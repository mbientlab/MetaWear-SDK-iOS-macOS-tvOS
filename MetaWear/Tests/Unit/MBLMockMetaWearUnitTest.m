/**
 * MBLMockMetaWearUnitTest.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 12/3/15.
 * Copyright 2015 MbientLab Inc. All rights reserved.
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

#import "MBLMockMetaWearUnitTest.h"
#import <CoreBluetooth/CoreBluetooth.h>

@implementation MBLMockMetaWearUnitTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for device to connect"];

    MBLSetUseMockManager(YES);
    [MBLMetaWearManager sharedManager].logLevel = MBLLogLevelInfo;
    // Nuke the devices
    [[MBLMetaWearManager sharedManager] startScanForMetaWearsAllowDuplicates:NO handler:^(NSArray<MBLMetaWear *> *array) {
        MBLMetaWear *device = [array firstObject];
        assert(device);
        [[MBLMetaWearManager sharedManager] stopScan];
        self.central = (MBLBluetoothCentralMock *)[MBLMetaWearManager sharedManager].centralManager;
        [self.central resetKnobs];
        self.peripheral = [[self.central retrievePeripheralsWithIdentifiers:@[device.identifier]] firstObject];
        [self.peripheral resetKnobs];
        [[[device connectAsync] success:^(MBLMetaWear * _Nonnull result) {
            self.device = result;
            [waitingExpectation fulfill];
        }] failure:^(NSError * _Nonnull error) {
            self.continueAfterFailure = NO;
            XCTAssertNil(error);
        }];
    }];
    
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)tearDown
{
    if (self.device) {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for disconnect"];
        [[self.device disconnectAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
            XCTAssertNil(t.error);
            [waitingExpectation fulfill];
            return nil;
        }];
        [self waitForExpectationsWithTimeout:15 handler:nil];
    }
    [super tearDown];
}

static const uint8_t randomKey1;
static uint8_t randomContext1;
static const uint8_t randomKey2;
static uint8_t randomContext2;

+ (dispatch_queue_t)randomQueue1
{
    static dispatch_queue_t singleton;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        singleton = dispatch_queue_create("com.mbientlab.metawear.randomQueue1", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(singleton, &randomKey1, &randomContext1, nil);
    });
    return singleton;
}

+ (BOOL)isRandomQueue1
{
    return (&randomContext1 == dispatch_get_specific(&randomKey1));
}

+ (dispatch_queue_t)randomQueue2
{
    static dispatch_queue_t singleton;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        singleton = dispatch_queue_create("com.mbientlab.metawear.randomQueue2", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(singleton, &randomKey2, &randomContext2, nil);
    });
    return singleton;
}

+ (BOOL)isRandomQueue2
{
    return (&randomContext2 == dispatch_get_specific(&randomKey2));
}

@end
