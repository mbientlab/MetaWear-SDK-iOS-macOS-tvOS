/**
 * BMA255Tests.m
 * MetaWearTests
 *
 * Created by Stephen Schiffli on 3/8/16.
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

@interface BMA255Tests : MetaWearTest
@property (nonatomic, retain) MBLAccelerometerBMA255 *accelerometer;
@end

@implementation BMA255Tests

- (void)setUp
{
    [super setUp];
    
    if (![self.device.accelerometer isKindOfClass:[MBLAccelerometerBMA255 class]]) {
        self.continueAfterFailure = NO;
        XCTFail("Trying to run BMA255 tests on a board without a BMA255 accelerometer");
    }
    self.accelerometer = (MBLAccelerometerBMA255 *)self.device.accelerometer;
}

- (void)testAccelStream
{
    self.accelerometer.fullScaleRange = MBLAccelerometerBoschRange16G;
    [self eventUpdateTest:self.accelerometer.dataReadyEvent time:10];
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
    self.accelerometer.fullScaleRange = MBLAccelerometerBoschRange16G;
    self.accelerometer.sampleFrequency = 100;
    [self eventUpdateTest:self.accelerometer.tapEvent time:20];
}

- (void)testFlatUpdates
{
    self.accelerometer.fullScaleRange = MBLAccelerometerBoschRange16G;
    self.accelerometer.sampleFrequency = 100;
    [self eventUpdateTest:self.accelerometer.flatEvent time:20];
}


- (void)testMotionUpdates
{
    MBLAccelerometerBMA255MotionEvent *motionEvent = self.accelerometer.motionEvent;
    self.accelerometer.fullScaleRange = MBLAccelerometerBoschRange16G;
    self.accelerometer.sampleFrequency = 100;
    
    motionEvent.anyMotionEnabled = YES;
    
    [self eventUpdateTest:motionEvent time:20];
}


@end
