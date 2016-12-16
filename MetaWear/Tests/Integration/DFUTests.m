/**
 * DFUTests.m
 * MetaWearTests
 *
 * Created by Stephen Schiffli on 9/30/16.
 * Copyright 2016 MbientLab Inc. All rights reserved.
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

#import "MetaWearTest.h"

@interface DFUTests : MetaWearTest <DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate, DFUPeripheralSelectorDelegate>
@property (nonatomic) XCTestExpectation *waitingExpectation;

@property (nonatomic) DFUServiceInitiator *initiator;
@property (nonatomic) DFUServiceController *dfuController;
@end

@implementation DFUTests

- (BFTask<NSNumber *> *)zipFirmwareExistsAsync:(NSURL *)url
{
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    [[NSURLSession.sharedSession dataTaskWithRequest:[[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10] completionHandler:^(NSData *data, NSURLResponse * response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (error) {
            [source trySetError:error];
        } else if (httpResponse.statusCode != 200) {
            [source trySetError:[NSError errorWithDomain:kMBLErrorDomain code:kMBLErrorNoAvailableFirmware userInfo:nil]];
        } else {
            [source trySetResult:@YES];
        }
    }] resume];
    return source.task;
}

- (void)testPerformDFU
{
    self.waitingExpectation = [self expectationWithDescription:@"wait for DFU"];
    NSString *version = @"1.2.5";
    MBLFirmwareBuild __block *firmware = [[MBLFirmwareBuild alloc] initWithHardwareRev:self.device.deviceInfo.hardwareRevision
                                                                           modelNumber:self.device.deviceInfo.modelNumber
                                                                           buildFlavor:@"vanilla"
                                                                           firmwareRev:version
                                                                              filename:@"firmware.zip"];
    // First try to fetch a zip file
    [[self zipFirmwareExistsAsync:firmware.firmwareURL] continueOnDispatchWithBlock:^id _Nullable(BFTask<NSNumber *> * _Nonnull t) {
        if (t.error) {
            // No zip file, assume it is a bin instead
            firmware = [[MBLFirmwareBuild alloc] initWithHardwareRev:self.device.deviceInfo.hardwareRevision
                                                         modelNumber:self.device.deviceInfo.modelNumber
                                                         buildFlavor:@"vanilla"
                                                         firmwareRev:version
                                                            filename:@"firmware.bin"];
        }
        // Do the update!
        [[[self.device prepareForFirmwareUpdateToVersionAsync:firmware] success:^(MBLFirmwareUpdateInfo * _Nonnull result) {
            NSLog(@"%@", result.firmwareUrl);
            DFUFirmware *selectedFirmware;
            if ([result.firmwareUrl.pathExtension caseInsensitiveCompare:@"zip"] == NSOrderedSame) {
                selectedFirmware = [[DFUFirmware alloc] initWithUrlToZipFile:result.firmwareUrl];
            } else {
                selectedFirmware = [[DFUFirmware alloc] initWithUrlToBinOrHexFile:result.firmwareUrl urlToDatFile:nil type:DFUFirmwareTypeApplication];
            }
            
            self.initiator = [[DFUServiceInitiator alloc] initWithCentralManager:result.centralManager target:result.target];
            [self.initiator withFirmware:selectedFirmware];
            
            self.initiator.forceDfu = YES;
            self.initiator.logger = self;
            self.initiator.delegate = self;
            self.initiator.progressDelegate = self;
            self.initiator.peripheralSelector = self;
            
            self.dfuController = [self.initiator start];
        }] failure:^(NSError * _Nonnull error) {
            XCTAssertNil(error);
            [self.waitingExpectation fulfill];
        }];
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:160 handler:nil];
}

- (void)testUpdateToRC
{
    self.waitingExpectation = [self expectationWithDescription:@"wait for DFU"];
    NSString *version = @"rc";
    MBLFirmwareBuild __block *firmware = [[MBLFirmwareBuild alloc] initWithHardwareRev:self.device.deviceInfo.hardwareRevision
                                                                           modelNumber:self.device.deviceInfo.modelNumber
                                                                           buildFlavor:@"vanilla"
                                                                           firmwareRev:version
                                                                              filename:@"firmware.zip"];
    // First try to fetch a zip file
    [[self zipFirmwareExistsAsync:firmware.firmwareURL] continueOnDispatchWithBlock:^id _Nullable(BFTask<NSNumber *> * _Nonnull t) {
        if (t.error) {
            // No zip file, assume it is a bin instead
            firmware = [[MBLFirmwareBuild alloc] initWithHardwareRev:self.device.deviceInfo.hardwareRevision
                                                         modelNumber:self.device.deviceInfo.modelNumber
                                                         buildFlavor:@"vanilla"
                                                         firmwareRev:version
                                                            filename:@"firmware.bin"];
        }
        // Do the update!
        [[[self.device prepareForFirmwareUpdateToVersionAsync:firmware] success:^(MBLFirmwareUpdateInfo * _Nonnull result) {
            NSLog(@"%@", result.firmwareUrl);
            DFUFirmware *selectedFirmware;
            if ([result.firmwareUrl.pathExtension caseInsensitiveCompare:@"zip"] == NSOrderedSame) {
                selectedFirmware = [[DFUFirmware alloc] initWithUrlToZipFile:result.firmwareUrl];
            } else {
                selectedFirmware = [[DFUFirmware alloc] initWithUrlToBinOrHexFile:result.firmwareUrl urlToDatFile:nil type:DFUFirmwareTypeApplication];
            }
            
            self.initiator = [[DFUServiceInitiator alloc] initWithCentralManager:result.centralManager target:result.target];
            [self.initiator withFirmware:selectedFirmware];
            
            self.initiator.forceDfu = YES;
            self.initiator.logger = self;
            self.initiator.delegate = self;
            self.initiator.progressDelegate = self;
            self.initiator.peripheralSelector = self;
            
            self.dfuController = [self.initiator start];
        }] failure:^(NSError * _Nonnull error) {
            XCTAssertNil(error);
            [self.waitingExpectation fulfill];
        }];
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:160 handler:nil];
}

#pragma mark - DFU Service delegate methods

- (void)dfuStateDidChangeTo:(enum DFUState)state
{
    NSString *msg = @"";
    switch (state) {
        case DFUStateConnecting:
            msg = @"Connecting...";
            break;
        case DFUStateStarting:
            msg = @"Starting DFU...";
            break;
        case DFUStateEnablingDfuMode:
            msg = @"Enabling DFU Bootloader...";
            break;
        case DFUStateUploading:
            msg = @"Uploading...";
            break;
        case DFUStateValidating:
            msg = @"Validating...";
            break;
        case DFUStateDisconnecting:
            msg = @"Disconnecting...";
            break;
        case DFUStateCompleted:
            msg = @"Upload complete";
            [self.waitingExpectation fulfill];
            break;
        case DFUStateAborted:
            msg = @"Upload aborted";
            break;
    }
    NSLog(@"%@", msg);
}

- (void)dfuError:(enum DFUError)error didOccurWithMessage:(NSString * _Nonnull)message
{
    XCTFail(@"Error %ld: %@", (long) error, message);
    [self.waitingExpectation fulfill];
}

- (void)dfuProgressDidChangeFor:(NSInteger)part outOf:(NSInteger)totalParts to:(NSInteger)progress currentSpeedBytesPerSecond:(double)currentSpeedBytesPerSecond avgSpeedBytesPerSecond:(double)avgSpeedBytesPerSecond
{
    NSLog(@"Progress: %ld%% (part %ld/%ld). Speed: %f bps, Avg speed: %f bps", (long)progress, (long)part, (long)totalParts, currentSpeedBytesPerSecond, avgSpeedBytesPerSecond);
}

- (void)logWith:(enum LogLevel)level message:(NSString * _Nonnull)message
{
    if (level > LogLevelInfo) {
        NSLog(@"%ld: %@", (long) level, message);
    }
}

- (BOOL)select:(CBPeripheral * _Nonnull)peripheral advertisementData:(NSDictionary<NSString *, id> * _Nonnull)advertisementData RSSI:(NSNumber * _Nonnull)RSSI
{
    NSLog(@"Looking for: %@", self.device.identifier);
    NSLog(@"%@", peripheral);
    return [peripheral.identifier isEqual:self.device.identifier];
}

- (NSArray<CBUUID *> * _Nullable)filterByHint:(CBUUID * _Nonnull)dfuServiceUUID
{
    return nil;
}

@end
