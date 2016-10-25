/**
 * MBLBarometerBMP280.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 7/28/15.
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

#import <MetaWear/MBLBarometerBosch.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Barometer standby times
 */
typedef NS_ENUM(uint8_t, MBLBarometerBMP280Standby) {
    MBLBarometerBMP280Standby0_5 = 0,
    MBLBarometerBMP280Standby62_5 = 1,
    MBLBarometerBMP280Standby125 = 2,
    MBLBarometerBMP280Standby250 = 3,
    MBLBarometerBMP280Standby500 = 4, // default
    MBLBarometerBMP280Standby1000 = 5,
    MBLBarometerBMP280Standby2000 = 6,
    MBLBarometerBMP280Standby4000 = 7
};

/**
 Interface to a BMP280 pressure sensor
 */
@interface MBLBarometerBMP280 : MBLBarometerBosch

/**
 Set the standby time for the periodicAltitidue and periodicPressure events.
 That is how long the device sleeps between successive measurements
 */
@property (nonatomic) MBLBarometerBMP280Standby standbyTime;

@end

NS_ASSUME_NONNULL_END
