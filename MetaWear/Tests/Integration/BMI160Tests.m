/**
 * BMI160Tests.m
 * MetaWearTests
 *
 * Created by Stephen Schiffli on 5/26/15.
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
#import "MBLAccelerometerBMI160+Private.h"
#import "MBLGyroBMI160+Private.h"
#import "MBLAccelerometerBoschDataReadyEvent.h"

@interface BMI160Tests : MetaWearTest
@property (nonatomic, retain) MBLAccelerometerBMI160 *accelerometer;
@property (nonatomic, retain) MBLGyroBMI160 *gyro;
@end

@implementation BMI160Tests

- (void)setUp
{
    [super setUp];
    
    if (![self.device.accelerometer isKindOfClass:[MBLAccelerometerBMI160 class]]) {
        self.continueAfterFailure = NO;
        XCTFail("Trying to run BMI160 tests on a board without a BMI160 accelerometer");
    }
    if (![self.device.gyro isKindOfClass:[MBLGyroBMI160 class]]) {
        self.continueAfterFailure = NO;
        XCTFail("Trying to run BMI160 tests on a board without a BMI160 gyro");
    }
    self.accelerometer = (MBLAccelerometerBMI160 *)self.device.accelerometer;
    self.gyro = (MBLGyroBMI160 *)self.device.gyro;
}

- (void)testAccelStream
{
    self.device.accelerometer.sampleFrequency = 25;
    [self.device.accelerometer.dataReadyEvent startNotificationsWithHandlerAsync:^(MBLAccelerometerData * _Nullable obj, NSError * _Nullable error) {
        NSLog(@"%@", obj);
    }];
    
    ((MBLBarometerBMP280 *)self.device.barometer).standbyTime = MBLBarometerBMP280Standby62_5;
    [((MBLBarometerBMP280 *)self.device.barometer).periodicPressure startNotificationsWithHandlerAsync:^(MBLNumericData * _Nullable obj, NSError * _Nullable error) {
        NSLog(@"%@", obj);
    }];
    
    
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"pause for manual verification"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2000 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [waitingExpectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5000 handler:nil];
    
    //self.accelerometer.fullScaleRange = MBLAccelerometerBoschRange2G;
    //[self eventUpdateTest:self.accelerometer.dataReadyEvent time:10];
}

- (void)testGyroUpdates
{
    self.gyro.sampleFrequency = 100;
    self.gyro.fullScaleRange = MBLGyroBMI160Range2000;
    [self eventUpdateTest:self.gyro.dataReadyEvent time:20];
}

- (void)testFreeFallUpdates
{
    self.accelerometer.lowOrHighGEvent.highGEnabledAxis = 0;
    self.accelerometer.lowOrHighGEvent.lowGEnabled = YES;
    [self eventUpdateTest:self.accelerometer.lowOrHighGEvent time:20];
}

- (void)testHighGUpdates
{
    self.accelerometer.fullScaleRange = MBLAccelerometerBoschRange16G;
    
    self.accelerometer.lowOrHighGEvent.lowGEnabled = NO;
    self.accelerometer.lowOrHighGEvent.highGThreshold = 8.0;
    self.accelerometer.lowOrHighGEvent.highGEnabledAxis = MBLAccelerometerAxisX;
    [self eventUpdateTest:self.accelerometer.lowOrHighGEvent time:20];
}

- (void)testOrientationUpdates
{
    [self eventUpdateTest:self.accelerometer.orientationEvent time:20];
}

- (void)testSingleTapUpdates
{
    self.accelerometer.tapEvent.type = MBLAccelerometerTapTypeSingle;
    self.accelerometer.fullScaleRange = MBLAccelerometerBoschRange16G;
    self.accelerometer.sampleFrequency = 100;
    [self eventUpdateTest:self.accelerometer.tapEvent time:20];
}

- (void)testDoubleTapUpdates
{
    self.accelerometer.tapEvent.type = MBLAccelerometerTapTypeDouble;
    self.accelerometer.fullScaleRange = MBLAccelerometerBoschRange16G;
    self.accelerometer.sampleFrequency = 100;
    [self eventUpdateTest:self.accelerometer.tapEvent time:20];
}

- (void)testSingleAndDoubleTap
{
    self.accelerometer.tapEvent.type = MBLAccelerometerTapTypeBoth;
    self.accelerometer.fullScaleRange = MBLAccelerometerBoschRange8G;
    self.accelerometer.sampleFrequency = 100;
    [self eventUpdateTest:self.accelerometer.tapEvent time:20];
}

- (void)testFlatUpdates
{
    self.accelerometer.fullScaleRange = MBLAccelerometerBoschRange8G;
    self.accelerometer.sampleFrequency = 100;
    [self eventUpdateTest:self.accelerometer.flatEvent time:20];
}

- (void)testStepDetectorUpdates
{
    [self.accelerometer resetStepCount];
    
    self.accelerometer.fullScaleRange = MBLAccelerometerBoschRange8G;
    self.accelerometer.sampleFrequency = 100;
    [self eventUpdateTest:self.accelerometer.stepEvent time:20];
    
    [[self.accelerometer.stepCounter readAsync] success:^(MBLNumericData * _Nonnull result) {
        NSLog(@"%@", result);
    }];
}

- (void)testMotionUpdates
{
    MBLAccelerometerBMI160MotionEvent *motionEvent = self.accelerometer.motionEvent;
    self.accelerometer.fullScaleRange = MBLAccelerometerBoschRange8G;
    self.accelerometer.sampleFrequency = 100;
    
    //motionEvent.significantAnyMotionEnabled = YES;
    //motionEvent.useSignificantMotion = YES;
    //motionEvent.slowNoMotionEnabled = YES;
    //motionEvent.useSlowMotion = NO;
    //motionEvent.slowNoMotionDuration = 5 * 1000;
    //motionEvent.slowNoMotionThreshold = 0.2;
    
    motionEvent.significantAnyMotionEnabled = YES;
    motionEvent.useSignificantMotion = NO;
    motionEvent.anyMotionDuration = 0; // One sample above threshold
    motionEvent.anyMotionThreshold = 0.10;
    
    [self eventUpdateTest:motionEvent time:20];
}

- (void)testButtonTurnOnLEDTapTurnOff
{
    [self.device.mechanicalSwitch.switchUpdateEvent programCommandsToRunOnEventAsync:^{
        [self.device.led flashLEDColorAsync:[MBLColor greenColor] withIntensity:0.5];
    }];
    [self.accelerometer.tapEvent programCommandsToRunOnEventAsync:^{
        [self.device.led setLEDOnAsync:NO withOptions:1];
    }];
    
    [self.accelerometer.tapEvent startNotificationsWithHandlerAsync:^(id obj, NSError *error) {
        NSLog(@"You tapped me!");
    }];
    
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"pause for manual verification"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.device.mechanicalSwitch.switchUpdateEvent eraseCommandsToRunOnEventAsync];
        [self.accelerometer.tapEvent eraseCommandsToRunOnEventAsync];
        [self.device.led setLEDOnAsync:NO withOptions:1];
        [waitingExpectation fulfill];
    });
    [self waitForExpectationsWithTimeout:15 handler:nil];
}

- (void)testTapAndStream
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"pause for manual verification"];
    
    [self.accelerometer.tapEvent startNotificationsWithHandlerAsync:^(id obj, NSError *error) {
        NSLog(@"TAP: %@", obj);
    }];
    [self.accelerometer.dataReadyEvent startNotificationsWithHandlerAsync:^(id obj, NSError *error) {
        NSLog(@"ACC: %@", obj);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.accelerometer.tapEvent stopNotificationsAsync];
        [self.accelerometer.dataReadyEvent stopNotificationsAsync];
        [waitingExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:60 handler:nil];
    
}

- (void)testMotionPowerSaveStateMachine
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];
    
    MBLAccelerometerBMI160MotionEvent *motionEvent = self.accelerometer.motionEvent;
    self.accelerometer.fullScaleRange = MBLAccelerometerBoschRange8G;
    self.accelerometer.sampleFrequency = 100;
    
    //motionEvent.significantAnyMotionEnabled = YES;
    //motionEvent.useSignificantMotion = YES;
    //motionEvent.slowNoMotionEnabled = YES;
    //motionEvent.useSlowMotion = NO;
    //motionEvent.slowNoMotionDuration = 5 * 1000;
    //motionEvent.slowNoMotionThreshold = 0.2;
    
    motionEvent.significantAnyMotionEnabled = YES;
    motionEvent.useSignificantMotion = NO;
    motionEvent.anyMotionDuration = 0; // One sample above threshold
    motionEvent.anyMotionThreshold = 0.10;
    
    // On Any-Motion timeout
    //  - Disable Data Int
    
    // On Any-Motion
    //  - start Any-Motion timer
    //  - Enable Data Int
    MBLTimerEvent *accelerometerTimeout = [self.device.timer eventWithPeriod:400 eventCount:1 autoStart:YES triggerOnStart:NO];
    
    [[[self.accelerometer.dataReadyEvent startNotificationsWithHandlerAsync:^(MBLAccelerometerData *obj, NSError *error) {
        NSLog(@"%@", obj);
    }] continueOnDispatchWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [accelerometerTimeout programCommandsToRunOnEventAsync:^{
            // Disable Data Int
            uint8_t data[] = { 0x0, 0x1 };
            [((MBLAccelerometerBoschDataReadyEvent *)self.accelerometer.dataReadyEvent).accelDataInterruptEn writeDataAsync:[NSData dataWithBytes:&data length:2]];
        }];
    }] continueOnDispatchWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [motionEvent programCommandsToRunOnEventAsync:^{
            [accelerometerTimeout start];
            // Enable Data Int
            uint8_t data[] = { 0x1, 0x0 };
            [((MBLAccelerometerBoschDataReadyEvent *)self.accelerometer.dataReadyEvent).accelDataInterruptEn writeDataAsync:[NSData dataWithBytes:&data length:2]];
        }];
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20000 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [waitingExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:200000 handler:nil];
}

- (void)testFlatAndStream
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];
    
    self.accelerometer.sampleFrequency = 10.0;
    [self.accelerometer.flatEvent startNotificationsWithHandlerAsync:^(MBLNumericData * _Nullable obj, NSError * _Nullable error) {
        NSLog(@"%@", obj);
    }];
    [BFTask taskFromMetaWearWithBlock:^id _Nonnull{
        [self.accelerometer.orientationEvent addNotificationWithExecutor:[BFExecutor dispatchExecutor] handler:^(id  _Nullable obj, NSError * _Nullable error) {
            NSLog(@"%@", obj);
        }];
        [self.accelerometer.orientationEvent performAsyncStartNotifications];
        return nil;
    }];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20000 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [waitingExpectation fulfill];
    });
    [self waitForExpectationsWithTimeout:200000 handler:nil];
}

@end
