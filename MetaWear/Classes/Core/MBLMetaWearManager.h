/**
 * MBLMetaWearManager.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 7/29/14.
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

#import <MetaWear/MBLMetaWear.h>
#import <MetaWear/MBLConstants.h>
#import <Bolts/Bolts.h>

NS_ASSUME_NONNULL_BEGIN

/**
 The MBLMetaWearManager is responsible for the scanning and discovery of MBLMetaWear devices.
 */
@interface MBLMetaWearManager : NSObject

/**
 Set the minimum firmware version required to run your app.  If you attempt to connect
 to a device with older firmware you will recieve a connection error.
 This defaults to oldest firmware supported by this API.
 */
@property (nonatomic) MBLFirmwareVersion minimumRequiredVersion;

/**
 Sets the queue for which all callbacks on both the MBLMetaWearManager and
 MBLMetaWear will occur on.  Defaults to the main queue.
 */
@property (nonatomic) NSOperationQueue *dispatchQueue;

/**
 Log level that will be displayed, defaults to `MBLLogLevelWarning`
 */
@property (nonatomic) MBLLogLevel logLevel;


///----------------------------------
/// @name Getting the Shared Instance
///----------------------------------

/**
 Access the shared MBLMetaWearManager object
 @returns The shared manager object.
 @warning You should not create an MBLMetaWearManager object, only used the sharedManager
 */
+ (instancetype)sharedManager;

///----------------------------------
/// @name Bluetooth State Watching
///----------------------------------

- (void)startBluetoothStateNotificationsWithHandler:(nonnull MBLCentralManagerStateHandler)handler;

- (void)stopBluetoothStateNotifications;

///----------------------------------
/// @name MetaWear Scanning and Finding
///----------------------------------

/**
 Begin scanning for MetaWear devices. This will invoke the provided block each time a
 new device shows up and passes an array of all discovered devices to the block.
 This continues until stopScanForMetaWears is called.
 @param handler Callback to handle each time a new device is found
 @see startScanForMetaWearsAllowDuplicates:handler:
 */
- (void)startScanForMetaWearsWithHandler:(MBLArrayHandler)handler;

/**
 Begin scanning for MetaWear devices with the option to filter duplicate devices or not.
 
 This will invoke the provided block each time a new device shows up if filter == YES or
 each time a new advertising packet is found if filter == NO (may be many times per second).
 This can be useful in specific situations, such as making a connection based on a
 MetaWear's RSSI, but may have an adverse affect on battery-life and application performance,
 so use wisely.  This continues until stopScanForMetaWears is called.
 @param duplicates YES: only callback when a new device is found, NO: callback each time
 @param handler Callback to handle each time a new device is found
 a new advertising packet is found
 */
- (void)startScanForMetaWearsAllowDuplicates:(BOOL)duplicates handler:(MBLArrayHandler)handler;

/**
 This method is intended for recovery mode only.  If a firmware update experiences an unexpected error,
 the device may get stuck in the bootloader and thus won't show up in startScanForMetaWearsWithHandler:.
 This method will start scanning for devices in bootloader mode
 @param duplicates YES: only callback when a new device is found, NO: callback each time
 a new advertising packet is found
 @param handler Callback to handle each time a new device is found
 @warning You can only call [MBLMetaWear updateFirmwareWithHandler:progressHandler:] on the `MBLMetaWear` objects
 in the array
 @warning This will cancel any current MetaWear scans
 */
- (void)startScanForMetaBootsAllowDuplicates:(BOOL)duplicates handler:(MBLArrayHandler)handler;

/**
 Stop scanning for devices, this will release all handlers given to
 startScanForMetaWearsAllowDuplicates:handler: and startScanForMetaBootsAllowDuplicates:handler:
 */
- (void)stopScan;

/**
 Devices are cached between start/stop scan requests, use the method if you with to clear that cache
 */
- (void)clearDiscoveredDevices;

/**
 Returns a list of saved MetaWear objects, you add to this list by calling [MBLMetaWear rememberDevice]
 @returns Task whose result will be an array of remembered MBLMetaWear objects
 */
- (BFTask<NSArray<MBLMetaWear *> *> *)retrieveSavedMetaWearsAsync;

///----------------------------------
/// @name Deprecated
///----------------------------------

- (void)stopScanForMetaBoots DEPRECATED_MSG_ATTRIBUTE("Use stopScan instead");
- (void)stopScanForMetaWears DEPRECATED_MSG_ATTRIBUTE("Use stopScan instead");
- (void)retrieveSavedMetaWearsWithHandler:(MBLArrayHandler)handler DEPRECATED_MSG_ATTRIBUTE("Use retrieveSavedMetaWearsAsync instead");

@end

NS_ASSUME_NONNULL_END
