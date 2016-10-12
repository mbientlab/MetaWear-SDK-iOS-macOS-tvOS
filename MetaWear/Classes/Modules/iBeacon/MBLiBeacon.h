/**
 * MBLiBeacon.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 8/3/14.
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

#import <MetaWear/MBLConstants.h>
#import <MetaWear/MBLModule.h>
#import <Bolts/Bolts.h>

NS_ASSUME_NONNULL_BEGIN

/**
 iBeacon transmiter power
 */
typedef NS_ENUM(uint8_t, MBLiBeaconTransmitPower) {
    MBLiBeaconTransmitPower4dBm,
    MBLiBeaconTransmitPower0dBm,
    MBLiBeaconTransmitPowerMinus4dBm,
    MBLiBeaconTransmitPowerMinus8dBm,
    MBLiBeaconTransmitPowerMinus12dBm,
    MBLiBeaconTransmitPowerMinus16dBm,
    MBLiBeaconTransmitPowerMinus20dBm,
    MBLiBeaconTransmitPowerMinus30dBm,
    MBLiBeaconTransmitPowerMinus40dBm
};

/**
 Interface to program the device to advertise as an iBeacon
 */
@interface MBLiBeacon : MBLModule

/**
 The iBeacon UUID being broadcast, the default is the MetaWear Service UUID
 */
- (CBUUID *)uuid;
- (BFTask *)setUuid:(CBUUID *)uuid;
/**
 The iBeacon major value being broadcast, the default is 0x0000
 */
- (uint16_t)major;
- (BFTask *)setMajor:(uint16_t)major;
/**
 The iBeacon minor value being broadcast, the default is 0x0000
 */
- (uint16_t)minor;
- (BFTask *)setMinor:(uint16_t)minor;

/**
 Calibrated RX power in dBm. This represents the approximate RSSI value seen 
 by the reciever when 1 meter away from the iBeacon, default is -55 dBm.
 Valid range is [-10, -128].
 */
- (int8_t)calibratedReceiverPower;
- (BFTask *)setCalibratedReceiverPower:(int8_t)calibratedReceiverPower;
/**
 iBeacon transmit power.  Setting a smaller (lower dBm) value will result in 
 a smaller beacon discovery radius, default is MBLiBeaconTransmitPower0dBm.
 You should adjust calibratedReceiverPower when changing transmitPower.
 */
- (MBLiBeaconTransmitPower)transmitPower;
- (BFTask *)setTransmitPower:(MBLiBeaconTransmitPower)transmitPower;

/**
 Advertisement frequency in ms, default is 100 ms.
 Valid range is [20, 10,240]
 */
- (uint16_t)frequency;
- (BFTask *)setFrequency:(uint16_t)frequency;

/**
 Change iBeacon state to on or off.
 @warning The beacon will only be visible after you disconnect
 @param on YES turns iBeacon on, NO, turns iBeacon off
 */
- (BFTask *)setBeaconOnAsync:(BOOL)on;

@end

NS_ASSUME_NONNULL_END
