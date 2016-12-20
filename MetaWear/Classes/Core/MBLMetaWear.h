/**
 * MBLMetaWear.h
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

#import <CoreBluetooth/CoreBluetooth.h>
#import <MetaWear/MBLConstants.h>
#import <Bolts/Bolts.h>

@class MBLTemperature;
@class MBLAccelerometer;
@class MBLGyro;
@class MBLLED;
@class MBLMechanicalSwitch;
@class MBLGPIO;
@class MBLHapticBuzzer;
@class MBLiBeacon;
@class MBLNeopixel;
@class MBLEvent;
@class MBLANCS;
@class MBLI2C;
@class MBLSerial;
@class MBLTimer;
@class MBLConductance;
@class MBLBarometer;
@class MBLAmbientLight;
@class MBLMagnetometer;
@class MBLHygrometer;
@class MBLPhotometer;
@class MBLProximity;
@class MBLSensorFusion;
@class MBLSettings;
@class MBLMetaWear;
@class MBLFirmwareUpdateInfo;
@protocol MBLBluetoothPeripheralDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 Current state of the MetaWear connection
 */
typedef NS_ENUM(NSInteger, MBLConnectionState) {
    MBLConnectionStateDisconnected = 0,
    MBLConnectionStateConnecting,
    MBLConnectionStateConnected,
    MBLConnectionStateDisconnecting,
    MBLConnectionStateDiscovery,
};


/**
 An MBLRestorable object is used to persist state across resets and disconnects.
 You create an object that conforms to this protocol and then assign it to an
 MBLMetaWear object using the setConfiguration:handler: method
 */
@protocol MBLRestorable <NSObject>
/**
 This function is called shortly after you assign this object to a MetaWear device.
 Override this function and use it as the main initialization point for setting up
 custom events needed for your application.
 
 Any API calls in this method will be persisted in non-volatile memory on the
 MetaWear, and be executed when the MetaWear powers on.  For example, if you want
 the device to automatically (after reset or power-loss) startLoggingAsync some 
 event, set the peripheral name, or modifiy a connection parameter, do that in this function.
 */
- (void)runOnDeviceBoot:(MBLMetaWear *)device;
@end



/**
 Each MBLMetaWear object corresponds a physical MetaWear board.  It contains all the logical
 methods you would expect for interacting with the device, such as, connecting, disconnecting,
 reading and writing state.
 
 Sensors and peripherals on the MetaWear are encapsulated within their own objects accessable 
 here via properties.  For example, all accelerometer functionality is contained in the 
 MBLAccelerometer class and is accessed using the accelerometer property
 */
@interface MBLMetaWear : NSObject

///----------------------------------
/// @name Sensor and Peripheral Accessors
///----------------------------------

/**
 MBLMechanicalSwitch object contains all methods for interacting with the on-board button
 */
@property (nonatomic, readonly, nullable) MBLMechanicalSwitch *mechanicalSwitch;
/**
 MBLLED object contains all methods for interacting with the on-board LED
 */
@property (nonatomic, readonly, nullable) MBLLED *led;
/**
 MBLTemperature object contains all methods for interacting with the on-chip and external thermistor temperature sensors
 */
@property (nonatomic, readonly, nullable) MBLTemperature *temperature;
/**
 MBLAccelerometer object contains all methods for interacting with the on-board accelerometer sensor
 */
@property (nonatomic, readonly, nullable) MBLAccelerometer *accelerometer;
/**
 MBLGyro object contains all methods for interacting with the on-board gyroscope sensor
 */
@property (nonatomic, readonly, nullable) MBLGyro *gyro;
/**
 MBLGPIO object contains all methods for interacting with the on-board pins
 */
@property (nonatomic, readonly, nullable) MBLGPIO *gpio;
/**
 MBLHapticBuzzer object contains all methods for interacting with the external haptic or buzzer
 */
@property (nonatomic, readonly, nullable) MBLHapticBuzzer *hapticBuzzer;
/**
 MBLiBeacon object contains all methods for programming the device to advertise as an iBeacon
 */
@property (nonatomic, readonly, nullable) MBLiBeacon *iBeacon;
/**
 MBLNeopixel object contains all methods for interacting with an external NeoPixel chain
 */
@property (nonatomic, readonly, nullable) MBLNeopixel *neopixel;
/**
 MBLANCS object contains all methods for interacting with ANCS notifications
 */
@property (nonatomic, readonly, nullable) MBLANCS *ancs;
/**
 MBLTimer object contains all methods for programming timer based operations
 */
@property (nonatomic, readonly, nullable) MBLTimer *timer;
/**
 MBLSerial object contains all methods for performing raw I2C and SPI read/writes
 */
@property (nonatomic, readonly, nullable) MBLSerial *serial;
/**
 MBLConductance object contains all methods for perfoming Conductance reads
 */
@property (nonatomic, readonly, nullable) MBLConductance *conductance;
/**
 MBLBarometer object contains all methods for interacting with the barometer sensor
 */
