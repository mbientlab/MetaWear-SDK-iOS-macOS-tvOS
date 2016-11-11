/**
 * MBLSensorFusion.h
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


#import <MetaWear/MBLConstants.h>
#import <MetaWear/MBLEulerAngleData.h>
#import <MetaWear/MBLQuaternionData.h>
#import <MetaWear/MBLAccelerometerData.h>
#import <MetaWear/MBLGyroData.h>
#import <MetaWear/MBLMagnetometerData.h>
#import <MetaWear/MBLEvent.h>
#import <MetaWear/MBLModule.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Working mode of the sensor fusion library
 */
typedef NS_ENUM(uint8_t, MBLSensorFusionMode) {
    MBLSensorFusionModeSleep = 0,
    MBLSensorFusionModeNDoF = 1,
    MBLSensorFusionModeIMUPlus = 2,
    MBLSensorFusionModeCompass = 3,
    MBLSensorFusionModeM4G = 4
};

/**
 Interface to the on-board sensor fusion algorithims.
 */
@interface MBLSensorFusion : MBLModule
/**
 The working mode of the sensor fusion library.
 */
@property (nonatomic) MBLSensorFusionMode mode;

/**
 We provide attitude and heading information using both Euler Angles and Quaternions.  
 Compared to quaternions, Euler Angles are simple and intuitive and they lend themselves 
 well to simple analysis and control.  On the other hand, Euler Angles are limited by a 
 phenomenon called Gimbal Lock.  In applications where the sensor will never operate near
 pitch angles of +/- 90 degrees, Euler Angles are a good choice.
 
 Event representing the current euler angle vector.
 */
@property (nonatomic, readonly) MBLEvent<MBLEulerAngleData *> *eulerAngle;
/**
 A quaternion is a four-element vector that can be used to encode any rotation in a 3D 
 coordinate system.  Technically, a quaternion is composed of one real element and three
 complex elements.  It's best to start with Euler Angles unless you are already familiar
 with quaternions.

 Event representing the current quaternion vector.
 */
@property (nonatomic, readonly) MBLEvent<MBLQuaternionData *> *quaternion;

/**
 Event representing the current gravity vector.
 */
@property (nonatomic, readonly) MBLEvent<MBLAccelerometerData *> *gravity;
/**
 Event representing the current linear acceleration vector.
 */
@property (nonatomic, readonly) MBLEvent<MBLAccelerometerData *> *linearAcceleration;

/**
 Event representing the current corrected acceleration vector.
 */
@property (nonatomic, readonly) MBLEvent<MBLCorrectedAccelerometerData *> *acceleration;
/**
 Event representing the current corrected rotation vector measured by the gyro.
 */
@property (nonatomic, readonly) MBLEvent<MBLCorrectedGyroData *> *rotation;
/**
 Event representing the current corrected magnetic field vector.
 */
@property (nonatomic, readonly) MBLEvent<MBLCorrectedMagnetometeData *> *magneticField;

@end

NS_ASSUME_NONNULL_END
