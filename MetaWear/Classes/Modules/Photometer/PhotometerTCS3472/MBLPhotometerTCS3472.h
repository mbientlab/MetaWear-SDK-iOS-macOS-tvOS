/**
 * MBLPhotometerTCS3472.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 2/17/16.
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

#import <MetaWear/MBLPhotometer.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Gain applied to the photometer sensor signal
 */
typedef NS_ENUM(uint8_t, MBLPhotometerTCS3472Gain) {
    MBLPhotometerTCS3472Gain1X = 0, // default
    MBLPhotometerTCS3472Gain4X = 1,
    MBLPhotometerTCS3472Gain16X = 2,
    MBLPhotometerTCS3472Gain60X = 3,
};

/**
 Interface to a TCS3472 RGB light sensor
 */
@interface MBLPhotometerTCS3472 : MBLPhotometer

/**
 Gain applied to the photometer sensor signal
 */
@property (nonatomic) MBLPhotometerTCS3472Gain gain;
/**
 The measurement time in ms for each RBG light sensor cycle. Valid range is [2.4-614.4], default 50.0.
 */
@property (nonatomic) double integrationTime;
/**
 Trigger an LED flash during the reading to improve reading in low light scenarios.
 YES: Flash during reading, NO: No flash, default NO.
 */
@property (nonatomic) BOOL ledFlash;

@end

NS_ASSUME_NONNULL_END
