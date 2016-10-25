/**
 * MBLSettings.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 1/19/15.
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
#import <MetaWear/MBLConstants.h>
#import <Bolts/Bolts.h>
@class MBLEvent<ResultType>;
@class MBLData<ResultType>;
@class MBLStringData;
@class MBLDataSample;
@class MBLNumericData;

NS_ASSUME_NONNULL_BEGIN

/**
 BLE transmiter power
 */
typedef NS_ENUM(uint8_t, MBLTransmitPower) {
    MBLTransmitPower4dBm = 0,
    MBLTransmitPower0dBm = 1,
    MBLTransmitPowerMinus4dBm = 2,
    MBLTransmitPowerMinus8dBm = 3,
    MBLTransmitPowerMinus12dBm = 4,
    MBLTransmitPowerMinus16dBm = 5,
    MBLTransmitPowerMinus20dBm = 6,
    MBLTransmitPowerMinus30dBm = 7
};

@interface MBLSettings : MBLModule

/**
 Advertising interval in ms. Defaults to 417.5
 This should be carefully considered, because it affects the time to discovery 
 and connect performance, and also battery life.
 */
@property (nonatomic) double advertisingInterval;
/**
 Advertising timeout in seconds. Valid range is [0, 180], use 0 for unlimited 
 advertising (0 is default)
 */
@property (nonatomic) uint8_t advertisingTimeout;

/**
 Bluetooth radio transmit power.  Setting a smaller (lower dBm) value will
 result in a smaller connection radius, default is MBLTransmitPower0dBm.
 */
@property (nonatomic) MBLTransmitPower transmitPower;

/**
 Set a raw value into the scan response BLE advertising packet.
 For example this byte string would turn the MetaWear into a URIBeacon
 uint8_t rawuri[] = { 0x03, 0x03, 0xD8, 0xFE, 0x10, 0x16, 0xD8, 0xFE, 0x00, 0x12, 0x00, 0x6D, 0x62, 0x69, 0x65, 0x6E, 0x74, 0x6C, 0x61, 0x62, 0x00 };
 */
@property (nonatomic, nullable) NSData *scanResponse;

/**
 Choose what happens if the internal log fills up.  If circularBufferLog is YES
 then the oldest log entries will be deleted to make room for now entries, if
 NO then new entries will be discared.  Defaults to NO.
 */
@property (nonatomic) BOOL circularBufferLog;

/**
 Event representing a BLE disconnection event.  Note this doesn't make sense to
 stream, but it's likely that programCommandsToRunOnEventAsync will have utility.
 Event callbacks will be provided an MBLDataSample object.
 */
@property (nonatomic, readonly, nullable) MBLEvent<MBLDataSample *> *disconnectEvent;

/**
 Get the MAC address of the MetaWear
 Event callbacks will be provided an MBLStringData object.
 */
@property (nonatomic, readonly, nullable) MBLData<MBLStringData *> *macAddress;

/**
 Percent remaining battery life, returns int between 0-100
 */
@property (nonatomic, readonly, nullable) MBLData<MBLNumericData *> *batteryRemaining;


/**
 Start the pairing process which creates a persistent bond between the
 MetaWear and iOS device
 */
- (BFTask *)initiatePairingAsync;
/**
 Removes all bonding information stored on the MetaWear.  The delete will
 actually occur on the next disconnect.
 
 Note, to delete bonding information on the iOS device you must go to 
 Settings -> Bluetooth choose the device you want to remove and 
 select "Forget This Device"
 */
- (BFTask *)deleteAllBondsAsync;

/**
 This call will start advertisement.  You can hook this call up to any MBLEvent
 if you need advanced ways to start advertising.  Note a button press it already
 hard coded to always trigger advertising, which should cover most cases.
 */
- (BFTask *)startAdvertisementAsync;



///----------------------------------
/// @name Experimental Connection Parameters
///----------------------------------

/**
 Minimum Connection Interval (uint16_t in units of 1.25ms) Valid range [6, 3200]
 */
@property (nonatomic) uint16_t minimumConnectionInterval;
/**
 Maximum Connection Interval (uint16_t in units of 1.25ms) Valid range [6, 3200]
 */
@property (nonatomic) uint16_t maximumConnectionInterval;
/**
 Slave Latency (intervals the device may skip if it has no data) Valid range [0, 1000]
 */
@property (nonatomic) uint16_t slaveLatency;
/**
 Supervisory Timeout (uint16_t in units of 10ms) Valid range [10, 3200]
 */
@property (nonatomic) uint16_t supervisoryTimeout;
/**
 Write all the above values to the device
 */
- (BFTask *)applyConnectionParametersAsync;

/**
 Raw battery voltage in mV.  For enabling only, please use batteryRemaining instead.
 */
@property (nonatomic, readonly, nullable) MBLData<MBLNumericData *> *batteryVoltage;

@end

NS_ASSUME_NONNULL_END
