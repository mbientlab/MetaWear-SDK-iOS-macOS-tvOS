/**
 * MBLAccelerometerBMI160.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 5/27/15.
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

#import "MBLAccelerometerBMI160+Private.h"
#import "MBLAccelerometerBosch+Private.h"
#import "MBLAccelerometer+Private.h"
#import "MBLAccelerometerBoschDataReadyEvent.h"
#import "MBLAccelerometerBoschAxisReadyEvent.h"
#import "MBLAccelerometerBoschLowOrHighGEvent+Private.h"
#import "MBLAccelerometerBoschOrientationEvent.h"
#import "MBLAccelerometerBoschTapEvent.h"
#import "MBLAccelerometerBoschFlatEvent.h"
#import "MBLAccelerometerBMI160StepEvent.h"
#import "MBLAccelerometerBMI160MotionEvent+Private.h"
#import "MBLFormat.h"
#import "MBLNumericFormatter.h"
#import "MBLData+Private.h"
#import "bmi160.h"

@interface MBLAccelerometerBMI160 ()
@property (nonatomic) MBLRegister *stepCounterReset;

@property (nonatomic) MBLEvent *stepEvent;
@property (nonatomic) MBLData *stepCounter;
@property (nonatomic) MBLAccelerometerBMI160MotionEvent *motionEvent;
@end

@implementation MBLAccelerometerBMI160

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        self.stepEvent = [[MBLAccelerometerBMI160StepEvent alloc] initWithAccelerometer:self];
        self.stepCounter = [[MBLData alloc] initWithModule:self registerId:0x1A format:[[MBLNumericFormatter alloc] initIntWithLength:2 isSigned:NO]];
        self.motionEvent = [[MBLAccelerometerBMI160MotionEvent alloc] initWithAccelerometer:self];
        
        self.stepCounterReset = [[MBLRegister alloc] initWithModule:self registerId:0x1B format:[[MBLFormat alloc] initEncodedDataWithLength:1]];

        self.lowOrHighGEvent.lowOrHighGDurationMultiplier = 2.5;
    }
    return self;
}

- (BFTask *)performAsyncInitialization
{
    // Setup the accelerometer config
    bmi160_regs_acc_t regs = { 0 };
    regs.acc_conf.acc_odr = self.scaleSampleFrequency;
    regs.acc_conf.acc_bwp = 2; // No oversampling
    regs.acc_conf.acc_us = 0; // Hardcode to not use undersampling mode
    
    regs.acc_range.acc_range = self.fullScaleRange;
    
    return [self.accelDataConfig writeDataAsync:[NSData dataWithBytes:&regs length:sizeof(bmi160_regs_gyr_t)]];
}

- (uint8_t)scaleSampleFrequency
{
    if (self.sampleFrequency > 800) {
        return BMI160_ACCEL_OUTPUT_DATA_RATE_1600HZ;
    } else if (self.sampleFrequency > 400) {
        return BMI160_ACCEL_OUTPUT_DATA_RATE_800HZ;
    } else if (self.sampleFrequency > 200) {
        return BMI160_ACCEL_OUTPUT_DATA_RATE_400HZ;
    } else if (self.sampleFrequency > 100) {
        return BMI160_ACCEL_OUTPUT_DATA_RATE_200HZ;
    } else if (self.sampleFrequency > 50) {
        return BMI160_ACCEL_OUTPUT_DATA_RATE_100HZ;
    } else if (self.sampleFrequency > 25) {
        return BMI160_ACCEL_OUTPUT_DATA_RATE_50HZ;
    } else if (self.sampleFrequency > 12.5) {
        return BMI160_ACCEL_OUTPUT_DATA_RATE_25HZ;
    } else {
        return BMI160_ACCEL_OUTPUT_DATA_RATE_12_5HZ;
    }
    // TODO: There are values lower than 12.5, but only
    // when undersampling is enabled
}

- (nonnull BFTask *)resetStepCount
{
    return [self.stepCounterReset writeByteAsync:0];
}

@end