@property (nonatomic, readonly, nullable) MBLBarometer *barometer;
/**
 MBLAmbientLight object contains all methods for interacting with the ambient light sensor
 */
@property (nonatomic, readonly, nullable) MBLAmbientLight *ambientLight;
/**
 MBLMagnetometer object contains all methods for interacting with the magnetometer sensor
 */
@property (nonatomic, readonly, nullable) MBLMagnetometer *magnetometer;
/**
 MBLHygrometer object contains all methods for interacting with the humidity sensor
 */
@property (nonatomic, readonly, nullable) MBLHygrometer *hygrometer;
/**
 MBLPhotometer object contains all methods for interacting with the photometer (color) sensor
 */
@property (nonatomic, readonly, nullable) MBLPhotometer *photometer;
/**
 MBLProximity object contains all methods for interacting with the proximity sensor
 */
@property (nonatomic, readonly, nullable) MBLProximity *proximity;
/**
 MBLProximity object contains all methods for interacting with the proximity sensor
 */
@property (nonatomic, readonly, nullable) MBLSensorFusion *sensorFusion;
/**
 MBLSettings object contains all methods for interacting with MetaWear device settings
 */
@property (nonatomic, readonly, nullable) MBLSettings *settings;
/**
 MBLDeviceInfo object contains version information about the device
 */
@property (nonatomic, readonly, nullable) MBLDeviceInfo *deviceInfo;


///----------------------------------
/// @name Persistent Configuration Settings
///----------------------------------

/**
 MBLRestorable object containing custom settings and events that are programmed
 to the MetaWear and preserved between disconnects and app termination.
 */
@property (nonatomic, readonly, nullable) id<MBLRestorable> configuration;

/**
 Assign a new configuration object to this MetaWear.  This only needs to be called once,
 likely after you confirm the device from a scanning screen or such.  Upon calling it will
 erase all non-volatile memory the device (which requires disconnect), then perform reset, 
 once its comes back online we will connect and invoke the setupEvents method.
 Then the runOnDeviceBoot method is invoked and all calls in that method are persisted 
 device side so after any future reset these settings will be applied automatically.
 @param configuration Pointer to object containing programming commands.  Writing nil
 will reset to factory settings.
 */
- (BFTask<MBLMetaWear *> *)setConfigurationAsync:(nullable id<MBLRestorable>)configuration;

///----------------------------------
/// @name State Accessors
///----------------------------------

/**
 Current connection state of this MetaWear
 */
@property (nonatomic, readonly) MBLConnectionState state;
/**
 Since we do not support using a single MetaWear device with multiple application, you
 should take care if a user accidently tries to do this.  Once connected, your application
 should check this BOOL and if it is YES, then you shouldn't change settings or perform any
 operations unless you supply the user with an alert saying, "This device is in use by another
 application, are you sure you want to reprogram it?  This will cause errors and data loss for
 the other application”.  If they agree then you need to call setConfigurationAsync: to take
 ownership of the device.
 */
@property (nonatomic, readonly) BOOL programedByOtherApp;
/**
 iOS generated unique identifier for this MetaWear.  This is device specific and
 two different iOS devices with generate two different identifiers.
 */
@property (nonatomic, readonly) NSUUID *identifier;
/**
 Stored value of signal strength at discovery time
 */
@property (nonatomic, readonly, nullable) NSNumber *discoveryTimeRSSI;
/**
 Smoothed out RSSI value, great for use with signal strength icons
 */
@property (nonatomic, readonly, nullable) NSNumber *averageRSSI;
/**
 Advertised device name.  You can simply assign a new string
 if you wish to change the advertised name, max 8 characters!
 */
@property (nonatomic) NSString *name;
/**
 The model of this MetaWear.  This is only valid after a successful connection!
 @see MBLModelString for turning this into a friendly string
 */
@property (nonatomic) MBLModel model;

///----------------------------------
/// @name Connect/Disconnect
///----------------------------------

/**
 Connect/reconnect to the MetaWear board. Once connection is complete, the provided block
 will be invoked.  If the NSError provided to the block is null then the connection
 succeeded, otherwise failure (see provided error for details)
 */
- (BFTask<MBLMetaWear *> *)connectAsync;
/**
 Connect/reconnect to the MetaWear board, but with a timeout if the board can't be 
 located.  Once connection is complete, the provided block will be invoked.  If the 
 NSError provided to the block is null then the connection succeeded, otherwise 
 failure (see provided error for details)
 @param timeout Max time to search for MetaWear before giving up
 */
- (BFTask<MBLMetaWear *> *)connectWithTimeoutAsync:(NSTimeInterval)timeout;

/**
 Disconnect from the MetaWear board.
 */
- (BFTask<MBLMetaWear *> *)disconnectAsync;

/**
 Create a task that will complete once this device disconnects, either expectedly
 or unexpectedly.  This is useful for observing unexpected disconnects and
 automatically issing a re-connect request or otherwise updating the UI.
 */
