/**
 * MBLGyroBMI160.h
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

#import <MetaWear/MBLGyro.h>
#import <MetaWear/bmi160.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Gyro sensitiviy ranges in degrees per second
 */
typedef NS_ENUM(uint8_t, MBLGyroBMI160Range) {
    MBLGyroBMI160Range125 = BMI160_GYRO_RANGE_125_DEG_SEC,
    MBLGyroBMI160Range250 = BMI160_GYRO_RANGE_250_DEG_SEC,
    MBLGyroBMI160Range500 = BMI160_GYRO_RANGE_500_DEG_SEC,
    MBLGyroBMI160Range1000 = BMI160_GYRO_RANGE_1000_DEG_SEC,
    MBLGyroBMI160Range2000 = BMI160_GYRO_RANGE_2000_DEG_SEC
};

/**
 Interface to on-board BMI160 gyro
 */
@interface MBLGyroBMI160 : MBLGyro
/**
 Maximum rotation the gyro can report
 */
@property (nonatomic) MBLGyroBMI160Range fullScaleRange;

@end

NS_ASSUME_NONNULL_END