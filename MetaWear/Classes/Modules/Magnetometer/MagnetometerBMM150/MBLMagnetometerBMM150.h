/**
 * MBLMagnetometerBMM150.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 1/6/16.
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

#import <MetaWear/MBLMagnetometer.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Magnetometer power presets
 */
typedef NS_ENUM(uint8_t, MBLMagnetometerBMM150Preset) {
    MBLMagnetometerBMM150PresetLowPower = 0,
    MBLMagnetometerBMM150PresetRegular = 1,
    MBLMagnetometerBMM150PresetEnhancedRegular = 2,
    MBLMagnetometerBMM150PresetHighAccuracy = 3
};

/**
 Interface to a BMM150 magnetometer sensor
 */
@interface MBLMagnetometerBMM150 : MBLMagnetometer

/**
 This affects the power, accuracy, and frequency of periodicMagneticField event
 */
@property (nonatomic) MBLMagnetometerBMM150Preset powerPreset;


/**
 Data representing the periodic magnetic field measured by magnetometer. 
 Event callbacks will be provided an MBLMagnetometerData object.
 */
@property (nonatomic, readonly) MBLEvent<MBLMagnetometerData *> *periodicMagneticField;

@end

NS_ASSUME_NONNULL_END