- (BFTask<MBLMetaWear *> *)waitForDisconnect;

///----------------------------------
/// @name Remember/Forget
///----------------------------------

/**
 Remember this MetaWear, it will be saved to disk and retrievable
 through [MBLMetaWearManager retrieveSavedMetaWears]
 */
- (void)rememberDevice;
/**
 Forget this MetaWear, it will no longer be retrievable
 through [MBLMetaWearManager retrieveSavedMetaWears]
 */
- (void)forgetDevice;

/**
 The state of all MetaWear modules are persisted to disk for ease of use
 across application launches.  Most of the time you don't need to explicitly
 call this function as it is called automatically after interactions with the 
 board.  Function that count as interacation include start/stopLogging,
 start/stopNotificationsAsync, program/eraseCommands.  If you make changes to various
 module setting but don't call one of these functions, then it may be usefully 
 to call this function so you don't lose the state of those setting changes.
 */
- (BFTask<MBLMetaWear *> *)synchronizeAsync;

///----------------------------------
/// @name State Reading
///----------------------------------

/**
 Query the current RSSI
 */
- (BFTask<NSNumber *> *)readRSSIAsync;
/**
 Query the percent remaining battery life, returns int between 0-100
 */
- (BFTask<NSNumber *> *)readBatteryLifeAsync;

///----------------------------------
/// @name Firmware Update and Reset
///----------------------------------

/**
 Perform a software reset of the device.  Note that all module properties of
 this object will be invalidated, so remove any external references to them.
 @warning This will cause the device to disconnect
 */
- (void)resetDevice;

/**
 See if this device is running the most up to date firmware
 */
- (BFTask<NSNumber *> *)checkForFirmwareUpdateAsync;

/**
 Download the latest firmware and put the device in bootloader mode.  Note that
 you will need to use Nordic's DFU library to actaully perform the update:
 https://github.com/NordicSemiconductor/IOS-Pods-DFU-Library
 For example, you can see our sample app for how to integrate DFU into your own app:
 https://github.com/mbientlab/Metawear-SampleiOSApp
 
 Please make sure the device is plugged in or charged above 50% to prevent errors.

 This is one API you can call WITHOUT being connected, there are some cases where
 you can't connect because the firmware is too old, but you still need to be able
 to update it!
 */
- (BFTask<MBLFirmwareUpdateInfo *> *)prepareForFirmwareUpdateAsync;

///----------------------------------
/// @name Debug and Testing Utilities
///----------------------------------

/**
 This causues the device to immediately disconnect with an error.  Useful for testing
 error handling flows.
 */
- (void)simulateDisconnect;


///----------------------------------
/// @name Deprecated
///----------------------------------

@property (nonatomic, readonly, nullable) MBLI2C *i2c DEPRECATED_MSG_ATTRIBUTE("Use serial instead");
@property (nonatomic, readonly) BOOL isGuestConnection DEPRECATED_MSG_ATTRIBUTE("Use programedByOtherApp instead");

- (void)updateFirmwareWithHandler:(MBLErrorHandler)handler
                  progressHandler:(nullable MBLFloatHandler)progressHandler DEPRECATED_MSG_ATTRIBUTE("Use prepareForFirmwareUpdateAsync instead");

- (void)setConfiguration:(nullable id<MBLRestorable>)configuration handler:(nullable MBLErrorHandler)handler DEPRECATED_MSG_ATTRIBUTE("use setConfigurationAsync: instead");
- (void)connectWithHandler:(nullable MBLErrorHandler)handler DEPRECATED_MSG_ATTRIBUTE("use connectAsync instead");
- (void)connectWithTimeout:(NSTimeInterval)timeout handler:(nullable MBLErrorHandler)handler DEPRECATED_MSG_ATTRIBUTE("use connectWithTimeoutAsync instead");
- (void)disconnectWithHandler:(nullable MBLErrorHandler)handler DEPRECATED_MSG_ATTRIBUTE("use disconnectAsync instead");
- (void)readBatteryLifeWithHandler:(MBLNumberHandler)handler DEPRECATED_MSG_ATTRIBUTE("use readBatteryLifeAsync instead");
- (void)readRSSIWithHandler:(MBLNumberHandler)handler DEPRECATED_MSG_ATTRIBUTE("use readRSSIAsync instead");
- (void)checkForFirmwareUpdateWithHandler:(MBLBoolHandler)handler DEPRECATED_MSG_ATTRIBUTE("use checkForFirmwareUpdateAsync instead");
- (void)prepareForFirmwareUpdateWithHandler:(MBLFirmwareUpdateHandler)handler DEPRECATED_MSG_ATTRIBUTE("use prepareForFirmwareUpdateAsync instead");
- (void)synchronize DEPRECATED_MSG_ATTRIBUTE("use synchronizeAsync instead");

@end

NS_ASSUME_NONNULL_END
