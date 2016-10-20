/**
 * MBLAccelerometerBosch.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 2/29/16.
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

#import <MetaWear/MBLAccelerometer.h>
#import <MetaWear/bmi160.h>
@class MBLNumericData;
@class MBLAccelerometerBoschLowOrHighGEvent;

NS_ASSUME_NONNULL_BEGIN

/**
 Accelerometer sensitiviy ranges
 */
typedef NS_ENUM(uint8_t, MBLAccelerometerBoschRange) {
    MBLAccelerometerBoschRange2G = BMI160_ACCEL_RANGE_2G,
    MBLAccelerometerBoschRange4G = BMI160_ACCEL_RANGE_4G,
    MBLAccelerometerBoschRange8G = BMI160_ACCEL_RANGE_8G,
    MBLAccelerometerBoschRange16G = BMI160_ACCEL_RANGE_16G,
};

/**
 Interface to a Bosch accelerometer
 */
@interface MBLAccelerometerBosch : MBLAccelerometer
/**
 Maximum acceleration the accelerometer can report
 */
@property (nonatomic) MBLAccelerometerBoschRange fullScaleRange;


/**
 Event representing a low-g (free fall) or high-g (impact) event.
 Event callbacks will be provided an empty MBLDataSample object
 */
@property (nonatomic, readonly) MBLAccelerometerBoschLowOrHighGEvent *lowOrHighGEvent;


/**
 Select the type of taps to be registered. When MBLAccelerometerTapModeBoth is used,
 you will get two events on a double tap, one for the single and one for the double.
 */
@property (nonatomic) MBLAccelerometerTapType tapType;
/**
 Event representing a tap (single, double, or both based on tapType) on the tapDetectionAxis.
 Event callbacks will be provided an empty MBLDataSample object
 */
@property (nonatomic, readonly) MBLEvent<MBLDataSample *> *tapEvent;


/**
 Event representing an orientation change.
 Event callbacks will be provided an MBLOrientationData object
 */
@property (nonatomic, readonly) MBLEvent<MBLOrientationData *> *orientationEvent;


/**
 Event representing the device being laid down flat (or removed from a flat posistion).
 Event callbacks will be provided an MBLNumericData object, where a bool value of
 YES means flat, and NO means not-flat.
 */
@property (nonatomic, readonly) MBLEvent<MBLNumericData *> *flatEvent;

@end

NS_ASSUME_NONNULL_END
