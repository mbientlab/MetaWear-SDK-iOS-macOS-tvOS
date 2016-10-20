/**
 * MBLHygrometerBME280.h
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

#import <MetaWear/MBLHygrometer.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Hygrometer oversampling rates
 */
typedef NS_ENUM(uint8_t, MBLHygrometerBME280Oversample) {
    MBLHygrometerBME280Oversample1X = 1,    // default
    MBLHygrometerBME280Oversample2X = 2,
    MBLHygrometerBME280Oversample4X = 3,
    MBLHygrometerBME280Oversample8X = 4,
    MBLHygrometerBME280Oversample16X = 5,
};

/**
 Interface to a BME280 humidity sensor
 */
@interface MBLHygrometerBME280 : MBLHygrometer

/**
 Use this to set humidity sampling mode, higher values produce more accurate
 results but will use more power.
 */
@property (nonatomic) MBLHygrometerBME280Oversample humidityOversampling;

/**
 Data representing the relative humidity of the environment.
 Event callbacks will be provided an MBLNumericData object whose
 double value will be percent relative humidity [0.0-100.0].
 
 @waring Period of event will depend on standbyTime from the MBLBarometerBMP280.  TODO: Remove this coupling
 */
@property (nonatomic, readonly) MBLEvent<MBLNumericData *> *periodicHumidity;

@end

NS_ASSUME_NONNULL_END
