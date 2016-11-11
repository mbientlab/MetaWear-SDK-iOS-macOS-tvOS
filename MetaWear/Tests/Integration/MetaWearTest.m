/**
 * MetaWearTests.m
 * MetaWearTests
 *
 * Created by Stephen Schiffli on 10/1/14.
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

#import "MetaWearTest.h"

static const BOOL forceClearAtStart = NO;
static const int secondsToConnect = 20;

@implementation MetaWearTest

- (void)setUp
{
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    XCTestExpectation *connectDeviceExpectation = [self expectationWithDescription:@"connect to device"];
    [MBLMetaWearManager sharedManager].logLevel = MBLLogLevelInfo;
    [[[[MBLDeviceLookup deviceForTestWithTimeout:10.0] continueOnDispatchWithSuccessBlock:^id _Nullable(BFTask<MBLMetaWear *> * _Nonnull t) {
        self.device = t.result;
        assert(self.device);
        return [MBLDeviceLookup connectDevice:self.device timeout:secondsToConnect forceClear:forceClearAtStart];
    }] success:^(id result) {
        if ([self.device.ambientLight isKindOfClass:[MBLAmbientLightLTR329 class]]) {
            self.i2cDevice = 0x29;
            self.i2cReadOnlyReg = 0x87;
            self.i2cReadOnlyRegValue = 0x05;
            self.i2cScratchReg = 0x85;
            self.i2cScratchRegValue = 0x35;
        } else if ([self.device.accelerometer isKindOfClass:[MBLAccelerometerMMA8452Q class]]) {
            self.i2cDevice = 0x1C;
            self.i2cReadOnlyReg = 0x0D;
            self.i2cReadOnlyRegValue = 0x2A;
            self.i2cScratchReg = 0x12;
            self.i2cScratchRegValue = 0x54;
        } else if ([self.device.photometer isKindOfClass:[MBLPhotometerTCS3472 class]]) {
            self.i2cDevice = 0x29;
            self.i2cReadOnlyReg = 0x80 | 0x12;
            self.i2cReadOnlyRegValue = 0x44;
            self.i2cScratchReg = 0x80 | 0x03;
            self.i2cScratchRegValue = 0xAB;
        } else {
            self.i2cDevice = 0;
        }
        self.model = [MBLDeviceLookup metawearModel];
        self.disconnectAtEnd = YES;
        [connectDeviceExpectation fulfill];
    }] failure:^(NSError * _Nonnull error) {
        self.continueAfterFailure = NO;
        XCTAssertNil(error);
    }];
    // The test will pause here, running the run loop, until the timeout is hit
    // or all expectations are fulfilled.
    [self waitForExpectationsWithTimeout:(secondsToConnect * 2) + 10 handler:nil];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    if (self.device && self.disconnectAtEnd) {
        XCTestExpectation *disconnectDeviceExpectation = [self expectationWithDescription:@"disconnect from device"];
        [[self.device disconnectAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
            XCTAssertNil(t.error);
            [disconnectDeviceExpectation fulfill];
            return nil;
        }];
        [self waitForExpectationsWithTimeout:5 handler:nil];
    }
    
    [super tearDown];
}

- (void)eventUpdateTest:(MBLEvent *)event time:(float)time
{
    [[event startNotificationsWithHandlerAsync:^(id obj, NSError *error) {
        XCTAssertNil(error);
        NSLog(@"%@", obj);
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        return nil;
    }];
    
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for stopNotificationsAsync"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[event stopNotificationsAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
            XCTAssertNil(t.error);
            [waitingExpectation fulfill];
            return nil;
        }];
    });
    [self waitForExpectationsWithTimeout:(time + 5) handler:nil];
}

- (void)eventUpdateTest:(MBLEvent *)event time:(float)time frequency:(float)frequency
{
    float __block count = 0;
    [[event startNotificationsWithHandlerAsync:^(id obj, NSError *error) {
        XCTAssertNil(error);
        NSLog(@"%@", obj);
        count++;
    }] failure:^(NSError * error) {
        XCTAssertNil(error);
    }];
    
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for stopNotificationsAsync"];
    NSDate *methodStart = [NSDate date];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[event stopNotificationsAsync] success:^(id  _Nonnull result) {
            NSDate *methodFinish = [NSDate date];
            NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
            XCTAssertEqualWithAccuracy(count, frequency * executionTime, frequency / 2.0);
            NSLog(@"actual:%f expected:%f", count, frequency * executionTime);
            [waitingExpectation fulfill];
        }];
    });
    [self waitForExpectationsWithTimeout:(time + 5) handler:nil];
}

- (void)eventCommandTest:(MBLEvent *)event time:(float)time
{
    [[event programCommandsToRunOnEventAsync:^{
        [self.device.led flashLEDColorAsync:[MBLColor whiteColor] withIntensity:1.0 numberOfFlashes:1];
        [self.device.hapticBuzzer startHapticWithDutyCycleAsync:248 pulseWidth:500 completion:nil];
    }] failure:^(NSError * _Nonnull error) {
        XCTAssertNil(error);
    }];
    
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for eraseCommandsToRunOnEventAsync"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[[event eraseCommandsToRunOnEventAsync] success:^(id  _Nonnull result) {
            [waitingExpectation fulfill];
        }] failure:^(NSError * _Nonnull error) {
            XCTAssertNil(error);
        }];
    });
    [self waitForExpectationsWithTimeout:time + 5 handler:nil];
}

- (void)eventLoggingTest:(MBLEvent *)event time:(float)time;
{
    [[event startLoggingAsync] failure:^(NSError * _Nonnull error) {
        XCTAssertNil(error);
    }];
    
    float __block progress = 0;
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for log download"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[[event downloadLogAndStopLoggingAsync:YES progressHandler:^(float number) {
            XCTAssertLessThanOrEqual(number, 1.0);
            XCTAssertGreaterThanOrEqual(number, 0.0);
            XCTAssertGreaterThanOrEqual(number, progress);
            progress = number;
        }] success:^(NSArray * _Nonnull result) {
            XCTAssertEqual(progress, 1.0);
            for (id obj in result) {
                NSLog(@"%@", obj);
            }
            [waitingExpectation fulfill];
        }] failure:^(NSError * _Nonnull error) {
            XCTAssertNil(error);
        }];
    });
    [self waitForExpectationsWithTimeout:time + 60 handler:nil];
}

- (void)eventConcurrencyTest:(MBLEvent *)event time:(float)time
{
    int __block notificationCount = 0;
    float __block progress = 0;
    
    [event startLoggingAsync];
    [[event startNotificationsWithHandlerAsync:^(id obj, NSError *error) {
        XCTAssertNil(error);
        NSLog(@"%@", obj);
        notificationCount++;
    }] failure:^(NSError * _Nonnull error) {
        XCTAssertNil(error);
    }];
    [event programCommandsToRunOnEventAsync:^{
        [self.device.led flashLEDColorAsync:[MBLColor whiteColor] withIntensity:1.0 numberOfFlashes:1];
        [self.device.hapticBuzzer startHapticWithDutyCycleAsync:248 pulseWidth:200 completion:nil];
    }];
    
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for log download"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [event eraseCommandsToRunOnEventAsync];
        [event stopNotificationsAsync];
        [[[event downloadLogAndStopLoggingAsync:YES progressHandler:^(float number) {
            XCTAssertLessThanOrEqual(number, 1.0);
            XCTAssertGreaterThanOrEqual(number, 0.0);
            XCTAssertGreaterThanOrEqual(number, progress);
            progress = number;
        }] success:^(NSArray * _Nonnull result) {
            XCTAssertEqual(progress, 1.0);
            XCTAssertGreaterThanOrEqual(notificationCount, result.count);
            for (id obj in result) {
                NSLog(@"%@", obj);
            }
            [waitingExpectation fulfill];
        }] failure:^(NSError * _Nonnull error) {
            XCTAssertNil(error);
            [waitingExpectation fulfill];
        }];
    });
    [self waitForExpectationsWithTimeout:time + 10 handler:nil];
}

- (double)accelerometerFrequencyNear:(double)frequency
{
    MBLAccelerometer *accelerometer = self.device.accelerometer;
    if ([accelerometer isKindOfClass:[MBLAccelerometerBMA255 class]]) {
        if (frequency > 1000.0) {
            return 2000.0;
        } else if (frequency > 500.0) {
            return 1000.0;
        } else if (frequency > 250.0) {
            return 500.0;
        } else if (frequency > 125.0) {
            return 125.0;
        } else if (frequency > 62.5) {
            return 62.5;
        } else if (frequency > 31.26) {
            return 31.26;
        } else if (frequency > 15.62) {
            return 15.62;
        } else {
            return 7.81;
        }
    } else if ([accelerometer isKindOfClass:[MBLAccelerometerBMI160 class]]) {
        if (frequency > 800.0) {
            return 1600.0;
        } else if (frequency > 400.0) {
            return 800.0;
        } else if (frequency > 200.0) {
            return 400.0;
        } else if (frequency > 100.0) {
            return 200.0;
        } else if (frequency > 50.0) {
            return 100.0;
        } else if (frequency > 25.0) {
            return 50.0;
        } else if (frequency > 12.5) {
            return 25.0;
        } else {
            return 12.5;
        }
    } else if ([accelerometer isKindOfClass:[MBLAccelerometerMMA8452Q class]]) {
        if (frequency > 400.0) {
            return 800.0;
        } else if (frequency > 200.0) {
            return 400.0;
        } else if (frequency > 100.0) {
            return 200.0;
        } else if (frequency > 50.0) {
            return 100.0;
        } else if (frequency > 12.5) {
            return 50.0;
        } else if (frequency > 6.25) {
            return 12.5;
        } else if (frequency > 1.56) {
            return 6.25;
        } else {
            return 1.56;
        }
    }
    assert(NO && "new accelerometer?");
    return 0;
}

- (void)sendData:(NSArray *)data
{
    for (NSString *byteArray in data) {
        NSData *toSend = [MBLMockUtils dataFromString:byteArray];
        [self.device writeCommandRegister:toSend withResponse:NO];
    }
}

@end
