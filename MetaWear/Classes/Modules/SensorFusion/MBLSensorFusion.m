/**
 * MBLSensorFusion.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 11/8/16.
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

#import "MBLSensorFusion+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLRegister+Private.h"
#import "MBLNumericFormatter.h"
#import "MBLLogger.h"
#import "MBLAccelerometerBMI160+Private.h"
#import "MBLGyroBMI160+Private.h"
#import "MBLMagnetometerBMM150+Private.h"
#import "MBLGravityFormat.h"
#import "MBLBitmaskEvent.h"
#import "MBLEulerFormat.h"
#import "MBLQuaternionFormat.h"
#import "MBLCorrectedFormat.h"

@interface MBLSensorFusion()
@property (nonatomic) MBLRegister *modeRegister;
@property (nonatomic) MBLRegister *outputEnable;

@property (nonatomic) MBLEvent *acceleration;
@property (nonatomic) MBLEvent *rotation;
@property (nonatomic) MBLEvent *magneticField;
@property (nonatomic) MBLEvent *eulerAngle;
@property (nonatomic) MBLEvent *quaternion;
@property (nonatomic) MBLEvent *gravity;
@property (nonatomic) MBLEvent *linearAcceleration;
@end

typedef struct  __attribute__((packed)) {
    uint8_t working_mode;
    uint8_t acc_range:4;
    uint8_t gyro_range:4;
} mw_sensorfusion_mode_t;

@implementation MBLSensorFusion

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        self.globalEnable = [[MBLRegister alloc] initWithModule:self registerId:0x1 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
        self.modeRegister = [[MBLRegister alloc] initWithModule:self registerId:0x2 format:[[MBLFormat alloc] initEncodedDataWithLength:2]];
        self.outputEnable = [[MBLRegister alloc] initWithModule:self registerId:0x3 format:[[MBLFormat alloc] initEncodedDataWithLength:2]];
        
        self.acceleration = [[MBLBitmaskEvent alloc] initWithModule:self registerId:0x4 enableBitmask:(1 << 0) enableRegister:self.outputEnable format:[[MBLCorrectedFormat alloc] initWithType:MBLCorrectedFormatTypeAccelerometer]];
        self.rotation = [[MBLBitmaskEvent alloc] initWithModule:self registerId:0x5 enableBitmask:(1 << 1) enableRegister:self.outputEnable format:[[MBLCorrectedFormat alloc] initWithType:MBLCorrectedFormatTypeGyro]];
        self.magneticField = [[MBLBitmaskEvent alloc] initWithModule:self registerId:0x6 enableBitmask:(1 << 2) enableRegister:self.outputEnable format:[[MBLCorrectedFormat alloc] initWithType:MBLCorrectedFormatTypeMagnetometer]];
        
        self.quaternion = [[MBLBitmaskEvent alloc] initWithModule:self registerId:0x7 enableBitmask:(1 << 3) enableRegister:self.outputEnable format:[[MBLQuaternionFormat alloc] init]];
        self.eulerAngle = [[MBLBitmaskEvent alloc] initWithModule:self registerId:0x8 enableBitmask:(1 << 4) enableRegister:self.outputEnable format:[[MBLEulerFormat alloc] init]];
        self.gravity = [[MBLBitmaskEvent alloc] initWithModule:self registerId:0x9 enableBitmask:(1 << 5) enableRegister:self.outputEnable format:[[MBLGravityFormat alloc] init]];
        self.linearAcceleration = [[MBLBitmaskEvent alloc] initWithModule:self registerId:0xA enableBitmask:(1 << 6) enableRegister:self.outputEnable format:[[MBLGravityFormat alloc] init]];
    }
    return self;
}

- (BFTask *)writeModeAccRange:(uint8_t)accRange gyroRange:(uint8_t)gyroRange
{
    // Write that mode
    mw_sensorfusion_mode_t mode = { 0 };
    mode.working_mode = self.mode;
    mode.acc_range = accRange;
    mode.gyro_range = gyroRange;
    
    return [self.modeRegister writeDataAsync:[NSData dataWithBytes:&mode length:sizeof(mw_sensorfusion_mode_t)]];
}

- (void)setMode:(MBLSensorFusionMode)mode
{
    if (self.initializeCount > 0) {
        if (mode != _mode) {
            MBLLog(MBLLogLevelError, @"Cannot change SensorFusion mode while it is active.");
        }
    } else {
        _mode = mode;
    }
}

- (BFTask *)performAsyncInitialization
{
    // Some basic housekeeping checks as we enable Sensor Fusion
    assert([self.device.accelerometer isKindOfClass:[MBLAccelerometerBMI160 class]]);
    assert([self.device.gyro isKindOfClass:[MBLGyroBMI160 class]]);
    assert([self.device.magnetometer isKindOfClass:[MBLMagnetometerBMM150 class]]);
    MBLAccelerometerBMI160 *accelerometer = (MBLAccelerometerBMI160 *)self.device.accelerometer;
    MBLGyroBMI160 *gyro = (MBLGyroBMI160 *)self.device.gyro;
    MBLMagnetometerBMM150 *magnetometer = (MBLMagnetometerBMM150 *)self.device.magnetometer;
    
    if (accelerometer.dataReadyEvent.initializeCount > 0) {
        return [BFTask taskWithError:[NSError errorWithDomain:kMBLErrorDomain
                                                         code:kMBLErrorOperationInvalid
                                                     userInfo:@{NSLocalizedDescriptionKey : @"Sensor Fusion needs to program the accelerometer to specific settings, please enable Sensor Fusion first before streaming or logging raw accelerometer data."}]];
    }
    if (gyro.dataReadyEvent.initializeCount > 0) {
        return [BFTask taskWithError:[NSError errorWithDomain:kMBLErrorDomain
                                                         code:kMBLErrorOperationInvalid
                                                     userInfo:@{NSLocalizedDescriptionKey : @"Sensor Fusion needs to program the gyro to specific settings, please enable Sensor Fusion first before streaming or logging raw gyro data."}]];
    }
    if (magnetometer.periodicMagneticField.initializeCount > 0) {
        return [BFTask taskWithError:[NSError errorWithDomain:kMBLErrorDomain
                                                         code:kMBLErrorOperationInvalid
                                                     userInfo:@{NSLocalizedDescriptionKey : @"Sensor Fusion needs to program the magnetometer to specific settings, please enable Sensor Fusion first before streaming or logging raw magnetometer data."}]];
    }
    
    // Byte 1.0-1.3: Accel Range (0: 2G, 1: 4G, 2: 8G, 3:16G)
    uint8_t accRange;
    switch (accelerometer.fullScaleRange) {
        case MBLAccelerometerBoschRange2G:
            accRange = 0;
            break;
        case MBLAccelerometerBoschRange4G:
            accRange = 1;
            break;
        case MBLAccelerometerBoschRange8G:
            accRange = 2;
            break;
        case MBLAccelerometerBoschRange16G:
            accRange = 3;
            break;
    }
    // Byte 1.4-1.7: Gyro Range (0: 2048, 1: 2000, 2: 1000, 3: 500, 4: 250) DPS (deg per sec)
    uint8_t gyroRange;
    switch (gyro.fullScaleRange) {
        case MBLGyroBMI160Range125:
            gyro.fullScaleRange = MBLGyroBMI160Range250;
            gyroRange = 4;
            break;
        case MBLGyroBMI160Range250:
            gyroRange = 4;
            break;
        case MBLGyroBMI160Range500:
            gyroRange = 3;
            break;
        case MBLGyroBMI160Range1000:
            gyroRange = 2;
            break;
        case MBLGyroBMI160Range2000:
            gyroRange = 1;
            break;
    }
    
    // Setup those sensors based on the mode
    switch (self.mode) {
        case MBLSensorFusionModeM4G:
            //    M4G (Mag/Acc simulated Gyro)
            //    50Hz Acc
            //    Null Gyro
            //    50Hz Mag (NOTE Using 25 for now since mag doesn't support 50)
            accelerometer.sampleFrequency = 50;
            
            magnetometer.powerPreset = MBLMagnetometerBMM150PresetRegular;
            magnetometer.sampleFrequency = MBLMagnetometerBMM150SampleFrequency25Hz;
            
            // Boot all the sensors
            return [[[[[accelerometer.dataReadyEvent initializeAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [accelerometer.dataReadyEvent activateAsync];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [magnetometer.periodicMagneticField initializeAsync];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [magnetometer.periodicMagneticField activateAsync];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [self writeModeAccRange:accRange gyroRange:gyroRange];
            }];
        case MBLSensorFusionModeNDoF:
            //    NDOF (N Degrees of Freedom: 9 axis rotation/heading)
            //    100Hz Acc
            //    100Hz Gyro
            //    25Hz Mag
            accelerometer.sampleFrequency = 100;
            
            gyro.sampleFrequency = 100;
            
            magnetometer.powerPreset = MBLMagnetometerBMM150PresetRegular;
            magnetometer.sampleFrequency = MBLMagnetometerBMM150SampleFrequency25Hz;
            
            // Boot all the sensors
            return [[[[[[[accelerometer.dataReadyEvent initializeAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [accelerometer.dataReadyEvent activateAsync];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [gyro.dataReadyEvent initializeAsync];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [gyro.dataReadyEvent activateAsync];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [magnetometer.periodicMagneticField initializeAsync];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [magnetometer.periodicMagneticField activateAsync];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [self writeModeAccRange:accRange gyroRange:gyroRange];
            }];
        case MBLSensorFusionModeCompass:
            //    Compass (Accel compensated Compass)
            //    25Hz Acc
            //    Null Gyro
            //    25Hz Mag
            accelerometer.sampleFrequency = 25;
            
            magnetometer.powerPreset = MBLMagnetometerBMM150PresetRegular;
            magnetometer.sampleFrequency = MBLMagnetometerBMM150SampleFrequency25Hz;
            
            // Boot all the sensors
            return [[[[[accelerometer.dataReadyEvent initializeAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [accelerometer.dataReadyEvent activateAsync];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [magnetometer.periodicMagneticField initializeAsync];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [magnetometer.periodicMagneticField activateAsync];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [self writeModeAccRange:accRange gyroRange:gyroRange];
            }];
        case MBLSensorFusionModeIMUPlus:
            //    IMUPlus (IMU Plus: 6 axis compensated rotation)
            //    100Hz Acc
            //    100Hz Gyro
            //    Null Mag
            accelerometer.sampleFrequency = 100;
            gyro.sampleFrequency = 100;
            
            // Boot all the sensors
            return [[[[[accelerometer.dataReadyEvent initializeAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [accelerometer.dataReadyEvent activateAsync];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [gyro.dataReadyEvent initializeAsync];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [gyro.dataReadyEvent activateAsync];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [self writeModeAccRange:accRange gyroRange:gyroRange];
            }];
        case MBLSensorFusionModeSleep:
            return [BFTask taskWithError:[NSError errorWithDomain:kMBLErrorDomain
                                                             code:kMBLErrorOperationInvalid
                                                         userInfo:@{NSLocalizedDescriptionKey : @"Please choose a mode besides Sleep before enabling Sensor Fusion."}]];
    }
}

- (BFTask *)performAsyncDeinitialization
{
    // Some basic housekeeping checks as we enable Sensor Fusion
    assert([self.device.accelerometer isKindOfClass:[MBLAccelerometerBMI160 class]]);
    assert([self.device.gyro isKindOfClass:[MBLGyroBMI160 class]]);
    assert([self.device.magnetometer isKindOfClass:[MBLMagnetometerBMM150 class]]);
    MBLAccelerometerBMI160 *accelerometer = (MBLAccelerometerBMI160 *)self.device.accelerometer;
    MBLGyroBMI160 *gyro = (MBLGyroBMI160 *)self.device.gyro;
    MBLMagnetometerBMM150 *magnetometer = (MBLMagnetometerBMM150 *)self.device.magnetometer;
    
    // Turn off those sensors based on the mode
    switch (self.mode) {
        case MBLSensorFusionModeM4G:
            // Disable all the sensors
            return [[[[accelerometer.dataReadyEvent deactivateAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [accelerometer.dataReadyEvent deinitializeAsync];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [magnetometer.periodicMagneticField deactivateAsync];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [magnetometer.periodicMagneticField deinitializeAsync];
            }];
        case MBLSensorFusionModeNDoF:
            // Disable all the sensors
            return [[[[[[accelerometer.dataReadyEvent deactivateAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [accelerometer.dataReadyEvent deinitializeAsync];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [gyro.dataReadyEvent deactivateAsync];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [gyro.dataReadyEvent deinitializeAsync];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [magnetometer.periodicMagneticField deactivateAsync];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [magnetometer.periodicMagneticField deinitializeAsync];
            }];
        case MBLSensorFusionModeCompass:
            // Disable all the sensors
            return [[[[accelerometer.dataReadyEvent deactivateAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [accelerometer.dataReadyEvent deinitializeAsync];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [magnetometer.periodicMagneticField deactivateAsync];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [magnetometer.periodicMagneticField deinitializeAsync];
            }];
        case MBLSensorFusionModeIMUPlus:
            // Disable all the sensors
            return [[[[accelerometer.dataReadyEvent deactivateAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [accelerometer.dataReadyEvent deinitializeAsync];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [gyro.dataReadyEvent deactivateAsync];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
                return [gyro.dataReadyEvent deinitializeAsync];
            }];
        case MBLSensorFusionModeSleep:
            return [BFTask taskWithError:[NSError errorWithDomain:kMBLErrorDomain
                                                             code:kMBLErrorOperationInvalid
                                                         userInfo:@{NSLocalizedDescriptionKey : @"Please choose a mode besides Sleep before enabling Sensor Fusion."}]];
    }
}

@end
