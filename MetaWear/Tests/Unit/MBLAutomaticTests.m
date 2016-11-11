/**
 * MBLAutomaticTests.m
 * MetaWearUnitTests
 *
 * Created by Stephen Schiffli on 5/5/15.
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

#import "MBLMockMetaWearUnitTest.h"

@interface MBLAutomaticTests : MBLMockMetaWearUnitTest

@end

@implementation MBLAutomaticTests

- (void)testSwitchRead
{
    XCTestExpectation *read1 = [self expectationWithDescription:@"wait for switch read1"];
    XCTestExpectation *read2 = [self expectationWithDescription:@"wait for switch read2"];

    [[self.device.mechanicalSwitch.switchValue readAsync] success:^(MBLNumericData * _Nonnull result) {
        XCTAssertEqual(result.value.boolValue, NO);
        [read1 fulfill];
    }];
    
    [[self.device.mechanicalSwitch.switchValue readAsync] success:^(MBLNumericData * _Nonnull result) {
        XCTAssertEqual(result.value.boolValue, YES);
        [read2 fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
}

- (void)testSerialI2C
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for serial reads"];
    
    MBLI2CData<MBLDataSample *> *reg = [self.device.serial dataAtDeviceAddress:0x1C registerAddress:0x12 length:1];
    [[[[reg writeByteAsync:0x54] continueOnDispatchWithSuccessBlock:^id (BFTask *task) {
        return [reg readAsync];
    }] continueOnDispatchWithSuccessBlock:^id (BFTask *task) {
        MBLDataSample *result = task.result;
        uint8_t val = 0x54;
        XCTAssertTrue([result.data isEqualToData:[NSData dataWithBytes:&val length:1]]);
        return nil;
    }] continueOnDispatchWithBlock:^id (BFTask *task) {
        XCTAssertNil(task.error);
        [waitingExpectation fulfill];
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}


- (void)testBarometerAltitude
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for barometer reads"];
    
    [[[[self.device.barometer.altitude readAsync] continueOnDispatchWithSuccessBlock:^id (BFTask *task) {
        MBLNumericData *result = task.result;
        XCTAssertEqualWithAccuracy(result.value.floatValue, 1000.0, 0.1);
        return [self.device.barometer.altitude readAsync];
    }] continueOnDispatchWithSuccessBlock:^id (BFTask *task) {
        MBLNumericData *result = task.result;
        XCTAssertEqualWithAccuracy(result.value.floatValue, -1000.0, 0.1);
        return nil;
    }] continueOnDispatchWithBlock:^id (BFTask *task) {
        XCTAssertNil(task.error);
        [waitingExpectation fulfill];
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testBarometerPressure
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for barometer reads"];
    
    [[[[self.device.barometer.pressure readAsync] continueOnDispatchWithSuccessBlock:^id (BFTask *task) {
        MBLNumericData *result = task.result;
        XCTAssertEqualWithAccuracy(result.value.floatValue, 1000.0, 0.1);
        return [self.device.barometer.pressure readAsync];
    }] continueOnDispatchWithSuccessBlock:^id (BFTask *task) {
        MBLNumericData *result = task.result;
        XCTAssertEqualWithAccuracy(result.value.floatValue, 16776216.0, 0.1);
        return nil;
    }] continueOnDispatchWithBlock:^id (BFTask *task) {
        XCTAssertNil(task.error);
        [waitingExpectation fulfill];
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testNotifications
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for notifications"];
    
    int __block count = 0;
    MBLEvent *event = self.device.mechanicalSwitch.switchUpdateEvent;
    [[event startNotificationsWithHandlerAsync:^(MBLNumericData *obj, NSError *error) {
        XCTAssertEqual(obj.value.boolValue, count % 2);
        XCTAssertLessThan(count, 4);
        if (++count == 4) {
            [[event stopNotificationsAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask *task) {
                XCTAssertNil(task.error);
                // Wait a sec to make sure notifications stop
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [waitingExpectation fulfill];
                });
                return nil;
            }];
        }
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask *task) {
        XCTAssertNil(task.error);
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testNotificationsExecutor
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for notifications"];
    
    int __block count = 0;
    BFExecutor *executor = [BFExecutor executorWithDispatchQueue:[MBLMockMetaWearUnitTest randomQueue1]];
    MBLEvent *event = self.device.mechanicalSwitch.switchUpdateEvent;
    [[event startNotificationsWithExecutorAsync:executor withHandler:^(MBLNumericData *obj, NSError *error) {
        XCTAssertTrue([MBLMockMetaWearUnitTest isRandomQueue1]);
        XCTAssertEqual(obj.value.boolValue, count % 2);
        XCTAssertLessThan(count, 4);
        if (++count == 4) {
            [[event stopNotificationsAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask *task) {
                XCTAssertNil(task.error);
                // Wait a sec to make sure notifications stop
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [waitingExpectation fulfill];
                });
                return nil;
            }];
        }
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask *task) {
        XCTAssertNil(task.error);
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testChangeDispatchQueueNotifications
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for notifications"];
    
    NSOperationQueue *queue1 = [[NSOperationQueue alloc] init];
    queue1.underlyingQueue = [MBLMockMetaWearUnitTest randomQueue1];
    
    NSOperationQueue *queue2 = [[NSOperationQueue alloc] init];
    queue2.underlyingQueue = [MBLMockMetaWearUnitTest randomQueue2];
    
    // Start in queue 1
    [MBLMetaWearManager sharedManager].dispatchQueue = queue1;
    int __block count = 0;
    MBLEvent<MBLNumericData *> *event = self.device.mechanicalSwitch.switchUpdateEvent;
    [event startNotificationsWithHandlerAsync:^(MBLNumericData * _Nullable obj, NSError * _Nullable error) {
        XCTAssertEqual(obj.value.boolValue, count % 2);
        count++;
        if (count <= 4) {
            XCTAssertTrue([MBLMockMetaWearUnitTest isRandomQueue1]);
        } else {
            XCTAssertTrue([MBLMockMetaWearUnitTest isRandomQueue2]);
        }
        if (count == 4) {
            [MBLMetaWearManager sharedManager].dispatchQueue = queue2;
        }
        if (count == 8) {
            [[event stopNotificationsAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask *task) {
                XCTAssertNil(task.error);
                // Wait a sec to make sure notifications stop
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [waitingExpectation fulfill];
                });
                return nil;
            }];
        }
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testHaptic
{
    XCTestExpectation *hapticCompletion = [self expectationWithDescription:@"hapticCompletion"];
    XCTestExpectation *hapticFired = [self expectationWithDescription:@"hapticFired"];
    XCTestExpectation *buzzerCompletion = [self expectationWithDescription:@"buzzerCompletion"];
    XCTestExpectation *buzzerFired = [self expectationWithDescription:@"buzzerFired"];
    
    const uint16_t pwidth = 230;
    const uint16_t dcycle = 54;
    
    MBLHapticHandler x = ^(uint8_t dutyCycle, uint16_t pulseWidth) {
        XCTAssertEqual(pulseWidth, pwidth);
        XCTAssertEqual(dutyCycle, dcycle);
        [hapticFired fulfill];
    };
    MBLBuzzerHandler y = ^(uint8_t dutyCycle, uint16_t pulseWidth) {
        XCTAssertEqual(pulseWidth, pwidth);
        [buzzerFired fulfill];
    };
    
    self.peripheral.hapticHandler = x;
    self.peripheral.buzzerHandler = y;
    
    [[self.device.hapticBuzzer startBuzzerWithPulseWidthAsync:pwidth completion:^{
        NSLog(@"Complete");
        [buzzerCompletion fulfill];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [self.device.hapticBuzzer startHapticWithDutyCycleAsync:dcycle pulseWidth:pwidth completion:^{
            NSLog(@"Complete");
            [hapticCompletion fulfill];
        }];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testGPIO
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];
    
    MBLGPIOPin *pin = self.device.gpio.pins[0];
    [[[[[[[[[[[[[[[[[[pin setToDigitalValueAsync:NO] continueOnDispatchWithSuccessBlock:^id (BFTask *task) {
        return [pin setToDigitalValueAsync:YES];
    }] continueOnDispatchWithSuccessBlock:^id (BFTask *task) {
        return [pin.digitalValue readAsync];
    }] continueOnDispatchWithSuccessBlock:^id (BFTask *task) {
        MBLNumericData *result = task.result;
        XCTAssertEqual(result.value.boolValue, YES);
        return [pin setToDigitalValueAsync:YES];
    }] continueOnDispatchWithSuccessBlock:^id (BFTask *task) {
        return [pin setToDigitalValueAsync:NO];
    }] continueOnDispatchWithSuccessBlock:^id (BFTask *task) {
        return [pin.digitalValue readAsync];
    }] continueOnDispatchWithSuccessBlock:^id (BFTask *task) {
        MBLNumericData *result = task.result;
        XCTAssertEqual(result.value.boolValue, NO);
        return [pin setConfiguration:MBLPinConfigurationPulldown];
    }] continueOnDispatchWithSuccessBlock:^id (BFTask *task) {
        return [pin setConfiguration:MBLPinConfigurationPullup];
    }] continueOnDispatchWithSuccessBlock:^id (BFTask *task) {
        return [pin.digitalValue readAsync];
    }] continueOnDispatchWithSuccessBlock:^id (BFTask *task) {
        MBLNumericData *result = task.result;
        XCTAssertEqual(result.value.boolValue, YES);
        return [pin.analogRatio readAsync];
    }] continueOnDispatchWithSuccessBlock:^id (BFTask *task) {
        MBLNumericData *result = task.result;
        XCTAssertEqualWithAccuracy(result.value.floatValue, 0.976540, 0.25);
        return [pin.analogAbsolute readAsync];
    }] continueOnDispatchWithSuccessBlock:^id (BFTask *task) {
        MBLNumericData *result = task.result;
        XCTAssertEqualWithAccuracy(result.value.floatValue, 2.956000, 0.25);
        return [pin setConfiguration:MBLPinConfigurationPullup];
    }] continueOnDispatchWithSuccessBlock:^id (BFTask *task) {
        return [pin setConfiguration:MBLPinConfigurationPulldown];
    }] continueOnDispatchWithSuccessBlock:^id (BFTask *task) {
        return [pin.digitalValue readAsync];
    }] continueOnDispatchWithSuccessBlock:^id (BFTask *task) {
        MBLNumericData *result = task.result;
        XCTAssertEqual(result.value.boolValue, NO);
        return [pin.analogRatio readAsync];
    }] continueOnDispatchWithSuccessBlock:^id (BFTask *task) {
        MBLNumericData *result = task.result;
        XCTAssertEqualWithAccuracy(result.value.floatValue, 0.006843, 0.25);
        return [pin.analogAbsolute readAsync];
    }] continueOnDispatchWithSuccessBlock:^id (BFTask *task) {
        MBLNumericData *result = task.result;
        XCTAssertEqualWithAccuracy(result.value.floatValue, 0.024000, 0.25);
        return nil;
    }] continueOnDispatchWithBlock:^id (BFTask *task) {
        XCTAssertNil(task.error);
        [waitingExpectation fulfill];
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testLED
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];
    
    [[self.device.led flashLEDColorAsync:[MBLColor whiteColor] withIntensity:1.0 numberOfFlashes:1] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        return nil;
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [waitingExpectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testTemp
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for readings"];
    
    [[[[BFTask taskFromMetaWearWithBlock:^id{
        return [[self.device.temperature.onDieThermistor readAsync] success:^(MBLNumericData * _Nonnull result) {
            XCTAssertEqualWithAccuracy(result.value.floatValue, 35.0, 20.0);
        }];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        self.device.temperature.externalThermistor.readPin = 0;
        self.device.temperature.externalThermistor.enablePin = 1;
        return [[self.device.temperature.externalThermistor readAsync] success:^(MBLNumericData * _Nonnull result) {
            XCTAssertEqualWithAccuracy(result.value.floatValue, 23.8889, 8.3333);
        }];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [[self.device.temperature.onboardThermistor readAsync] success:^(MBLNumericData * _Nonnull result) {
            XCTAssertEqualWithAccuracy(result.value.floatValue, 35.0, 20.0);
        }];
    }] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        XCTAssertFalse(task.faulted);
        [waitingExpectation fulfill];
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
