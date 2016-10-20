/**
 * MBLAmbientLightLTR329.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 7/27/15.
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

#import <MetaWear/MBLAmbientLight.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Gain applied to the ambient light sensor signal, changes the dynamic range
 */
typedef NS_ENUM(uint8_t, MBLAmbientLightLTR329Gain) {
    MBLAmbientLightLTR329Gain1X = 0, // 1 lux to 64k lux (default)
    MBLAmbientLightLTR329Gain2X = 1, // 0.5 lux to 32k lux
    MBLAmbientLightLTR329Gain4X = 2, // 0.25 lux to 16k lux
    MBLAmbientLightLTR329Gain8X = 3, // 0.125 lux to 8k lux
    MBLAmbientLightLTR329Gain48X = 6,// 0.02 lux to 1.3k lux
    MBLAmbientLightLTR329Gain96X = 7 // 0.01 lux to 600 lux
};

/**
 Integration Time is the measurement time for each ambient light sensor cycle
 */
typedef NS_ENUM(uint8_t, MBLAmbientLightLTR329Integration) {
    MBLAmbientLightLTR329Integration50ms = 1,
    MBLAmbientLightLTR329Integration100ms = 0,
    MBLAmbientLightLTR329Integration150ms = 4,
    MBLAmbientLightLTR329Integration200ms = 2,
    MBLAmbientLightLTR329Integration250ms = 5,
    MBLAmbientLightLTR329Integration300ms = 6,
    MBLAmbientLightLTR329Integration350ms = 7,
    MBLAmbientLightLTR329Integration400ms = 3
};

/**
 Measurement Repeat Rate, defines the the period of the XXX and YYY event.
 NOTE: must be set to be equal or larger than the Integration Time.
 */
typedef NS_ENUM(uint8_t, MBLAmbientLightLTR329Rate) {
    MBLAmbientLightLTR329Rate50ms = 0,
    MBLAmbientLightLTR329Rate100ms = 1,
    MBLAmbientLightLTR329Rate200ms = 2,
    MBLAmbientLightLTR329Rate500ms = 3,
    MBLAmbientLightLTR329Rate1000ms = 4,
    MBLAmbientLightLTR329Rate2000ms = 5
};

/**
 Interface to a LTR329 ambient light sensor
 */
@interface MBLAmbientLightLTR329 : MBLAmbientLight

/**
 Gain applied to the ambient light sensor signal, changes the dynamic range
 */
@property (nonatomic) MBLAmbientLightLTR329Gain gain;
/**
 The measurement time for each ambient light sensor cycle 
 */
@property (nonatomic) MBLAmbientLightLTR329Integration integrationTime;
/**
 Measurement Repeat Rate, defines the the period of the 
 periodicIlluminance event.
 */
@property (nonatomic) MBLAmbientLightLTR329Rate measurementRate;


/**
 Data representing the visible light response measured by the sensor. Period
 of event will depend on measurementRate. Event callbacks will be provided
 an MBLNumericData object whose double value will be illuminance in lux. 
 */
@property (nonatomic, readonly) MBLEvent<MBLNumericData *> *periodicIlluminance;

@end

NS_ASSUME_NONNULL_END
