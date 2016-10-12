/**
 * MetaBootTest.m
 * MetaWearTests
 *
 * Created by Stephen Schiffli on 10/27/14.
 * Copyright 2014-2015 MbientLab Inc. All rights reserved.
 *
 * IMPORTANT: Your use of this Software is limited to those specific rights
 * granted under the terms of a software license agreement between the user who
 * downloaded the software, his/her employer (which must be your employer) and
 * MbientLab Inc, (the "License").  You may not use this Software unless you
 * agree to abide by the terms of the License which can be found at
 * www.mbientlab.com/terms.  The License limits your use, and you acknowledge,
 * that the Software may be modified, copied, and distributed when used in
 * conjunction with an MbientLab Inc, product.  Other than for the foregoing
 * purpose, you may not use, reproduce, copy, prepare derivative works of,
 * modify, distribute, perform, display or sell this Software and/or its
 * documentation for any purpose.
 *
 * YOU FURTHER ACKNOWLEDGE AND AGREE THAT THE SOFTWARE AND DOCUMENTATION ARE
 * PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED,
 * INCLUDING WITHOUT LIMITATION, ANY WARRANTY OF MERCHANTABILITY, TITLE,
 * NON-INFRINGEMENT AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL
 * MBIENTLAB OR ITS LICENSORS BE LIABLE OR OBLIGATED UNDER CONTRACT, NEGLIGENCE,
 * STRICT LIABILITY, CONTRIBUTION, BREACH OF WARRANTY, OR OTHER LEGAL EQUITABLE
 * THEORY ANY DIRECT OR INDIRECT DAMAGES OR EXPENSES INCLUDING BUT NOT LIMITED
 * TO ANY INCIDENTAL, SPECIAL, INDIRECT, PUNITIVE OR CONSEQUENTIAL DAMAGES, LOST
 * PROFITS OR LOST DATA, COST OF PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY,
 * SERVICES, OR ANY CLAIMS BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY
 * DEFENSE THEREOF), OR OTHER SIMILAR COSTS.
 *
 * Should you have any questions regarding your right to use this Software,
 * contact MbientLab via email: hello@mbientlab.com
 */

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "DeviceLookup.h"

static const int secondsToFind = 20;

/*
 This test setup looks for devices in MetaBoot mode.
 */
@interface MetaBootTest : XCTestCase <DFUPeripheralSelector, LoggerDelegate, DFUServiceDelegate, DFUProgressDelegate>
@property (nonatomic) MBLMetaWear *device;
@property (nonatomic) XCTestExpectation *waitingExpectation;
@end

@implementation MetaBootTest

- (void)setUp
{
    [super setUp];
    
    XCTestExpectation *findDeviceExpectation = [self expectationWithDescription:@"searching for device"];
    
    NSString *deviceUid = [DeviceLookup metawearUid];
    [[MBLMetaWearManager sharedManager] startScanForMetaBootsAllowDuplicates:NO handler:^(NSArray *array) {
        for (MBLMetaWear *cur in array) {
            if ([cur.identifier.UUIDString isEqualToString:deviceUid]) {
                [[MBLMetaWearManager sharedManager] stopScanForMetaWears];
                self.device = cur;
                [findDeviceExpectation fulfill];
            }
        }
    }];
    
    [self waitForExpectationsWithTimeout:secondsToFind handler:nil];
}

- (void)testPerformMetaBootDFU
{
    self.waitingExpectation = [self expectationWithDescription:@"wait for DFU"];
    
    MBLFirmwareBuild *firmware = [[MBLFirmwareBuild alloc] initWithHardwareRev:@"0.3"
                                                                   modelNumber:@"1"
                                                                   buildFlavor:@"vanilla"
                                                                   firmwareRev:@"1.2.3"
                                                                      filename:@"firmware.bin"];
    [[[self.device prepareForFirmwareUpdateToVersionAsync:firmware] success:^(MBLFirmwareUpdateInfo * _Nonnull result) {
        NSLog(@"%@", result.firmwareUrl);
        DFUFirmware *selectedFirmware;
        if ([result.firmwareUrl.pathExtension caseInsensitiveCompare:@"zip"] == NSOrderedSame) {
            selectedFirmware = [[DFUFirmware alloc] initWithUrlToZipFile:result.firmwareUrl];
        } else {
            selectedFirmware = [[DFUFirmware alloc] initWithUrlToBinOrHexFile:result.firmwareUrl urlToDatFile:nil type:DFUFirmwareTypeApplication];
        }
        
        DFUServiceInitiator *initiator = [[DFUServiceInitiator alloc] initWithCentralManager:result.centralManager target:result.target];
        [initiator withFirmwareFile:selectedFirmware];
        
        initiator.forceDfu = YES;
        // initiator.packetReceiptNotificationParameter = N; // default is 12
        initiator.logger = self;
        initiator.delegate = self;
        initiator.progressDelegate = self;
        initiator.peripheralSelector = self;
        
        [initiator start];
    }] failure:^(NSError * _Nonnull error) {
        XCTAssertNil(error);
        [self.waitingExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2600000000 handler:nil];
}

#pragma mark - DFU Service delegate methods

- (void)logWith:(enum LogLevel)level message:(NSString *)message
{
    NSLog(@"%ld: %@", (long) level, message);
}

- (void)didStateChangedTo:(enum State)state
{
    NSString *msg = @"";
    switch (state) {
        case StateConnecting:
            msg = @"Connecting...";
            break;
        case StateStarting:
            msg = @"Starting DFU...";
            break;
        case StateEnablingDfuMode:
            msg = @"Enabling DFU Bootloader...";
            break;
        case StateUploading:
            msg = @"Uploading...";
            break;
        case StateValidating:
            msg = @"Validating...";
            break;
        case StateDisconnecting:
            msg = @"Disconnecting...";
            break;
        case StateCompleted:
            msg = @"Upload complete";
            [self.waitingExpectation fulfill];
            break;
        case StateAborted:
            msg = @"Upload aborted";
            break;
    }
    NSLog(@"%@", msg);
}

-(void)onUploadProgress:(NSInteger)part totalParts:(NSInteger)totalParts progress:(NSInteger)percentage
currentSpeedBytesPerSecond:(double)speed avgSpeedBytesPerSecond:(double)avgSpeed
{
    NSLog(@"Progress: %ld%% (part %ld/%ld). Speed: %f bps, Avg speed: %f bps", (long) percentage, (long) part, (long) totalParts, speed, avgSpeed);
}

-(void)didErrorOccur:(enum DFUError)error withMessage:(NSString *)message
{
    XCTFail(@"Error %ld: %@", (long) error, message);
    [self.waitingExpectation fulfill];
}

- (BOOL)select:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSLog(@"Looking for: %@", self.device.identifier);
    NSLog(@"%@", peripheral);
    return [peripheral.identifier isEqual:self.device.identifier];
}

- (NSArray<CBUUID *> *)filterBy
{
    return nil;
}

@end
