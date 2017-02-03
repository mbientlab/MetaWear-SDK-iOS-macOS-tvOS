/**
 * MBLAccelerometerBoschTapEvent.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 6/13/15.
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

#import <MetaWear/MBLEvent.h>
#import <MetaWear/MBLDataSample.h>
#import <MetaWear/MBLAccelerometer.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Time delay between two taps
 */
typedef NS_ENUM(uint8_t, MBLAccelerometerBoschTapDuration) {
    MBLAccelerometerBoschTapDuration50ms = 0,
    MBLAccelerometerBoschTapDuration100ms = 1,
    MBLAccelerometerBoschTapDuration150ms = 2,
    MBLAccelerometerBoschTapDuration200ms = 3,
    MBLAccelerometerBoschTapDuration250ms = 4, // Default
    MBLAccelerometerBoschTapDuration375ms = 5,
    MBLAccelerometerBoschTapDuration500ms = 6,
    MBLAccelerometerBoschTapDuration700ms = 7
};

/**
 Time for accelerometer to be still before a tap is considered to have occured
 */
typedef NS_ENUM(uint8_t, MBLAccelerometerBoschTapQuiet) {
    MBLAccelerometerBoschTapQuiet30ms = 0, // Default
    MBLAccelerometerBoschTapQuiet20ms = 1
};

/**
 Time for status register to be locked in order to prevent other slopes from overwirting tap information
 */
typedef NS_ENUM(uint8_t, MBLAccelerometerBoschTapShock) {
    MBLAccelerometerBoschTapShock50ms = 0, // Default
    MBLAccelerometerBoschTapShock75ms = 1
};

@interface MBLAccelerometerBoschTapEvent : MBLEvent<MBLDataSample *>

/**
 Select the type of taps to be registered. When MBLAccelerometerTapModeBoth is used,
 you will get two events on a double tap, one for the single and one for the double.
 */
@property (nonatomic) MBLAccelerometerTapType type;

/**
 Tap detection threshold in G's. Default 2.0
 */
@property (nonatomic) double threshold;

/**
 Time delay between two taps
 */
@property (nonatomic) MBLAccelerometerBoschTapDuration duration;
/**
 Time for accelerometer to be still before a tap is considered to have occured
 */
@property (nonatomic) MBLAccelerometerBoschTapQuiet quiet;
/**
 Time for status register to be locked in order to prevent other slopes from overwirting tap information
 */
@property (nonatomic) MBLAccelerometerBoschTapShock shock;

@end

NS_ASSUME_NONNULL_END
