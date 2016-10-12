/**
 * MBLGyro.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 5/19/15.
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

#import <MetaWear/MBLModule.h>
#import <MetaWear/MBLEvent.h>
@class MBLGyroData;
@class MBLNumericData;

NS_ASSUME_NONNULL_BEGIN

/**
 Gyro axis
 */
typedef NS_ENUM(uint8_t, MBLGyroAxis) {
    MBLGyroAxisX = 0,
    MBLGyroAxisY = 1,
    MBLGyroAxisZ = 2
};

/**
 Interface to an abstract on-board gyroscope. If you need more advanced
 features then upcast to the specific gyroscope on your board, MBLGyroBMI160.
 @see MBLGyroBMI160
 */
@interface MBLGyro : MBLModule

/**
 The frequency, in hertz, for providing gyro samples to the event handlers.
 
 @discussion  The value of this property is capped to minimum and maximum values;
 the maximum value is determined by the maximum frequency supported by the hardware.
 If your app is sensitive to the intervals of acceleration data, it should always
 check the timestamps of the delivered MBLGyroData instances to determine the
 true update interval.
 */
@property (nonatomic) double sampleFrequency;

/**
 Event representing a new gryo data sample complete with x, y, and z
 axis data. This event will occur at the neareast hardware value
 to sampleFrequency. Event callbacks will be provided an MBLGyroData object.
 */
@property (nonatomic, readonly) MBLEvent<MBLGyroData *> *dataReadyEvent;
/**
 Event representing a new gyro X-axis sample. This event will occur
 at sampleFrequency. Event callbacks will be provided an MBLNumericData
 object whose double value will be rotation rate in degrees per second.
 */
@property (nonatomic, readonly) MBLEvent<MBLNumericData *> *xAxisReadyEvent;
/**
 Event representing a new gyro Y-axis sample. This event will occur
 at sampleFrequency. Event callbacks will be provided an MBLNumericData
 object whose double value will be rotation rate in degrees per second.
 */
@property (nonatomic, readonly) MBLEvent<MBLNumericData *> *yAxisReadyEvent;
/**
 Event representing a new gyro Z-axis sample. This event will occur
 at sampleFrequency. Event callbacks will be provided an MBLNumericData
 object whose double value will be rotation rate in degrees per second.
 */
@property (nonatomic, readonly) MBLEvent<MBLNumericData *> *zAxisReadyEvent;

@end

NS_ASSUME_NONNULL_END
