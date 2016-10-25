/**
 * MMA8452QTests.m
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
#import "MBLAccelerometerMMA8452Q.h"

@interface MMA8452QTests : MetaWearTest
@property (nonatomic, retain) MBLAccelerometerMMA8452Q *accelerometer;
@end

@implementation MMA8452QTests

- (void)setUp
{
    [super setUp];
    
    if (![self.device.accelerometer isKindOfClass:[MBLAccelerometerMMA8452Q class]]) {
        self.continueAfterFailure = NO;
        XCTFail("Trying to run MMA8452Q tests on a board without an MMA8452Q accelerometer");
    }
    self.accelerometer = (MBLAccelerometerMMA8452Q *)self.device.accelerometer;
}


- (void)testSingleTapUpdates
{
    self.accelerometer.tapDetectionAxis = MBLAccelerometerAxisX;
    
    [self eventUpdateTest:self.accelerometer.tapEvent time:10];
}

- (void)testSingleTapCommand
{
    [self eventCommandTest:self.accelerometer.tapEvent time:5];
}

- (void)testSingleTapLogging
{
    [self eventLoggingTest:self.accelerometer.tapEvent time:5];
}

- (void)testSingleTapConcurrency
{
    [self eventConcurrencyTest:self.accelerometer.tapEvent time:5];
}


- (void)testDoubleTapUpdates
{
    self.accelerometer.tapType = MBLAccelerometerTapTypeDouble;
    [self eventUpdateTest:self.accelerometer.tapEvent time:5];
}

- (void)testDoubleTapCommand
{
    self.accelerometer.tapType = MBLAccelerometerTapTypeDouble;
    [self eventCommandTest:self.accelerometer.tapEvent time:5];
}

- (void)testDoubleTapLogging
{
    self.accelerometer.tapType = MBLAccelerometerTapTypeDouble;
    [self eventLoggingTest:self.accelerometer.tapEvent time:5];
}

- (void)testDoubleTapConcurrency
{
    self.accelerometer.tapType = MBLAccelerometerTapTypeDouble;
    [self eventConcurrencyTest:self.accelerometer.tapEvent time:5];
}


- (void)testSingleAndDoubleTap
{
    self.accelerometer.tapType = MBLAccelerometerTapTypeBoth;
    [self eventUpdateTest:self.accelerometer.tapEvent time:5];
}


- (void)testOrientationUpdates
{
    [self eventUpdateTest:self.accelerometer.orientationEvent time:5];
}

- (void)testOrientationCommand
{
    [self eventCommandTest:self.accelerometer.orientationEvent time:5];
}

- (void)testOrientationLogging
{
    [self eventLoggingTest:self.accelerometer.orientationEvent time:5];
}

- (void)testOrientationEverything
{
    [self eventConcurrencyTest:self.accelerometer.orientationEvent time:5];
}


- (void)testFreeFallUpdates
{
    //self.accelerometer.freeFallWidth = 20;
    //self.accelerometer.freeFallThreshold = 0.2;
    [self eventUpdateTest:self.accelerometer.freeFallEvent time:20];
}

- (void)testFreeFallCommand
{
    [self eventCommandTest:self.accelerometer.freeFallEvent time:5];
}

- (void)testFreeFallLogging
{
    [self eventLoggingTest:self.accelerometer.freeFallEvent time:5];
}

- (void)testFreeFallEverything
{
    [self eventConcurrencyTest:self.accelerometer.freeFallEvent time:5];
}


- (void)testShakeUpdates
{
    self.accelerometer.sampleFrequency = 50;
    self.accelerometer.shakeWidth = 400.0;
    self.accelerometer.shakeThreshold = 1.0;
    [self eventUpdateTest:self.accelerometer.shakeEvent time:5];
    self.accelerometer.shakeWidth = 200.0;
    self.accelerometer.shakeThreshold = 0.5;
}

- (void)testShakeCommand
{
    [self eventCommandTest:self.accelerometer.shakeEvent time:5];
}

- (void)testShakeLogging
{
    [self eventLoggingTest:self.accelerometer.shakeEvent time:5];
}

- (void)testShakeEverything
{
    [self eventConcurrencyTest:self.accelerometer.shakeEvent time:5];
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

- (void)testAllProperties
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"pause for manual verification"];
    
    self.accelerometer.fullScaleRange = MBLAccelerometerRange8G;
    self.accelerometer.highPassFilter = NO;
    self.accelerometer.highPassCutoffFreq = MBLAccelerometerCutoffFreqHigheset;
    self.accelerometer.sampleFrequency = 50;
    self.accelerometer.lowNoise = NO;
    self.accelerometer.fastReadMode = NO;
    self.accelerometer.sleepSampleFrequency = MBLAccelerometerSleepSampleFrequency1_56Hz;
    self.accelerometer.sleepPowerScheme = MBLAccelerometerPowerSchemeNormal;
    self.accelerometer.autoSleep = NO;
    self.accelerometer.tapDetectionAxis = MBLAccelerometerAxisX;
    self.accelerometer.tapType = MBLAccelerometerTapTypeSingle;
    
    int __block count = 0;
    [self.device.accelerometer.dataReadyEvent startNotificationsWithHandlerAsync:^(MBLAccelerometerData *obj, NSError *error) {
        // The RMS when not moving should be gravity only, or sqrt(1000*1000/3) = 577
        XCTAssertEqualWithAccuracy(obj.RMS, 0.577, 0.040);
        count++;
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.device.accelerometer.dataReadyEvent stopNotificationsAsync];
        // 2 seconds @50Hz gives us 100 samples
        XCTAssertEqualWithAccuracy(count, 100, 20);
        [waitingExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:10 handler:nil];
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

@end
