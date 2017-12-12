/**
 * MBLGyroBMI160.m
 * MetaWear
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

#import "MBLGyroBMI160.h"
#import "MBLGyro+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLGyroBMI160DataReadyEvent.h"
#import "MBLGyroBMI160PackedDataReadyEvent.h"
#import "MBLGyroBMI160AxisReadyEvent.h"
#import "MBLNumericFormatter.h"

@interface MBLGyroBMI160 ()
@property (nonatomic) MBLRegister *gyroConfig;
@property (nonatomic) MBLRegister *gyroPowerModeTrigger;
@property (nonatomic) MBLRegister *powerModeStatus;
@end

@implementation MBLGyroBMI160

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        // MBLGyro properties
        self.dataReadyEvent = [[MBLGyroBMI160DataReadyEvent alloc] initWithGyro:self];
        if (moduleInfo.moduleRevision >= 1) {
            self.packedDataReadyEvent = [[MBLGyroBMI160PackedDataReadyEvent alloc] initWithGyro:self];
        }
        self.xAxisReadyEvent = [[MBLGyroBMI160AxisReadyEvent alloc] initWithGyro:self axis:MBLGyroAxisX];
        self.yAxisReadyEvent = [[MBLGyroBMI160AxisReadyEvent alloc] initWithGyro:self axis:MBLGyroAxisY];
        self.zAxisReadyEvent = [[MBLGyroBMI160AxisReadyEvent alloc] initWithGyro:self axis:MBLGyroAxisZ];
        
        // Default settings
        self.fullScaleRange = MBLGyroBMI160Range2000;
        self.filterMode = MBLBMI160FilterModeNormal;

        // Registers
        MBLRegister *gyroPowerMode = [[MBLRegister alloc] initWithModule:self registerId:0x1 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
        self.gyroConfig = [[MBLRegister alloc] initWithModule:self registerId:0x3 format:[[MBLFormat alloc] initEncodedDataWithLength:2]];
        self.gyroPowerModeTrigger = [[MBLRegister alloc] initWithModule:self registerId:0x4 format:[[MBLFormat alloc] initEncodedDataWithLength:1]];
        
        self.globalEnable = gyroPowerMode;
    }
    return self;
}

- (BFTask *)pullConfigAsync
{
    return [[self.gyroConfig readAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        MBLDataSample *result = t.result;
        const bmi160_regs_gyr_t *regs = result.data.bytes;
        self.fullScaleRange = regs->gyr_range.gyr_range;
        return nil;
    }];
}

- (BFTask *)performAsyncInitialization
{
    // First setup the gyro config
    bmi160_regs_gyr_t regs = { 0 };
    regs.gyr_conf.gyr_odr = self.scaleSampleFrequency;
    regs.gyr_conf.gyr_bwp = self.filterMode;
    
    regs.gyr_range.gyr_range = self.fullScaleRange;
    
    return [self.gyroConfig writeDataAsync:[NSData dataWithBytes:&regs length:sizeof(bmi160_regs_gyr_t)]];
}

- (uint8_t)scaleSampleFrequency
{
    if (self.sampleFrequency > 1600) {
        return BMI160_GYRO_OUTPUT_DATA_RATE_3200HZ;
    } else if (self.sampleFrequency > 800) {
        return BMI160_GYRO_OUTPUT_DATA_RATE_1600HZ;
    } else if (self.sampleFrequency > 400) {
        return BMI160_GYRO_OUTPUT_DATA_RATE_800HZ;
    } else if (self.sampleFrequency > 200) {
        return BMI160_GYRO_OUTPUT_DATA_RATE_400HZ;
    } else if (self.sampleFrequency > 100) {
        return BMI160_GYRO_OUTPUT_DATA_RATE_200HZ;
    } else if (self.sampleFrequency > 50) {
        return BMI160_GYRO_OUTPUT_DATA_RATE_100HZ;
    } else if (self.sampleFrequency > 25) {
        return BMI160_GYRO_OUTPUT_DATA_RATE_50HZ;
    } else {
        return BMI160_GYRO_OUTPUT_DATA_RATE_25HZ;
    }
}

@end
