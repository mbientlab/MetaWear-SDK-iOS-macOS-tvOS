/**
 * AutomaticTests.m
 * MetaWearTests
 *
 * Created by Stephen Schiffli on 10/7/14.
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
#import "TempLoggerConfiguration.h"
#import "IncrementingEventConfig.h"

@interface AutomaticTests : MetaWearTest
@end

@implementation AutomaticTests

// Helpful Macros - Note we don't use functions to preserve proper line
// numbers in error reporting
#define AssertModule(module, imp, rev) \
    XCTAssertNotNil(module); \
    XCTAssertEqual(module.moduleInfo.moduleImplementation, imp); \
    XCTAssertEqual(module.moduleInfo.moduleRevision, rev);

#define AssertNilModule(module) \
    XCTAssertNil(module);

#define CapabilityCheck(thingThatNeedsToExist) \
    if (!(thingThatNeedsToExist)) { self.disconnectAtEnd = NO; return; }

- (void)testModuleVersions
{
    XCTAssertEqual(self.model, self.device.model);
    switch (self.model) {
        case MBLModelMetaWearR:
            AssertModule(self.device.mechanicalSwitch, 0, 0);
            AssertModule(self.device.led, 0, 1);
            AssertModule(self.device.accelerometer, 0, 1);
            AssertModule(self.device.temperature, 1, 0);
            AssertModule(self.device.gpio, 0, 2);
            AssertModule(self.device.neopixel, 0, 0);
            AssertModule(self.device.iBeacon, 0, 0);
            AssertModule(self.device.hapticBuzzer, 0, 0);
            AssertModule(self.device.dataProcessor, 0, 0);
            AssertModule(self.device.command, 0, 0);
            AssertModule(self.device.logging, 0, 2);
            AssertModule(self.device.timer, 0, 0);
            AssertModule(self.device.serial, 0, 1);
            AssertModule(self.device.ancs, 0, 0);
            AssertModule(self.device.macro, 0, 1);
            AssertNilModule(self.device.conductance);
            AssertModule(self.device.settings, 0, 4);
            AssertNilModule(self.device.barometer);
            AssertNilModule(self.device.gyro);
            AssertNilModule(self.device.ambientLight);
            AssertNilModule(self.device.magnetometer);
            AssertNilModule(self.device.hygrometer);
            AssertNilModule(self.device.photometer);
            AssertNilModule(self.device.proximity);
            break;
        case MBLModelMetaWearRG:
            AssertModule(self.device.mechanicalSwitch, 0, 0);
            AssertModule(self.device.led, 0, 1);
            AssertModule(self.device.accelerometer, 1, 1);
            AssertModule(self.device.temperature, 1, 0);
            AssertModule(self.device.gpio, 0, 2);
            AssertModule(self.device.neopixel, 0, 0);
            AssertModule(self.device.iBeacon, 0, 0);
            AssertModule(self.device.hapticBuzzer, 0, 0);
            AssertModule(self.device.dataProcessor, 0, 0);
            AssertModule(self.device.command, 0, 0);
            AssertModule(self.device.logging, 0, 2);
            AssertModule(self.device.timer, 0, 0);
            AssertModule(self.device.serial, 0, 1);
            AssertModule(self.device.ancs, 0, 0);
            AssertModule(self.device.macro, 0, 1);
            AssertNilModule(self.device.conductance);
            AssertModule(self.device.settings, 0, 4);
            AssertNilModule(self.device.barometer);
            AssertModule(self.device.gyro, 0, 1);
            AssertNilModule(self.device.ambientLight);
            AssertNilModule(self.device.magnetometer);
            AssertNilModule(self.device.hygrometer);
            AssertNilModule(self.device.photometer);
            AssertNilModule(self.device.proximity);
            break;
        case MBLModelMetaWearRPro:
            AssertModule(self.device.mechanicalSwitch, 0, 0);
            AssertModule(self.device.led, 0, 1);
            AssertModule(self.device.accelerometer, 1, 1);
            AssertModule(self.device.temperature, 1, 0);
            AssertModule(self.device.gpio, 0, 2);
            AssertModule(self.device.neopixel, 0, 0);
            AssertModule(self.device.iBeacon, 0, 0);
            AssertModule(self.device.hapticBuzzer, 0, 0);
            AssertModule(self.device.dataProcessor, 0, 0);
            AssertModule(self.device.command, 0, 0);
            AssertModule(self.device.logging, 0, 2);
            AssertModule(self.device.timer, 0, 0);
            AssertModule(self.device.serial, 0, 1);
            AssertModule(self.device.ancs, 0, 0);
            AssertModule(self.device.macro, 0, 1);
            AssertNilModule(self.device.conductance);
            AssertModule(self.device.settings, 0, 4);
            AssertModule(self.device.barometer, 0, 0);
            AssertModule(self.device.gyro, 0, 1);
            AssertModule(self.device.ambientLight, 0, 0);
            AssertNilModule(self.device.magnetometer);
            AssertNilModule(self.device.hygrometer);
            AssertNilModule(self.device.photometer);
            AssertNilModule(self.device.proximity);
            break;
        case MBLModelMetaWearC:
            AssertModule(self.device.mechanicalSwitch, 0, 0);
            AssertModule(self.device.led, 0, 1);
            AssertModule(self.device.accelerometer, 1, 1);
            AssertModule(self.device.temperature, 1, 0);
            AssertModule(self.device.gpio, 0, 2);
            AssertModule(self.device.neopixel, 0, 0);
            AssertModule(self.device.iBeacon, 0, 0);
            AssertModule(self.device.hapticBuzzer, 0, 0);
            AssertModule(self.device.dataProcessor, 0, 0);
            AssertModule(self.device.command, 0, 0);
            AssertModule(self.device.logging, 0, 2);
            AssertModule(self.device.timer, 0, 0);
            AssertModule(self.device.serial, 0, 1);
            AssertModule(self.device.ancs, 0, 0);
            AssertModule(self.device.macro, 0, 1);
            AssertNilModule(self.device.conductance);
            AssertModule(self.device.settings, 0, 4);
            AssertNilModule(self.device.barometer);
            AssertModule(self.device.gyro, 0, 1);
            AssertNilModule(self.device.ambientLight);
            AssertNilModule(self.device.magnetometer);
            AssertNilModule(self.device.hygrometer);
            AssertNilModule(self.device.photometer);
            AssertNilModule(self.device.proximity);
            break;
        case MBLModelMetaWearCPro:
            AssertModule(self.device.mechanicalSwitch, 0, 0);
            AssertModule(self.device.led, 0, 1);
            AssertModule(self.device.accelerometer, 1, 1);
            AssertModule(self.device.temperature, 1, 0);
            AssertModule(self.device.gpio, 0, 2);
            AssertModule(self.device.neopixel, 0, 0);
            AssertModule(self.device.iBeacon, 0, 0);
            AssertModule(self.device.hapticBuzzer, 0, 0);
            AssertModule(self.device.dataProcessor, 0, 0);
            AssertModule(self.device.command, 0, 0);
            AssertModule(self.device.logging, 0, 2);
            AssertModule(self.device.timer, 0, 0);
            AssertModule(self.device.serial, 0, 1);
            AssertModule(self.device.ancs, 0, 0);
            AssertModule(self.device.macro, 0, 1);
            AssertNilModule(self.device.conductance);
            AssertModule(self.device.settings, 0, 4);
            AssertModule(self.device.barometer, 0, 0);
            AssertModule(self.device.gyro, 0, 1);
            AssertModule(self.device.ambientLight, 0, 0);
            AssertModule(self.device.magnetometer, 0, 1);
            AssertNilModule(self.device.hygrometer);
            AssertNilModule(self.device.photometer);
            AssertNilModule(self.device.proximity);
            break;
        case MBLModelMetaDetector:
            AssertModule(self.device.mechanicalSwitch, 0, 0);
            AssertModule(self.device.led, 0, 1);
            AssertModule(self.device.accelerometer, 3, 1);
            AssertModule(self.device.temperature, 1, 0);
            AssertModule(self.device.gpio, 0, 2);
            AssertModule(self.device.neopixel, 0, 0);
            AssertModule(self.device.iBeacon, 0, 0);
            AssertModule(self.device.hapticBuzzer, 0, 0);
            AssertModule(self.device.dataProcessor, 0, 0);
            AssertModule(self.device.command, 0, 0);
            AssertModule(self.device.logging, 0, 2);
            AssertModule(self.device.timer, 0, 0);
            AssertModule(self.device.serial, 0, 1);
            AssertModule(self.device.ancs, 0, 0);
            AssertModule(self.device.macro, 0, 1);
            AssertNilModule(self.device.conductance);
            AssertModule(self.device.settings, 0, 4);
            AssertNilModule(self.device.barometer);
            AssertNilModule(self.device.gyro);
            AssertModule(self.device.ambientLight, 0, 0);
            AssertNilModule(self.device.magnetometer);
            AssertNilModule(self.device.hygrometer);
            AssertNilModule(self.device.photometer);
            AssertModule(self.device.proximity, 0, 0);
            break;
        case MBLModelMetaEnvironment:
            AssertModule(self.device.mechanicalSwitch, 0, 0);
            AssertModule(self.device.led, 0, 0);
            AssertModule(self.device.accelerometer, 3, 0);
            AssertModule(self.device.temperature, 1, 0);
            AssertModule(self.device.gpio, 0, 1);
            AssertModule(self.device.neopixel, 0, 0);
            AssertModule(self.device.iBeacon, 0, 0);
            AssertModule(self.device.hapticBuzzer, 0, 0);
            AssertModule(self.device.dataProcessor, 0, 0);
            AssertModule(self.device.command, 0, 0);
            AssertModule(self.device.logging, 0, 2);
            AssertModule(self.device.timer, 0, 0);
            AssertModule(self.device.serial, 0, 0);
            AssertModule(self.device.ancs, 0, 0);
            AssertModule(self.device.macro, 0, 1);
            AssertNilModule(self.device.conductance);
            AssertModule(self.device.settings, 0, 3);
            AssertModule(self.device.barometer, 1, 0);
            AssertNilModule(self.device.gyro);
            AssertNilModule(self.device.ambientLight);
            AssertNilModule(self.device.magnetometer);
            AssertModule(self.device.hygrometer, 0, 0);
            AssertModule(self.device.photometer, 0, 0);
            AssertNilModule(self.device.proximity);
            break;
        case MBLModelMetaTracker:
            AssertModule(self.device.mechanicalSwitch, 0, 0);
            AssertModule(self.device.led, 0, 1);
            AssertModule(self.device.accelerometer, 1, 1);
            AssertModule(self.device.temperature, 1, 0);
            AssertModule(self.device.gpio, 0, 2);
            AssertModule(self.device.neopixel, 0, 0);
            AssertModule(self.device.iBeacon, 0, 0);
            AssertModule(self.device.hapticBuzzer, 0, 0);
            AssertModule(self.device.dataProcessor, 0, 0);
            AssertModule(self.device.command, 0, 0);
            AssertModule(self.device.logging, 0, 2);
            AssertModule(self.device.timer, 0, 0);
            AssertModule(self.device.serial, 0, 1);
            AssertNilModule(self.device.ancs);
            AssertModule(self.device.macro, 0, 1);
            AssertNilModule(self.device.conductance);
            AssertModule(self.device.settings, 0, 4);
            AssertModule(self.device.barometer, 1, 0);
            AssertModule(self.device.gyro, 0, 1);
            AssertModule(self.device.ambientLight, 0, 0);
            AssertNilModule(self.device.magnetometer);
            AssertModule(self.device.hygrometer, 0, 0);
            AssertNilModule(self.device.photometer);
            AssertNilModule(self.device.proximity);
            break;
        case MBLModelMetaMotionR:
            AssertModule(self.device.mechanicalSwitch, 0, 0);
            AssertModule(self.device.led, 0, 1);
            AssertModule(self.device.accelerometer, 1, 2);
            AssertModule(self.device.temperature, 1, 0);
            AssertModule(self.device.gpio, 0, 2);
            AssertModule(self.device.neopixel, 0, 0);
            AssertModule(self.device.iBeacon, 0, 0);
            AssertModule(self.device.hapticBuzzer, 0, 0);
            AssertModule(self.device.dataProcessor, 0, 1);
            AssertModule(self.device.command, 0, 0);
            AssertModule(self.device.logging, 0, 2);
            AssertModule(self.device.timer, 0, 0);
            AssertModule(self.device.serial, 0, 1);
            AssertNilModule(self.device.ancs);
            AssertModule(self.device.macro, 0, 1);
            AssertNilModule(self.device.conductance);
            AssertModule(self.device.settings, 0, 5);
            AssertModule(self.device.barometer, 0, 0);
            AssertModule(self.device.gyro, 0, 1);
            AssertModule(self.device.ambientLight, 0, 0);
            AssertModule(self.device.magnetometer, 0, 1);
            AssertNilModule(self.device.hygrometer);
            AssertNilModule(self.device.photometer);
            AssertNilModule(self.device.proximity);
            AssertModule(self.device.sensorFusion, 0, 0);
            break;
        default:
            XCTFail("Not enabeled");
            break;
    }
}


- (void)testArchiveSpeed
{
    [self measureBlock:^{
        [self.device synchronizeAsync];
        dispatch_sync([MBLConstants metaWearQueue], ^{
        });
    }];
}

- (void)testSwitchRead
{
    CapabilityCheck(self.device.mechanicalSwitch.switchValue);
    
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"testSwitchRead"];
    
    [[self.device.mechanicalSwitch.switchValue readAsync] success:^(MBLNumericData * _Nonnull result) {
        XCTAssertEqual(result.value.boolValue, NO);
        [waitingExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testMultiConnect
{
    XCTestExpectation *firstConnection = [self expectationWithDescription:@"firstConnection"];
    XCTestExpectation *secondConnection = [self expectationWithDescription:@"secondConnection"];
    
    [[self.device disconnectAsync] success:^(id result) {
        [[self.device connectAsync] success:^(id result) {
            [firstConnection fulfill];
        }];
    }];
    [[self.device disconnectAsync] success:^(id result) {
        [[self.device connectAsync] success:^(id result) {
            [secondConnection fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testMultiTimeoutConnect
{
    XCTestExpectation *firstConnection = [self expectationWithDescription:@"firstConnection"];
    XCTestExpectation *secondConnection = [self expectationWithDescription:@"secondConnection"];
    
    [[self.device disconnectAsync] continueOnDispatchWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        [[self.device connectWithTimeoutAsync:0.1] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
            XCTAssertNotNil(t.error);
            XCTAssertEqual(t.error.domain, kMBLErrorDomain);
            XCTAssertEqual(t.error.code, kMBLErrorConnectionTimeout);
            [firstConnection fulfill];
            return nil;
        }];
        [[self.device connectWithTimeoutAsync:30] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
            XCTAssertNil(t.error);
            [secondConnection fulfill];
            return nil;
        }];
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testDisconnectedErrors
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"testDisconnectedErrors"];
    
    [[[self.device disconnectAsync] continueOnDispatchWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        return [self.device setConfigurationAsync:nil];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNotNil(t.error);
        XCTAssertEqual(t.error.code, kMBLErrorNotConnected);
        [waitingExpectation fulfill];
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testAccelerometerUpdates
{
    CapabilityCheck(self.device.accelerometer.dataReadyEvent);

    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"testAccelerometerUpdates"];

    self.device.accelerometer.sampleFrequency = [self accelerometerFrequencyNear:50];
    int __block count = 0;
    [self.device.accelerometer.dataReadyEvent startNotificationsWithHandlerAsync:^(MBLAccelerometerData *obj, NSError *error) {
        // The RMS when not moving should be gravity only, or sqrt(1000*1000/3) = 577
        XCTAssertEqualWithAccuracy(obj.RMS, 0.577, 0.1);
        count++;
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.device.accelerometer.dataReadyEvent stopNotificationsAsync];
        // Check for 2 seconds worth of updates
        XCTAssertEqualWithAccuracy(count, self.device.accelerometer.sampleFrequency * 2.0, self.device.accelerometer.sampleFrequency / 2.0);
        [waitingExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testAccelerometerStreamDisconnect
{
    CapabilityCheck(self.device.accelerometer.dataReadyEvent);

    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"waitingExpectation"];
    XCTestExpectation *errorExpectation = [self expectationWithDescription:@"errorExpectation"];
    
    self.device.accelerometer.sampleFrequency = 50;
    BOOL __block expectSample = YES;
    [self.device.accelerometer.dataReadyEvent startNotificationsWithHandlerAsync:^(MBLAccelerometerData *obj, NSError *error) {
        if (error) {
            [errorExpectation fulfill];
        } else {
            XCTAssertEqualWithAccuracy(obj.RMS, 0.577, 0.1);
            XCTAssertTrue(expectSample);
        }
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self.device disconnectAsync] success:^(id result) {
            expectSample = NO;
            [[self.device connectAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
                XCTAssertNil(t.error);
                // Make sure we don't get any stray notifications
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [waitingExpectation fulfill];
                });
                return nil;
            }];
        }];
    });
    
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testAccelerometerLogging
{
    CapabilityCheck(self.device.accelerometer.dataReadyEvent);

    self.device.accelerometer.sampleFrequency = [self accelerometerFrequencyNear:200];
    
    int __block notificationCount = 0;
    [self.device.accelerometer.dataReadyEvent startLoggingAsync];
    [self.device.accelerometer.dataReadyEvent startNotificationsWithHandlerAsync:^(MBLAccelerometerData *sample, NSError *error) {
        XCTAssertEqualWithAccuracy(sample.RMS, 0.577, 0.1);
        notificationCount++;
    }];
    
    float __block progress = 0;
    int __block progressCount = 0;
    
    XCTestExpectation *loggingExpectation = [self expectationWithDescription:@"logging accelerometer data"];
    // Let the log run for 3.0 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.device.accelerometer.dataReadyEvent stopNotificationsAsync];
        [[self.device.accelerometer.dataReadyEvent downloadLogAndStopLoggingAsync:YES progressHandler:^(float number) {
            XCTAssertLessThanOrEqual(number, 1.0);
            XCTAssertGreaterThanOrEqual(number, 0.0);
            XCTAssertGreaterThanOrEqual(number, progress);
            progress = number;
            progressCount++;
        }] success:^(NSArray<MBLAccelerometerData *> * _Nonnull result) {
            // Make sure progress reported complete before this handler gets called
            XCTAssertEqual(progress, 1.0);
            // Make sure we got at least as many log entries as notifications
            XCTAssertGreaterThanOrEqual(result.count, notificationCount);
            // Make sure the number of notifications is in an expected range...this is from trial and error
            XCTAssertEqualWithAccuracy(notificationCount, self.device.accelerometer.sampleFrequency * 3.0, self.device.accelerometer.sampleFrequency / 2.0);
            
            for (MBLAccelerometerData *sample in result) {
                // The RMS when not moving should be gravity only, or sqrt(1000*1000/3) = 577
                XCTAssertEqualWithAccuracy(sample.RMS, 0.577, 0.1);
            }
            // Finished the test!
            // We were having trouble with extra samples getting into the log after the above
            // readout, so here we do an extra purge after the accelermoeter has had time to
            // empty its buffers.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[self.device.logging stopAndClearLog] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                    [loggingExpectation fulfill];
                    return nil;
                }];
            });
        }];
    });
    [self waitForExpectationsWithTimeout:60 handler:nil];
    XCTAssertGreaterThanOrEqual(progressCount, 4);
}

- (void)testStopLogWithoutDownload
{
    CapabilityCheck(self.device.accelerometer.dataReadyEvent);
    
    self.device.accelerometer.sampleFrequency = [self accelerometerFrequencyNear:200];
    
    int __block entryCount = 0;
    [self.device.accelerometer.dataReadyEvent startLoggingAsync];
    
    XCTestExpectation *loggingExpectation = [self expectationWithDescription:@"logging accelerometer data"];
    // Let the log run for 2.0 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self.device.accelerometer.dataReadyEvent stopLoggingAsync] success:^(MBLNumericData * _Nonnull result) {
            entryCount = result.value.intValue;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[self.device.accelerometer.dataReadyEvent downloadLogAndStopLoggingAsync:YES remainingHandler:^(uint32_t totalEntries, uint32_t remainingEntries) {
                    XCTAssertEqual(totalEntries, entryCount);
                }] success:^(NSArray<MBLAccelerometerData *> * _Nonnull result) {
                    // Finished the test!
                    // We were having trouble with extra samples getting into the log after the above
                    // readout, so here we do an extra purge after the accelermoeter has had time to
                    // empty its buffers.
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [[self.device.logging stopAndClearLog] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                            [loggingExpectation fulfill];
                            return nil;
                        }];
                    });
                }];
            });
        }];
    });
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

- (void)testAccelerometerRMSLogging
{
    CapabilityCheck(self.device.accelerometer.rmsDataReadyEvent);

    self.device.accelerometer.sampleFrequency = [self accelerometerFrequencyNear:200];
    
    int __block notificationCount = 0;
    [self.device.accelerometer.rmsDataReadyEvent startLoggingAsync];
    [self.device.accelerometer.rmsDataReadyEvent startNotificationsWithHandlerAsync:^(MBLRMSAccelerometerData *sample, NSError *error) {
        XCTAssertNil(error);
        XCTAssertEqualWithAccuracy(sample.rms, 0.577, 0.1);
        notificationCount++;
    }];
    
    uint32_t __block previousTotal = 0;
    uint32_t __block previousRemaining = UINT32_MAX;
    int __block progressCount = 0;

    XCTestExpectation *loggingExpectation = [self expectationWithDescription:@"logging accelerometer data"];
    // Let the log run for 3.0 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.device.accelerometer.rmsDataReadyEvent stopNotificationsAsync];
        [[self.device.accelerometer.rmsDataReadyEvent downloadLogAndStopLoggingAsync:YES remainingHandler:^(uint32_t totalEntries, uint32_t remainingEntries) {
            NSLog(@"%d %d", remainingEntries, totalEntries);
            XCTAssertLessThanOrEqual(remainingEntries, totalEntries);
            XCTAssertLessThanOrEqual(remainingEntries, previousRemaining);
            previousRemaining = remainingEntries;
            previousTotal = totalEntries;
            progressCount++;
        }] success:^(NSArray<MBLRMSAccelerometerData *> * _Nonnull result) {
            // Make sure progress reported complete before this handler gets called
            XCTAssertEqual(previousRemaining, 0);
            // Make sure we got at least as many log entries as notifications
            XCTAssertGreaterThanOrEqual(result.count, notificationCount);
            // Make sure the number of notifications is in an expected range...this is from trial and error
            XCTAssertEqualWithAccuracy(notificationCount, self.device.accelerometer.sampleFrequency * 3.0, self.device.accelerometer.sampleFrequency / 2.0);
            
            for (MBLRMSAccelerometerData *sample in result) {
                // The RMS when not moving should be gravity only, or sqrt(1000*1000/3) = 577
                XCTAssertEqualWithAccuracy(sample.rms, 0.577, 0.1);
            }
            // Finished the test!
            // We were having trouble with extra samples getting into the log after the above
            // readout, so here we do an extra purge after the accelermoeter has had time to
            // empty its buffers.
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[self.device.logging stopAndClearLog] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                    [loggingExpectation fulfill];
                    return nil;
                }];
            });
        }];
    });
    [self waitForExpectationsWithTimeout:60 handler:nil];
    XCTAssertGreaterThanOrEqual(progressCount, 4);
}

- (void)testTemperatureRead
{
    CapabilityCheck(self.device.temperature);
    
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"testTemperatureRead"];

    NSMutableArray *tasks = [NSMutableArray array];
    for (MBLData *channel in self.device.temperature.channels) {
        BFTask *readTask;
        if ([channel isKindOfClass:[MBLExternalThermistor class]]) {
            ((MBLExternalThermistor *)channel).readPin = 0;
            ((MBLExternalThermistor *)channel).enablePin = 1;
            readTask = [channel readAsync];
        } else {
            readTask = [channel readAsync];
            [readTask success:^(MBLNumericData * _Nonnull result) {
                // Make sure the temp is in an expected range
                XCTAssertEqualWithAccuracy(result.value.floatValue, 35.0, 20.0);
            }];
        }
        [tasks addObject:readTask];
    }

    [[BFTask taskForCompletionOfAllTasks:tasks] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        XCTAssertNil(task.error);
        [waitingExpectation fulfill];
        return nil;
    }];
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testGpioReads
{
    CapabilityCheck(self.device.gpio);

    for (MBLGPIOPin *pin in self.device.gpio.pins) {
        // TODO: Add pin change test
        if (pin.digitalValue) {
            {
                // Digital out in high
                XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"Digital out in high"];
                [pin setToDigitalValueAsync:NO];
                [pin setToDigitalValueAsync:YES];
                [[pin.digitalValue readAsync] success:^(MBLNumericData * _Nonnull result) {
                    XCTAssertEqual(result.value.boolValue, YES);
                    [waitingExpectation fulfill];
                }];
                [self waitForExpectationsWithTimeout:10 handler:nil];
            }
            {
                // Digital out in low
                XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"Digital out in low"];
                [pin setToDigitalValueAsync:YES];
                [pin setToDigitalValueAsync:NO];
                [[pin.digitalValue readAsync] success:^(MBLNumericData * _Nonnull result) {
                    XCTAssertEqual(result.value.boolValue, NO);
                    [waitingExpectation fulfill];
                }];
                [self waitForExpectationsWithTimeout:10 handler:nil];
            }
            {
                // Digital in pullup
                XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"Digital in pullup"];
                pin.configuration = MBLPinConfigurationPulldown;
                pin.configuration = MBLPinConfigurationPullup;
                [[pin.digitalValue readAsync] success:^(MBLNumericData * _Nonnull result) {
                    XCTAssertEqual(result.value.boolValue, YES);
                    [waitingExpectation fulfill];
                }];
                [self waitForExpectationsWithTimeout:10 handler:nil];
            }
            {
                // Digital in pulldown
                XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"Digital in pulldown"];
                pin.configuration = MBLPinConfigurationPullup;
                pin.configuration = MBLPinConfigurationPulldown;
                [[pin.digitalValue readAsync] success:^(MBLNumericData * _Nonnull result) {
                    XCTAssertEqual(result.value.boolValue, NO);
                    [waitingExpectation fulfill];
                }];
                [self waitForExpectationsWithTimeout:10 handler:nil];
            }
        }
        if (pin.analogRatio) {
            {
                // Analog ratio in pullup
                XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"Analog ratio in pullup"];
                pin.configuration = MBLPinConfigurationPulldown;
                pin.configuration = MBLPinConfigurationPullup;
                [[pin.analogRatio readAsync] success:^(MBLNumericData * _Nonnull result) {
                    XCTAssertEqualWithAccuracy(result.value.floatValue, 0.976540, 0.25);
                    [waitingExpectation fulfill];
                }];
                [self waitForExpectationsWithTimeout:10 handler:nil];
            }
            {
                // Analog ratio in pulldown
                XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"Analog ratio in pulldown"];
                pin.configuration = MBLPinConfigurationPullup;
                pin.configuration = MBLPinConfigurationPulldown;
                [[pin.analogRatio readAsync] success:^(MBLNumericData * _Nonnull result) {
                    XCTAssertEqualWithAccuracy(result.value.floatValue, 0.006843, 0.25);
                    [waitingExpectation fulfill];
                }];
                [self waitForExpectationsWithTimeout:10 handler:nil];
            }
        }
        if (pin.analogAbsolute) {
            {
                // Analog abs in pullup
                XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"Analog abs in pullup"];
                pin.configuration = MBLPinConfigurationPulldown;
                pin.configuration = MBLPinConfigurationPullup;
                [[pin.analogAbsolute readAsync] success:^(MBLNumericData * _Nonnull result) {
                    XCTAssertEqualWithAccuracy(result.value.floatValue, 2.956000, 0.25);
                    [waitingExpectation fulfill];
                }];
                [self waitForExpectationsWithTimeout:10 handler:nil];
            }
            {
                // Analog abs in pulldown
                XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"Analog abs in pulldown"];
                pin.configuration = MBLPinConfigurationPullup;
                pin.configuration = MBLPinConfigurationPulldown;
                [[pin.analogAbsolute readAsync] success:^(MBLNumericData * _Nonnull result) {
                    XCTAssertEqualWithAccuracy(result.value.floatValue, 0.024000, 0.25);
                    [waitingExpectation fulfill];
                }];
                [self waitForExpectationsWithTimeout:10 handler:nil];
            }
        }
    }
}

- (void)testTimer
{
    CapabilityCheck(self.device.timer);

    MBLEvent *event = [self.device.timer eventWithPeriod:500 eventCount:4];
    
    int __block count = 0;
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"testTimer"];
    [event startNotificationsWithHandlerAsync:^(id obj, NSError *error) {
        NSLog(@"%@", obj);
        count++;
        if (count == 4) {
            [event stopNotificationsAsync];
            [waitingExpectation fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testLogDownloadWithoutStopping
{
    CapabilityCheck(self.device.temperature.onDieThermistor);

    int samplePeriod = 200;
    int __block notificationCount = 0;
    int __block logCount = 0;
    
    MBLEvent<MBLNumericData *> *event = [self.device.temperature.onDieThermistor periodicReadWithPeriod:samplePeriod];
    [event startNotificationsWithHandlerAsync:^(id obj, NSError *error) {
        NSLog(@"%@", obj);
        notificationCount++;
    }];
    
    [event startLoggingAsync];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertTrue(event.isLogging);
        [[event downloadLogAndStopLoggingAsync:NO] success:^(NSArray<MBLNumericData *> * _Nonnull result) {
            for (id obj in result) {
                NSLog(@"Log: %@", obj);
            }
            logCount += result.count;
        }];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[event downloadLogAndStopLoggingAsync:NO] success:^(NSArray<MBLNumericData *> * _Nonnull result) {
            for (id obj in result) {
                NSLog(@"Log: %@", obj);
            }
            logCount += result.count;
        }];
    });
    
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"testLogDownloadWithoutStopping"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [event stopNotificationsAsync];
        [[event downloadLogAndStopLoggingAsync:YES] success:^(NSArray<MBLNumericData *> * _Nonnull result) {
            for (id obj in result) {
                NSLog(@"Log: %@", obj);
            }
            logCount += result.count;
            XCTAssertGreaterThanOrEqual(logCount, notificationCount);
            [waitingExpectation fulfill];
        }];
    });
    
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)recursiveSaturation:(int)i expectation:(XCTestExpectation *)expectation
{
    [[self.device disconnectAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        NSLog(@"Bye Bye");
        // Reconnect after a random time goes by
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((arc4random() % 16) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[self.device connectAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
                XCTAssertNil(t.error);
                TempLoggerConfiguration *configuration = self.device.configuration;
                XCTAssertNotNil(configuration);
                XCTAssertTrue(configuration.periodicTemperature.isLogging);
                [[configuration.periodicTemperature downloadLogAndStopLoggingAsync:i == 0 progressHandler:^(float number) {
                    NSLog(@"Progress: %f", number);
                }] success:^(NSArray<MBLNumericData *> * _Nonnull result) {
                    XCTAssertNotEqual(result.count, 0);
                    NSLog(@"Total: %lu", (unsigned long)result.count);
                    if (i > 0) {
                        [self recursiveSaturation:i - 1 expectation:expectation];
                    } else {
                        [expectation fulfill];
                    }
                }];
                return nil;
            }];
        });
        return nil;
    }];
}

- (void)testLogSaturation
{
    CapabilityCheck(self.device.temperature.onDieThermistor);

    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"testLogSaturation recursive loop"];
    [[self.device setConfigurationAsync:[[TempLoggerConfiguration alloc] initWithPeriod:2]] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        if (!t.error) {
            [self recursiveSaturation:2 expectation:waitingExpectation];
        } else {
            [waitingExpectation fulfill];
        }
        return nil;
    }];
    [self waitForExpectationsWithTimeout:500 handler:nil];
    
    // Now clear all the state
    waitingExpectation = [self expectationWithDescription:@"testLogSaturation clear all state"];
    [[[self.device connectAsync] continueOnDispatchWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        return [self.device setConfigurationAsync:nil];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        [waitingExpectation fulfill];
        return nil;
    }];
    [self waitForExpectationsWithTimeout:45 handler:nil];
}

- (void)testLogDownloadDisconnect
{
    CapabilityCheck(self.device.timer);

    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"logging"];
    
    [[[self.device setConfigurationAsync:[[IncrementingEventConfig alloc] initWithPeriod:20]] continueOnDispatchWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        // Give it some time to log quality data
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            IncrementingEventConfig *configuration = self.device.configuration;
            XCTAssertNotNil(configuration);
            XCTAssertTrue(configuration.incrementingCounter.isLogging);
            [[configuration.incrementingCounter downloadLogAndStopLoggingAsync:YES progressHandler:^(float number) {
                if (number > 0.25) {
                    NSLog(@"Disconnecting!");
                    [[MBLMetaWearManager sharedManager] disconnectMetaWear:self.device fromPeripheralSide:NO];
                }
            }] failure:^(NSError * _Nonnull error) {
                [waitingExpectation fulfill];
            }];
        });
        return nil;
    }] failure:^(NSError * _Nonnull error) {
        XCTAssertNil(error);
        [waitingExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:40 handler:nil];
    
    waitingExpectation = [self expectationWithDescription:@"downloading"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self.device connectAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
            XCTAssertNil(t.error);
            IncrementingEventConfig *configuration = self.device.configuration;
            if (configuration) {
                [[configuration.incrementingCounter downloadLogAndStopLoggingAsync:YES] success:^(NSArray<MBLNumericData *> * _Nonnull result) {
                    NSLog(@"%@", result);
                    for (int i = 1; i <= result.count; i++) {
                        MBLNumericData *obj = result[i - 1];
                        XCTAssertEqual(obj.value.intValue, i);
                    }
                    [waitingExpectation fulfill];
                }];
            }
            return nil;
        }];
    });
    [self waitForExpectationsWithTimeout:40 handler:nil];
    
    // Now clear all the state
    waitingExpectation = [self expectationWithDescription:@"clearing state"];
    [[[self.device connectAsync] continueOnDispatchWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        return [self.device setConfigurationAsync:nil];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        [waitingExpectation fulfill];
        return nil;
    }];
    [self waitForExpectationsWithTimeout:45 handler:nil];
}

- (void)testLogDownloadReset
{
    CapabilityCheck(self.device.timer);

    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"logging"];
    [[self.device setConfigurationAsync:[[IncrementingEventConfig alloc] initWithPeriod:20]] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        if (!t.error) {
            // Give it some time to log quality data
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                IncrementingEventConfig *configuration = self.device.configuration;
                XCTAssertNotNil(configuration);
                XCTAssertTrue(configuration.incrementingCounter.isLogging);
                [[configuration.incrementingCounter downloadLogAndStopLoggingAsync:YES progressHandler:^(float number) {
                    if (number > 0.25) {
                        NSLog(@"Resetting!");
                        [self.device.testDebug resetDevice];
                    }
                }] failure:^(NSError * _Nonnull error) {
                    [waitingExpectation fulfill];
                }];
            });
        } else {
            [waitingExpectation fulfill];
        }
        return nil;
    }];
    [self waitForExpectationsWithTimeout:40 handler:nil];
    
    waitingExpectation = [self expectationWithDescription:@"downloading"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self.device connectAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
            XCTAssertNil(t.error);
            IncrementingEventConfig *configuration = self.device.configuration;
            XCTAssertNotNil(configuration);
            [[configuration.incrementingCounter downloadLogAndStopLoggingAsync:YES] success:^(NSArray<MBLNumericData *> * _Nonnull result) {
                NSLog(@"%@", result);
                int offset = 0;
                for (int i = 1; i <= result.count; i++) {
                    MBLNumericData *obj = result[i - 1];
                    if (obj.value.intValue == 1) {
                        offset = i - 1;
                    }
                    XCTAssertEqual(obj.value.intValue, i - offset);
                }
                [waitingExpectation fulfill];
            }];
            return nil;
        }];
    });
    [self waitForExpectationsWithTimeout:40 handler:nil];
    
    // Now clear all the state
    waitingExpectation = [self expectationWithDescription:@"clear state"];
    [[[self.device connectAsync] continueOnDispatchWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        return [self.device setConfigurationAsync:nil];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        [waitingExpectation fulfill];
        return nil;
    }];
    [self waitForExpectationsWithTimeout:45 handler:nil];
}

- (void)testLogDontAckReadout
{
    // TODO: Don't make this depend on i2c
    CapabilityCheck(self.device.serial);
    CapabilityCheck((self.i2cDevice != 0));
    
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reset"];
    
    const int ENTRIES = 200;
    const float PERIOD = 0.010;
    NSInteger __block sizeFirstReadout = 0;

    MBLI2CData *whoami = [self.device.serial dataAtDeviceAddress:self.i2cDevice registerAddress:self.i2cReadOnlyReg length:1];
    MBLEvent<MBLDataSample *> *periodicReg = [whoami periodicReadWithPeriod:PERIOD * 1000.0 eventCount:ENTRIES];
    [[periodicReg startLoggingAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(((ENTRIES * PERIOD) + 1.0) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.device.logging->noAckMode = YES;
            [[periodicReg downloadLogAndStopLoggingAsync:YES] success:^(NSArray<MBLDataSample *> * _Nonnull result) {
                NSLog(@"%@", result);
                sizeFirstReadout = result.count;
                for (MBLDataSample *entry in result) {
                    XCTAssertEqual(self.i2cReadOnlyRegValue, *(uint8_t *)entry.data.bytes);
                }
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.device.testDebug resetDevice]; // Reset after not ack-ing
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [waitingExpectation fulfill];
                    });
                });
            }];
        });
        return nil;
    }];

    
    [self waitForExpectationsWithTimeout:30 handler:nil];
    
    waitingExpectation = [self expectationWithDescription:@"download"];
    
    [[self.device connectAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        MBLI2CData *whoami = [self.device.serial dataAtDeviceAddress:self.i2cDevice registerAddress:self.i2cReadOnlyReg length:1];
        MBLEvent<MBLDataSample *> *periodicReg = [whoami periodicReadWithPeriod:PERIOD * 1000.0 eventCount:ENTRIES];
        [periodicReg startLoggingAsync];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(((ENTRIES * PERIOD) + 1.0) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.device.logging->noAckMode = NO;
            [[periodicReg downloadLogAndStopLoggingAsync:YES] success:^(NSArray<MBLDataSample *> * _Nonnull result) {
                NSLog(@"%@", result);
                XCTAssertEqual(result.count, (ENTRIES * 2) - sizeFirstReadout);
                for (MBLDataSample *entry in result) {
                    XCTAssertEqual(self.i2cReadOnlyRegValue, *(uint8_t *)entry.data.bytes);
                }
                [waitingExpectation fulfill];
            }];
        });
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:120 handler:nil]; // TODO: Set this timeout down
}

- (void)testLogDownloadAfterReconnect
{
    CapabilityCheck(self.device.temperature.onDieThermistor);

    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"testLogDownloadAfterReconnect"];
    
    [[self.device setConfigurationAsync:[[TempLoggerConfiguration alloc] initWithPeriod:200]] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        [[self.device disconnectAsync] success:^(id result) {
            NSLog(@"Bye Bye");
        }];
        
        // Reconnect after a few seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[self.device connectAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
                XCTAssertNil(t.error);
                TempLoggerConfiguration *configuration = self.device.configuration;
                XCTAssertNotNil(configuration);
                XCTAssertTrue(configuration.periodicTemperature.isLogging);
                [[configuration.periodicTemperature downloadLogAndStopLoggingAsync:YES] success:^(NSArray<MBLNumericData *> * _Nonnull result) {
                    XCTAssertNotEqual(result.count, 0);
                    for (id obj in result) {
                        NSLog(@"Log: %@", obj);
                    }
                    [waitingExpectation fulfill];
                }];
                return nil;
            }];
        });
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:60 handler:nil];
    
    // Now clear all the state
    waitingExpectation = [self expectationWithDescription:@"clear state"];
    [[[self.device connectAsync] continueOnDispatchWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        return [self.device setConfigurationAsync:nil];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        [waitingExpectation fulfill];
        return nil;
    }];
    [self waitForExpectationsWithTimeout:45 handler:nil];
}

- (void)testPeriodicLogDownloadAfterReset
{
    CapabilityCheck(self.device.temperature.onDieThermistor);

    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"testPeriodicLogDownloadAfterReset"];

    const double frequency = 20;
    [[self.device setConfigurationAsync:[[TempLoggerConfiguration alloc] initWithPeriod:1000 / frequency]] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        NSDate *methodStart = [NSDate date];
        XCTAssertNil(t.error);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.device resetDevice];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[self.device connectAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
                    XCTAssertNil(t.error);
                    TempLoggerConfiguration *configuration = self.device.configuration;
                    XCTAssertNotNil(configuration);
                    XCTAssertTrue(configuration.periodicTemperature.isLogging);
                    NSDate *methodFinish = [NSDate date];
                    [[configuration.periodicTemperature downloadLogAndStopLoggingAsync:YES] success:^(NSArray<MBLNumericData *> * _Nonnull result) {
                        NSLog(@"%@", result);
                        BOOL singleZero = NO;
                        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
                        XCTAssertEqualWithAccuracy(result.count, frequency * executionTime, frequency / 2.0);
                        for (MBLNumericData *obj in result) {
                            if (!singleZero && (fabs(obj.value.doubleValue) < DBL_EPSILON)) {
                                singleZero = YES;
                                continue;
                            }
                            XCTAssertEqualWithAccuracy(obj.value.floatValue, 35.0, 20.0);
                        }
                        [waitingExpectation fulfill];
                    }];
                    return nil;
                }];
            });
        });
        return nil;
    }];
    [self waitForExpectationsWithTimeout:60 handler:nil];
    
    // Now clear all the state
    waitingExpectation = [self expectationWithDescription:@"clear state"];
    [[[self.device connectAsync] continueOnDispatchWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        return [self.device setConfigurationAsync:nil];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        [waitingExpectation fulfill];
        return nil;
    }];
    [self waitForExpectationsWithTimeout:45 handler:nil];
}

- (void)testBigStream
{
    MBLBarometerBosch *barometer = (MBLBarometerBosch *)self.device.barometer;
    if ([barometer isKindOfClass:[MBLBarometerBMP280 class]]) {
        ((MBLBarometerBMP280 *)barometer).standbyTime = MBLBarometerBMP280Standby62_5;
    } else if ([barometer isKindOfClass:[MBLBarometerBME280 class]]) {
        ((MBLBarometerBME280 *)barometer).standbyTime = MBLBarometerBME280Standby62_5;
    }
    MBLMagnetometerBMM150 *magnetometer = (MBLMagnetometerBMM150 *)self.device.magnetometer;
    magnetometer.powerPreset = MBLMagnetometerBMM150PresetLowPower;
    self.device.gyro.sampleFrequency = 25;
    MBLAccelerometer *accelerometer = self.device.accelerometer;
    if ([accelerometer isKindOfClass:[MBLAccelerometerBMA255 class]]) {
        accelerometer.sampleFrequency = 31.26;
    } else if ([accelerometer isKindOfClass:[MBLAccelerometerBMI160 class]]) {
        accelerometer.sampleFrequency = 25;
    } else if ([accelerometer isKindOfClass:[MBLAccelerometerMMA8452Q class]]) {
        accelerometer.sampleFrequency = 12.5;
    }
    
    int __block barometerCount = 0;
    int __block magnetometerCount = 0;
    int __block gyroCount = 0;
    int __block accelerometerCount = 0;
    
    NSMutableArray *tasks = [NSMutableArray array];
    if (barometer.periodicAltitude) {
        [tasks addObject:[barometer.periodicAltitude startNotificationsWithHandlerAsync:^(MBLNumericData * _Nullable obj, NSError * _Nullable error) {
            XCTAssertNil(error);
            barometerCount++;
        }]];
    }
    if (magnetometer.periodicMagneticField) {
        [tasks addObject:[magnetometer.periodicMagneticField startNotificationsWithHandlerAsync:^(MBLMagnetometerData * _Nullable obj, NSError * _Nullable error) {
            XCTAssertNil(error);
            magnetometerCount++;
        }]];
    }
    if (self.device.gyro.dataReadyEvent) {
        [tasks addObject:[self.device.gyro.dataReadyEvent startNotificationsWithHandlerAsync:^(MBLGyroData * _Nullable obj, NSError * _Nullable error) {
            XCTAssertNil(error);
            gyroCount++;
        }]];
    }
    if (self.device.accelerometer.dataReadyEvent) {
        [tasks addObject:[self.device.accelerometer.dataReadyEvent startNotificationsWithHandlerAsync:^(MBLAccelerometerData * _Nullable obj, NSError * _Nullable error) {
            XCTAssertNil(error);
            accelerometerCount++;
        }]];
    }
    [[BFTask taskForCompletionOfAllTasks:tasks] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        XCTAssertNil(task.error);
        return nil;
    }];
    
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"checking counts"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSMutableArray *tasks = [NSMutableArray array];
        if (barometer.periodicAltitude) {
            [tasks addObject:[barometer.periodicAltitude stopNotificationsAsync]];
            XCTAssertEqualWithAccuracy(barometerCount, 142, 25);
        }
        if (magnetometer.periodicMagneticField) {
            [tasks addObject:[magnetometer.periodicMagneticField stopNotificationsAsync]];
            XCTAssertEqualWithAccuracy(magnetometerCount, 110, 25);
        }
        if (self.device.gyro.dataReadyEvent) {
            [tasks addObject:[self.device.gyro.dataReadyEvent stopNotificationsAsync]];
            XCTAssertEqualWithAccuracy(gyroCount, 250, 25);
        }
        if (self.device.accelerometer.dataReadyEvent) {
            [tasks addObject:[self.device.accelerometer.dataReadyEvent stopNotificationsAsync]];
            XCTAssertEqualWithAccuracy(accelerometerCount, accelerometer.sampleFrequency * 10, accelerometer.sampleFrequency);
        }
        
        [[BFTask taskForCompletionOfAllTasks:tasks] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull task) {
            XCTAssertNil(task.error);
            [waitingExpectation fulfill];
            return nil;
        }];
    });
    [self waitForExpectationsWithTimeout:50 handler:nil];
}

- (void)testDroppedReadsWhileStreaming
{
    CapabilityCheck(self.device.accelerometer.dataReadyEvent);

    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"Make sure we dont drop reads"];
    
    self.device.accelerometer.sampleFrequency = 400;
    [self.device.accelerometer.dataReadyEvent startNotificationsWithHandlerAsync:^(id obj, NSError *error) {
    }];
    
    int __block count = 0;
    const int expected = 1000;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (int i = 0; i < expected; i++) {
            [self.device.testDebug.keyRegister writeDataAsync:[NSData dataWithBytes:&i length:4]];
            [[self.device.testDebug.keyRegister readAsync] success:^(MBLNumericData *result) {
                XCTAssertEqual(result.value.intValue, i);
                count++;
                if (count == expected) {
                    [waitingExpectation fulfill];
                }
            }];
        }
    });
    
    [self waitForExpectationsWithTimeout:60 handler:nil];
    XCTAssertEqual(count, expected);
    if (count != expected) {
        // Flush out all the droped reads
        [self.device.zeroCountQueue forceResume];
    }
    
    [self.device.accelerometer.dataReadyEvent stopNotificationsAsync];
}

- (void)testI2CReadWrite
{
    CapabilityCheck(self.device.serial);
    CapabilityCheck((self.i2cDevice != 0));

    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];
    
    MBLI2CData<MBLDataSample *> *aReg = [self.device.serial dataAtDeviceAddress:self.i2cDevice registerAddress:self.i2cScratchReg length:1];
    [aReg writeByteAsync:self.i2cScratchRegValue];
    [[aReg readAsync] success:^(MBLDataSample * _Nonnull result) {
        XCTAssertEqual(self.i2cScratchRegValue, *(uint8_t *)result.data.bytes);
        [waitingExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testI2CMultipleReadWrite
{
    CapabilityCheck(self.device.serial);
    CapabilityCheck((self.i2cDevice != 0));
    
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];
    
    MBLI2CData<MBLDataSample *> *whoami = [self.device.serial dataAtDeviceAddress:self.i2cDevice registerAddress:self.i2cReadOnlyReg length:1];
    MBLI2CData<MBLDataSample *> *aReg = [self.device.serial dataAtDeviceAddress:self.i2cDevice registerAddress:self.i2cScratchReg length:1];
    [aReg writeByteAsync:self.i2cScratchRegValue];
    [[aReg readAsync] success:^(MBLDataSample * _Nonnull result) {
        XCTAssertEqual(self.i2cScratchRegValue, *(uint8_t *)result.data.bytes);
    }];
    [[whoami readAsync] success:^(MBLDataSample * _Nonnull result) {
        XCTAssertEqual(self.i2cReadOnlyRegValue, *(uint8_t *)result.data.bytes);
        [waitingExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testI2CPeriodicRead
{
    CapabilityCheck(self.device.serial);
    CapabilityCheck((self.i2cDevice != 0));
    
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"testI2CPeriodicRead"];
    
    MBLI2CData *whoami = [self.device.serial dataAtDeviceAddress:self.i2cDevice registerAddress:self.i2cReadOnlyReg length:1];
    MBLEvent *periodicReg = [whoami periodicReadWithPeriod:1500 eventCount:5];
    int __block notificationCount = 0;
    [periodicReg startNotificationsWithHandlerAsync:^(MBLDataSample *obj, NSError *error) {
        XCTAssertEqual(self.i2cReadOnlyRegValue, *(uint8_t *)obj.data.bytes);
        NSLog(@"%@", obj);
        notificationCount++;
        if (notificationCount == 5) {
            [periodicReg stopNotificationsAsync];
            [waitingExpectation fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:20 handler:nil];
}

- (void)testI2CPeriodicLog
{
    CapabilityCheck(self.device.serial);
    CapabilityCheck((self.i2cDevice != 0));
    
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"testI2CPeriodicLog"];
    
    MBLI2CData *whoami = [self.device.serial dataAtDeviceAddress:self.i2cDevice registerAddress:self.i2cReadOnlyReg length:1];
    MBLEvent<MBLDataSample *> *periodicReg = [whoami periodicReadWithPeriod:1000 eventCount:5];
    [periodicReg startLoggingAsync];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[periodicReg downloadLogAndStopLoggingAsync:YES] success:^(NSArray<MBLDataSample *> * _Nonnull result) {
            for (MBLDataSample *entry in result) {
                XCTAssertEqual(self.i2cReadOnlyRegValue, *(uint8_t *)entry.data.bytes);
                NSLog(@"%@", entry);
            }
            [waitingExpectation fulfill];
        }];
    });
    
    [self waitForExpectationsWithTimeout:2000000000 handler:nil]; // TODO: Set this timeout down
}

- (void)testI2CPeriodicReadIntoFilter
{
    CapabilityCheck(self.device.serial);
    CapabilityCheck((self.i2cDevice != 0));
    
    // TEST CASE: Read sensor once a second, throw out values over 250
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];
    
    MBLI2CData *whoami = [self.device.serial dataAtDeviceAddress:self.i2cDevice registerAddress:self.i2cReadOnlyReg length:1];
    MBLEvent *summedWhoami = [[whoami periodicReadWithPeriod:1000] summationOfEvent];
    int __block notificationCount = 0;
    [summedWhoami startNotificationsWithHandlerAsync:^(MBLDataSample *obj, NSError *error) {
        notificationCount++;
        
        XCTAssertEqual(self.i2cReadOnlyRegValue * notificationCount, *(uint32_t *)obj.data.bytes);
        NSLog(@"%@", obj);
        if (notificationCount == 5) {
            [summedWhoami stopNotificationsAsync];
            [waitingExpectation fulfill];
        }
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}


- (void)testMultiLog
{
    CapabilityCheck(self.device.serial);
    CapabilityCheck((self.i2cDevice != 0));
    
    XCTestExpectation *waiting1 = [self expectationWithDescription:@"wait for reads"];
    XCTestExpectation *waiting2 = [self expectationWithDescription:@"wait for reads"];
    const double frequency = 100.0;
    
    MBLI2CData<MBLDataSample *> *whoami1 = [self.device.serial dataAtDeviceAddress:self.i2cDevice registerAddress:self.i2cReadOnlyReg length:1];
    MBLI2CData<MBLNumericData *> *whoami2 = [self.device.serial numberAtDeviceAddress:self.i2cDevice registerAddress:self.i2cReadOnlyReg length:1 isSigned:NO];
    
    MBLEvent<MBLDataSample *> *periodicReg1 = [whoami1 periodicReadWithPeriod:1000.0 / frequency];
    [periodicReg1 startLoggingAsync];
    
    MBLEvent<MBLNumericData *> *periodicReg2 = [[whoami2 periodicReadWithPeriod:1000.0 / frequency] modifyEventUsingOperation:MBLArithmeticOperationMultiply withData:2];
    [periodicReg2 startLoggingAsync];
    
    NSDate *methodStart = [NSDate date];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSDate *methodFinish = [NSDate date];
        NSTimeInterval executionTime = [methodFinish timeIntervalSinceDate:methodStart];
        [[periodicReg1 downloadLogAndStopLoggingAsync:YES] success:^(NSArray<MBLDataSample *> * _Nonnull result) {
            XCTAssertEqualWithAccuracy(result.count, frequency * executionTime, frequency / 2.0);
            for (MBLDataSample *entry in result) {
                XCTAssertEqual(self.i2cReadOnlyRegValue, *(uint8_t *)entry.data.bytes);
            }
            [waiting1 fulfill];
        }];
        
        [[periodicReg2 downloadLogAndStopLoggingAsync:YES] success:^(NSArray<MBLNumericData *> * _Nonnull result) {
            XCTAssertEqualWithAccuracy(result.count, frequency * executionTime, frequency / 2.0);
            for (MBLNumericData *entry in result) {
                XCTAssertEqual(self.i2cReadOnlyRegValue * 2, entry.value.intValue);
            }
            [waiting2 fulfill];
        }];
    });
    
    [self waitForExpectationsWithTimeout:20 handler:nil];
}

- (void)testProgrammedByOtherAppConnection
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"checking for other app connection"];
    
    uint32_t realKey = self.device.testDebug.magicKey;
    
    XCTAssertFalse(self.device.programedByOtherApp);
    [[self.device disconnectAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (t.error) {
            XCTAssertNil(t.error);
            [waitingExpectation fulfill];
        } else {
            self.device.testDebug.magicKey = 1;
            [[self.device connectAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
                XCTAssertNil(t.error);
                if (!t.error) {
                    XCTAssertTrue(self.device.programedByOtherApp);
                }
                [waitingExpectation fulfill];
                return nil;
            }];
        }
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:60 handler:nil];
    
    // Perform cleanup
    self.device.testDebug.magicKey = realKey;
}

- (void)testFilterFromOffsetedEntry
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"filter tests"];
    
    MBLAccelerometerMMA8452QFormat *format = [[MBLAccelerometerMMA8452QFormat alloc] initWithAxis:MBLAccelerometerAxisZ];
    MBLEvent *spoof = [self.device.testDebug spoofEvent:format];
    
    MBLEvent *event1 = [spoof conditionalDataSwitch:YES];
    MBLEvent *event2 = [spoof countingDataSwitch:1];
    MBLEvent *event3 = [spoof summationOfEvent];
    MBLEvent *event4 = [spoof counterOfEvent];
    MBLEvent *event5 = [spoof averageOfEventWithDepth:2];
    MBLEvent *event6 = [spoof compareEventUsingOperation:MBLComparisonOperationLessThan data:@[@0.0] output:MBLComparisonOutputValue];
    MBLEvent *event7 = [spoof periodicSampleOfEvent:50];
    MBLEvent *event8 = [spoof differentialSampleOfEvent:50];
    MBLEvent *event9 = [spoof delayOfEventWithCount:1];
    MBLEvent *event10 = [spoof pulseDetectorOfEventWithThreshold:-0.5 width:1 output:MBLPulseOutputPeak];
    MBLEvent *event11 = [spoof changeOfEventByDelta:0.5 output:MBLDeltaValueOutputAbsolute];
    MBLEvent *event12 = [spoof changeOfEventAcrossThreshold:-0.5 hysteresis:0.1 output:MBLThresholdValueOutputAbsolute];
    
    __block BOOL first = YES;
    
    [event1 startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        if (first) {
            XCTAssertEqualWithAccuracy(obj.value.doubleValue, -0.997, 0.001);
        } else {
            XCTAssertEqualWithAccuracy(obj.value.doubleValue, 0.097, 0.001);
        }
    }];
    [event2 startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        if (first) {
            XCTAssertEqualWithAccuracy(obj.value.doubleValue, -0.997, 0.001);
        } else {
            XCTFail("Counting switch shouldn't get second value");
        }
    }];
    [event3 startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        if (first) {
             XCTAssertEqualWithAccuracy(obj.value.doubleValue, -0.997, 0.001);
        } else {
            XCTAssertEqualWithAccuracy(obj.value.doubleValue, -0.9, 0.001);
        }
    }];
    [event4 startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        if (first) {
            XCTAssertEqual(obj.value.intValue, 1);
        } else {
            XCTAssertEqual(obj.value.intValue, 2);
        }
    }];
    [event5 startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        if (first) {
            XCTFail("Average filter shouldn't get first value");
        } else {
            XCTAssertEqualWithAccuracy(obj.value.doubleValue, -0.45, 0.001);
        }
    }];
    [event6 startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        if (first) {
            XCTAssertEqualWithAccuracy(obj.value.doubleValue, -0.997, 0.001);
        } else {
            XCTFail("Compare switch shouldn't get second value");
        }
    }];
    [event7 startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        if (first) {
            XCTAssertEqualWithAccuracy(obj.value.doubleValue, -0.997, 0.001);
        } else {
            XCTAssertEqualWithAccuracy(obj.value.doubleValue, 0.097, 0.001);
        }
    }];
    [event8 startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        if (first) {
            XCTAssertEqualWithAccuracy(obj.value.doubleValue, -0.997, 0.001);
        } else {
            XCTAssertEqualWithAccuracy(obj.value.doubleValue, 1.094, 0.001);
        }
    }];
    [event9 startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        if (first) {
            XCTFail("Delay filter shouldn't get first value");
        } else {
            XCTAssertEqualWithAccuracy(obj.value.doubleValue, -0.997, 0.001);
        }
    }];
    [event10 startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        XCTFail("Pulse detector shouldn't get any values");
    }];
    [event11 startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        if (first) {
            XCTAssertEqualWithAccuracy(obj.value.doubleValue, -0.997, 0.001);
        } else {
            XCTAssertEqualWithAccuracy(obj.value.doubleValue, 0.097, 0.001);
        }
    }];
    [event12 startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        if (first) {
            XCTFail("Threshold filter shouldn't get first value");
        } else {
            XCTAssertEqualWithAccuracy(obj.value.doubleValue, 0.097, 0.001);
        }
    }];
    
    [[self.device waitForCommandCompletion] success:^(id result) {
        [self.device.testDebug spoofData:@[@"61-00-D8-FF-1B-FC"]
                            notification:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            first = NO;
            [self.device.testDebug spoofData:@[@"1B-FC-D8-FF-61-00"]
                                notification:NO];
        });
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [event1 stopNotificationsAsync];
        [event2 stopNotificationsAsync];
        [event3 stopNotificationsAsync];
        [event4 stopNotificationsAsync];
        [event5 stopNotificationsAsync];
        [event6 stopNotificationsAsync];
        [event7 stopNotificationsAsync];
        [event8 stopNotificationsAsync];
        [event9 stopNotificationsAsync];
        [event10 stopNotificationsAsync];
        [event11 stopNotificationsAsync];
        [event12 stopNotificationsAsync];
        [waitingExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:60 handler:nil];
}



- (void)testConditionalDataSwitch
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];
    
    MBLEvent *spoof = [self.device.testDebug spoofEvent:self.device.temperature.onDieThermistor.format];
    MBLDataSwitch *spoofSwitch = [spoof conditionalDataSwitch:NO];
    float __block expected = 25.5;
    int __block count = -1;
    [spoofSwitch startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        XCTAssertNil(error);
        XCTAssertNotEqual(count, -1, @"Expected switch to filter all data");
        XCTAssertEqualWithAccuracy(obj.value.floatValue, expected, 0.1);
        count++;
        expected += 1.0;
        if (count == 7) {
            [spoofSwitch stopNotificationsAsync];
            [waitingExpectation fulfill];
        }
    }];
    [[self.device waitForCommandCompletion] success:^(id result) {
        [self.device.testDebug spoofData:@[@"CC-00",
                                           @"D4-00",
                                           @"DC-00",
                                           @"E4-00",
                                           @"EC-00",
                                           @"F4-00",
                                           @"FC-00"]
                            notification:NO];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        count = 0;
        [spoofSwitch resetConditionalAsync:YES];
        [self.device.testDebug spoofData:@[@"CC-00",
                                           @"D4-00",
                                           @"DC-00",
                                           @"E4-00",
                                           @"EC-00",
                                           @"F4-00",
                                           @"FC-00"]
                            notification:NO];
    });
    
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

- (void)testChangeOfEventByDelta
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];
    
    MBLEvent *spoof = [self.device.testDebug spoofEvent:self.device.temperature.onDieThermistor.format];
    spoof = [spoof changeOfEventByDelta:2.2 output:MBLDeltaValueOutputAbsolute];
    float __block expected = 25.5;
    int __block count = 0;
    [spoof startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        XCTAssertNil(error);
        XCTAssertEqualWithAccuracy(obj.value.floatValue, expected, 0.1);
        count++;
        expected += 3.0;
        if (count == 3) {
            [spoof stopNotificationsAsync];
            [waitingExpectation fulfill];
        }
    }];
    
    [[self.device waitForCommandCompletion] success:^(id result) {
        [self.device.testDebug spoofData:@[@"CC-00",
                                           @"D4-00",
                                           @"DC-00",
                                           @"E4-00",
                                           @"EC-00",
                                           @"F4-00",
                                           @"FC-00",
                                           @"FF-00"]
                            notification:NO];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testChangeOfEventAcrossThreshold
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];
    
    MBLEvent *spoof = [self.device.testDebug spoofEvent:self.device.temperature.onDieThermistor.format];
    spoof = [spoof changeOfEventAcrossThreshold:28.0 hysteresis:2.2 output:MBLThresholdValueOutputAbsolute];
    int __block count = 0;
    [spoof startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        XCTAssertEqualWithAccuracy(obj.value.floatValue, 28.5, 0.1);
        count++;
    }];
    
    [[self.device waitForCommandCompletion] success:^(id result) {
        [self.device.testDebug spoofData:@[@"CC-00",
                                           @"D4-00",
                                           @"DC-00",
                                           @"E4-00",
                                           @"DC-00",
                                           @"E4-00"]
                            notification:NO];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertEqual(count, 1);
        [[spoof stopNotificationsAsync] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
            [waitingExpectation fulfill];
            return task;
        }];
    });
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testPulseDetectorOfEventWithThreshold
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];
    
    MBLEvent *spoof = [self.device.testDebug spoofEvent:self.device.temperature.onDieThermistor.format];
    spoof = [spoof pulseDetectorOfEventWithThreshold:-62.0 width:3 output:MBLPulseOutputArea];
    int __block count = 0;
    [spoof startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        XCTAssertEqualWithAccuracy(obj.value.floatValue, -183.25, 0.1);
        count++;
    }];
    
    [[self.device waitForCommandCompletion] success:^(id result) {
        [self.device.testDebug spoofData:@[@"01-FE", // -63.9
                                           @"06-FE", // -63.3
                                           @"13-FE", // -61.7
                                           @"1C-FE", // -60.6
                                           @"17-FE", // -61.1
                                           @"FC-FD"] // -64.4
                            notification:NO];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertEqual(count, 1);
        [spoof stopNotificationsAsync];
        [waitingExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testCounterOfEvents
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];
    
    MBLEvent *spoof = [self.device.testDebug spoofEvent:self.device.temperature.onDieThermistor.format];
    spoof = [spoof counterOfEvent];
    int __block count = 0;
    [spoof startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        count++;
        XCTAssertEqual(count, obj.value.intValue);
    }];
    
    [[self.device waitForCommandCompletion] success:^(id result) {
        [self.device.testDebug spoofData:@[@"01-FE", // -63.9
                                           @"06-FE", // -63.3
                                           @"13-FE", // -61.7
                                           @"1C-FE", // -60.6
                                           @"17-FE", // -61.1
                                           @"FC-FD"] // -64.4
                            notification:NO];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        XCTAssertEqual(count, 6);
        [spoof stopNotificationsAsync];
        [waitingExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testModifyEventUsingOperation
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"testModifyEventUsingOperation"];
    
    MBLEvent<MBLNumericData *> *temp = [self.device.temperature.onDieThermistor periodicReadWithPeriod:500];
    MBLFilter<MBLNumericData *> *doubleTemp = [temp modifyEventUsingOperation:MBLArithmeticOperationMultiply withData:2];
    MBLFilter<MBLNumericData *> *halfTemp = [temp modifyEventUsingOperation:MBLArithmeticOperationDivide withData:2];
    MBLFilter<MBLNumericData *> *fiftyLessTemp = [temp modifyEventUsingOperation:MBLArithmeticOperationSubtract withData:50.0];
    MBLFilter<MBLNumericData *> *absTemp = [fiftyLessTemp modifyEventUsingOperation:MBLArithmeticOperationAbsoluteValue withData:0];
    
    double __block actualTemp = 0.0;
    [temp startNotificationsWithHandlerAsync:^(MBLNumericData * _Nullable obj, NSError * _Nullable error) {
        XCTAssertNil(error);
        actualTemp = obj.value.doubleValue;
        [temp stopNotificationsAsync];
    }];
    [doubleTemp startNotificationsWithHandlerAsync:^(MBLNumericData *  _Nullable obj, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertEqualWithAccuracy(actualTemp * 2.0, obj.value.doubleValue, 0.1);
        [doubleTemp stopNotificationsAsync];
    }];
    [halfTemp startNotificationsWithHandlerAsync:^(MBLNumericData *  _Nullable obj, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertEqualWithAccuracy(actualTemp / 2.0, obj.value.doubleValue, 0.1);
        [halfTemp stopNotificationsAsync];
    }];
    [fiftyLessTemp startNotificationsWithHandlerAsync:^(MBLNumericData *  _Nullable obj, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertEqualWithAccuracy(actualTemp - 50.0, obj.value.doubleValue, 0.1);
        [fiftyLessTemp stopNotificationsAsync];
    }];
    [absTemp startNotificationsWithHandlerAsync:^(MBLNumericData *  _Nullable obj, NSError * _Nullable error) {
        XCTAssertNil(error);
        XCTAssertEqualWithAccuracy(fabs(actualTemp - 50.0), obj.value.doubleValue, 0.1);
        [absTemp stopNotificationsAsync];
        [waitingExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}


- (void)testProximity
{
    CapabilityCheck(self.device.proximity);
    
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];

    MBLProximityTSL2671 *proximity = (MBLProximityTSL2671 *)self.device.proximity;
    MBLEvent *event = [proximity.proximity periodicReadWithPeriod:500];
    int __block count = 0;
    [event startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        // Somewhere in the [0, 1024] range by default
        XCTAssertEqualWithAccuracy(obj.value.doubleValue, 512, 512);
        count++;
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [event stopNotificationsAsync];
        // 5 seconds @2Hz gives us 10 samples
        XCTAssertEqualWithAccuracy(count, 10, 2);
        [waitingExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testHumidityRead
{
    CapabilityCheck(self.device.hygrometer);
    
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];

    MBLHygrometerBME280 *hygrometer = (MBLHygrometerBME280 *)self.device.hygrometer;
    MBLEvent *event = [hygrometer.humidity periodicReadWithPeriod:500];
    int __block count = 0;
    [event startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        // Somewhere in the [20, 90] for indoor humidity i'd assume?
        XCTAssertEqualWithAccuracy(obj.value.doubleValue, 55, 35);
        count++;
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [event stopNotificationsAsync];
        // 5 seconds @2Hz gives us 10 samples
        XCTAssertEqualWithAccuracy(count, 10, 2);
        [waitingExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testHumidityPeriodicRead
{
    CapabilityCheck(self.device.hygrometer);
    
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];
    
    MBLHygrometerBME280 *hygrometer = (MBLHygrometerBME280 *)self.device.hygrometer;
    hygrometer.humidityOversampling = MBLHygrometerBME280Oversample16X;
    int __block count = 0;
    [hygrometer.periodicHumidity startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        // Somewhere in the [20, 90] for indoor humidity i'd assume?
        XCTAssertEqualWithAccuracy(obj.value.doubleValue, 55, 35);
        count++;
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [hygrometer.periodicHumidity stopNotificationsAsync];
        hygrometer.humidityOversampling = MBLHygrometerBME280Oversample1X;

        XCTAssertEqualWithAccuracy(count, 122, 20); // Based on the barometer default tStandby
        [waitingExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testPressurePeriodicRead
{
    CapabilityCheck(self.device.barometer);
    
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];

    MBLBarometerBosch *barometer = (MBLBarometerBosch *)self.device.barometer;
    int __block count = 0;
    [barometer.periodicPressure startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        // A first guess at typical atmosphere pressure
        XCTAssertEqualWithAccuracy(obj.value.doubleValue, 101374.296875, 3000.0);
        count++;
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [barometer.periodicPressure stopNotificationsAsync];
        
        XCTAssertEqualWithAccuracy(count, 10, 2); // Based on the default settings
        [waitingExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testAltitudePeriodicRead
{
    CapabilityCheck(self.device.barometer);

    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];
    
    MBLBarometerBosch *barometer = (MBLBarometerBosch *)self.device.barometer;
    int __block count = 0;
    [barometer.periodicAltitude startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        // We usually test around sea level +-500m
        XCTAssertEqualWithAccuracy(obj.value.doubleValue, 0, 500);
        count++;
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [barometer.periodicAltitude stopNotificationsAsync];
        
        XCTAssertEqualWithAccuracy(count, 10, 2); // Based on the default settings
        [waitingExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testPhotometerPeriodicRead
{
    CapabilityCheck(self.device.photometer);

    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];
    
    MBLPhotometerTCS3472 *photometer = (MBLPhotometerTCS3472 *)self.device.photometer;
    photometer.gain = MBLPhotometerTCS3472Gain1X;
    photometer.integrationTime = 50.0;
    photometer.ledFlash = YES;
    MBLEvent<MBLRGBData *> *event = [photometer.color periodicReadWithPeriod:500];
    int __block count = 0;
    [event startNotificationsWithHandlerAsync:^(MBLRGBData * _Nullable obj, NSError * _Nullable error) {
        // Somewhere in the 100 range for these settings
        XCTAssertEqualWithAccuracy(obj.red, 100, 100);
        XCTAssertEqualWithAccuracy(obj.green, 100, 100);
        XCTAssertEqualWithAccuracy(obj.blue, 100, 100);
        XCTAssertEqualWithAccuracy(obj.clear, 100, 100);
        count++;
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [event stopNotificationsAsync];
        XCTAssertEqualWithAccuracy(count, 10, 2);
        [waitingExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testPhotometerRead
{
    CapabilityCheck(self.device.photometer);

    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];
    
    MBLPhotometerTCS3472 *photometer = (MBLPhotometerTCS3472 *)self.device.photometer;
    photometer.gain = MBLPhotometerTCS3472Gain1X;
    photometer.integrationTime = 50.0;
    photometer.ledFlash = NO;
    
    NSMutableArray *tasks = [NSMutableArray array];
    [tasks addObject:[photometer.color readAsync]];
    [tasks addObject:[photometer.redColor readAsync]];
    [tasks addObject:[photometer.greenColor readAsync]];
    [tasks addObject:[photometer.blueColor readAsync]];
    [tasks addObject:[photometer.clearColor readAsync]];
    
    [[BFTask taskForCompletionOfAllTasksWithResults:tasks] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        XCTAssertNil(task.error);
        NSLog(@"%@", task.result);
        [waitingExpectation fulfill];
        return nil;
    }];
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testBMA255
{
    CapabilityCheck([self.device.accelerometer isKindOfClass:[MBLAccelerometerBMA255 class]]);

    MBLAccelerometerBMA255 *accelerometer = (MBLAccelerometerBMA255 *)self.device.accelerometer;
    accelerometer.sampleFrequency = 15;
    [self eventUpdateTest:accelerometer.dataReadyEvent time:5 frequency:15.62];
    accelerometer.sampleFrequency = 20;
    [self eventUpdateTest:accelerometer.dataReadyEvent time:5 frequency:31.26];
    accelerometer.sampleFrequency = 60;
    [self eventUpdateTest:accelerometer.dataReadyEvent time:5 frequency:62.5];
    accelerometer.sampleFrequency = 125;
    [self eventUpdateTest:accelerometer.dataReadyEvent time:5 frequency:125];
    accelerometer.sampleFrequency = 125.1;
    [self eventUpdateTest:accelerometer.dataReadyEvent time:5 frequency:250];
}

- (void)testMagnetometerBMM150
{
    CapabilityCheck([self.device.magnetometer isKindOfClass:[MBLMagnetometerBMM150 class]]);
    
    MBLMagnetometerBMM150 *magnetometer = (MBLMagnetometerBMM150 *)self.device.magnetometer;
    magnetometer.powerPreset = MBLMagnetometerBMM150PresetRegular;
    [self eventUpdateTest:magnetometer.periodicMagneticField time:5 frequency:10.0];
    magnetometer.powerPreset = MBLMagnetometerBMM150PresetHighAccuracy;
    [self eventUpdateTest:magnetometer.periodicMagneticField time:5 frequency:20.0];
}

- (void)testSPIRead
{
    CapabilityCheck(self.device.serial);
    CapabilityCheck([self.device.accelerometer isKindOfClass:[MBLAccelerometerBMI160 class]]);
    
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];

    // def spi_pack_cmdstring(self, ss, sck, mosi, miso, native, lsb_first, mode, freq):
    // cmdstr = "0d-82-" + self.spi_pack_cmdstring(10, 0, 11, 7, 1, 0, 3, 6) + "04-da"
    MBLSPIData *bmi160 = [self.device.serial dataWithSlaveSelectPin:10 clockPin:0 mosiPin:11 misoPin:7 lsbFirst:0 spiMode:3 spiFrequency:6 nativePinIndexing:1 length:5];

    uint8_t byte = 0xDA;
    [[[bmi160 readWithParamtersAsync:[NSData dataWithBytes:&byte length:1]] success:^(MBLDataSample *result) {
        uint8_t data[] = { 0x07, 0x30, 0x81, 0x0b, 0xc0 };
        int dataSize = sizeof(data) / sizeof(data[0]);
        NSData *expected = [NSData dataWithBytes:data length:dataSize];
        XCTAssertTrue([result.data isEqualToData:expected]);
        [waitingExpectation fulfill];
    }] failure:^(NSError * error) {
        XCTAssertNil(error);
        [waitingExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];

}

- (void)testPackedAccelStream
{
    CapabilityCheck(self.device.accelerometer.dataReadyEvent);

    self.device.accelerometer.sampleFrequency = [self accelerometerFrequencyNear:400];
    [self eventUpdateTest:self.device.accelerometer.packedDataReadyEvent time:10 frequency:self.device.accelerometer.sampleFrequency];
}

- (void)testPackedGyroStream
{
    CapabilityCheck(self.device.gyro.dataReadyEvent);
    
    self.device.gyro.sampleFrequency = 400;
    [self eventUpdateTest:self.device.gyro.packedDataReadyEvent time:10 frequency:self.device.gyro.sampleFrequency];
}

- (void)testSensorFusion
{
    CapabilityCheck(self.device.sensorFusion);

    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"testSensorFusion"];
    
    self.device.sensorFusion.mode = MBLSensorFusionModeNDoF;
    
    int __block count = 0;
    double sampleFrequency = 100.0;
    [self.device.sensorFusion.gravity startNotificationsWithHandlerAsync:^(MBLAccelerometerData *obj, NSError *error) {
        XCTAssertEqualWithAccuracy(obj.RSS, 1.0, 0.1);
        count++;
    }];
    [self.device.sensorFusion.linearAcceleration startNotificationsWithHandlerAsync:^(MBLAccelerometerData *obj, NSError *error) {
        XCTAssertLessThan(obj.RSS, 0.1);
        count++;
    }];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.device.sensorFusion.gravity stopNotificationsAsync];
        // Check for 2 seconds worth of updates
        XCTAssertEqualWithAccuracy(count, sampleFrequency * 2.0 * 2.0, sampleFrequency);
        [waitingExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testSensorFusionErrors
{
    CapabilityCheck(self.device.sensorFusion);
    
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"testSensorFusion"];
    
    self.device.sensorFusion.mode = MBLSensorFusionModeM4G;
    [[[[[[[self.device.sensorFusion.rotation startNotificationsWithHandlerAsync:^(MBLDataSample * _Nullable obj, NSError * _Nullable error) {
        XCTFail("Shouldn't get any samples in invalid config");
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        return [self.device.sensorFusion.rotation stopNotificationsAsync];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        self.device.sensorFusion.mode = MBLSensorFusionModeCompass;
        return [self.device.sensorFusion.rotation startNotificationsWithHandlerAsync:^(MBLDataSample * _Nullable obj, NSError * _Nullable error) {
            XCTFail("Shouldn't get any samples in invalid config");
        }];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        return [self.device.sensorFusion.rotation stopNotificationsAsync];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        self.device.sensorFusion.mode = MBLSensorFusionModeIMUPlus;
        return [self.device.sensorFusion.magneticField startNotificationsWithHandlerAsync:^(MBLDataSample * _Nullable obj, NSError * _Nullable error) {
            XCTFail("Shouldn't get any samples in invalid config");
        }];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        return [self.device.sensorFusion.magneticField stopNotificationsAsync];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        [waitingExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:10 handler:nil];
}

@end
