/**
 * MBLConstants.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 7/30/14.
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

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
@class MBLAccelerometerData;
@class MBLDeviceInfo;
@class MBLFirmwareBuild;
@class MBLMetaWear;

#if TARGET_OS_IOS || TARGET_OS_TV
#import <UIKit/UIKit.h>
#define MBLColor UIColor
#else
#import <AppKit/AppKit.h>
#define MBLColor NSColor
#endif

NS_ASSUME_NONNULL_BEGIN

extern NSString *const kMBLAPIVersion;

#pragma mark - Enums

/**
 Supported Firmware Versions
 */
typedef NS_ENUM(uint8_t, MBLFirmwareVersion) {
    MBLFirmwareVersion1_0_4,
    MBLFirmwareVersion1_0_5,
    MBLFirmwareVersion1_0_6,
    MBLFirmwareVersion1_0_7,
    MBLFirmwareVersion1_1_0,
    MBLFirmwareVersion1_1_1,
    MBLFirmwareVersion1_1_2,
    MBLFirmwareVersion1_2_0,
    MBLFirmwareVersion1_2_1,
    MBLFirmwareVersion1_2_2,
    MBLFirmwareVersion1_2_3,
    MBLFirmwareVersion1_2_4,
    MBLFirmwareVersion1_2_5,
    MBLFirmwareVersion1_3_0,
    MBLFirmwareVersion1_3_1,
    MBLFirmwareVersion1_3_2,
    MBLFirmwareVersion1_3_3
};
NSString *MBLFirmwareVersionString(MBLFirmwareVersion version);

/**
 Supported models of Meta family of products
 */
typedef NS_ENUM(uint8_t, MBLModel) {
    MBLModelUnknown,
    MBLModelMetaWearR,
    MBLModelMetaWearRG,
    MBLModelMetaWearRPro,
    MBLModelMetaWearC,
    MBLModelMetaWearCPro,
    MBLModelMetaEnvironment,
    MBLModelMetaDetector,
    MBLModelMetaHealth,
    MBLModelMetaTracker,
    MBLModelMetaMotionR,
    MBLModelMetaMotionC
};
NSString *MBLModelString(MBLModel model);

/**
 Verbosity of log messages coming from the MetaWear SDK
 */
typedef NS_ENUM(uint8_t, MBLLogLevel) {
    MBLLogLevelNone = 0,
    MBLLogLevelError = 1,
    MBLLogLevelWarning = 2,
    MBLLogLevelInfo = 3,
    MBLLogLevelDebug = 4
};

/**
 Rating of Sensor Fusion calibration status for data samples
 */
typedef NS_ENUM(uint8_t, MBLCalibrationAccuracy) {
    MBLCalibrationAccuracyUnreliable = 0,
    MBLCalibrationAccuracyLow = 1,
    MBLCalibrationAccuracyMedium = 2,
    MBLCalibrationAccuracyHigh = 3
};
NSString *MBLCalibrationAccuracyString(MBLCalibrationAccuracy accuracy);

#pragma mark - Block Typedefs

typedef void (^MBLVoidHandler)();
typedef void (^MBLErrorHandler)(NSError *__nullable error);
typedef void (^MBLDataHandler)(NSData *__nullable data, NSError *__nullable error);
typedef void (^MBLObjectHandler)(id __nullable obj, NSError *__nullable error);
typedef void (^MBLArrayHandler)(NSArray<MBLMetaWear *> *__nonnull array);
typedef void (^MBLArrayErrorHandler)(NSArray *__nullable array, NSError *__nullable error);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
typedef void (^MBLCentralManagerStateHandler)(CBCentralManagerState state);
#pragma clang diagnostic pop
typedef void (^MBLAccelerometerHandler)(MBLAccelerometerData *__nullable acceleration, NSError *__nullable error);
typedef void (^MBLDeviceInfoHandler)(MBLDeviceInfo *__nullable deviceInfo, NSError *__nullable error);
typedef void (^MBLDecimalNumberHandler)(NSDecimalNumber *__nullable number, NSError *__nullable error);
typedef void (^MBLThresholdHandler)(NSDecimalNumber *__nullable number, BOOL isRising, NSError *__nullable error);
typedef void (^MBLNumberHandler)(NSNumber *__nullable number, NSError *__nullable error);
typedef void (^MBLSwitchStateHandler)(BOOL isPressed, NSError *__nullable error);
typedef void (^MBLBoolHandler)(BOOL isTrue, NSError *__nullable error);
typedef void (^MBLFloatHandler)(float number);
typedef void (^MBLLogProgressHandler)(uint32_t totalEntries, uint32_t remainingEntries);
typedef void (^MBLStringHandler)(NSString *__nullable string);
typedef void (^MBLFirmwareBuildHandler)(MBLFirmwareBuild *__nullable firmware, NSError *__nullable error);
typedef void (^MBLUrlHandler)(NSURL *__nullable url, NSError *__nullable error);
typedef void (^MBLFirmwareUpdateHandler)(NSURL *__nullable firmwareUrl, CBPeripheral *__nullable target, CBCentralManager *__nullable centralManager, NSError *__nullable error);

#pragma mark - Errors

extern NSString *__nonnull const kMBLErrorDomain;

/*! @abstract 100: Unexpected number of bluetooth services */
extern NSInteger const kMBLErrorUnexpectedServices;

/*! @abstract 101: Unexpected number of bluetooth characteristics */
extern NSInteger const kMBLErrorUnexpectedCharacteristics;

/*! @abstract 102: Couldn't connect to firmware updater */
extern NSInteger const kMBLErrorNoFirmwareUpdater;

/*! @abstract 103: MetaWear object not recognized by MetaWearManager */
extern NSInteger const kMBLErrorInvalidMetaWearObject;

/*! @abstract 104: MetaWear not charged enough for firmware update */
extern NSInteger const kMBLErrorInsufficientCharge;

/*! @abstract 105: MetaWear firmware version too old */
extern NSInteger const kMBLErrorOutdatedFirmware;

/*! @abstract 106: Unexpected disconnect during a connection */
extern NSInteger const kMBLErrorUnexpectedDisconnect;

/*! @abstract 107: Timeout during connection */
extern NSInteger const kMBLErrorConnectionTimeout;

/*! @abstract 108: Couldn't perform DFU, bad model number given */
extern NSInteger const kMBLErrorWrongFirmwareModelNumber;

/*! @abstract 109: Couldn't perform DFU, no valid firmware releases found */
extern NSInteger const kMBLErrorNoAvailableFirmware;

/*! @abstract 110: MetaWear not connected, can't perform operation */
extern NSInteger const kMBLErrorNotConnected;

/*! @abstract 111: MetaWear out of memory, can't perform action */
extern NSInteger const kMBLErrorInsufficientMemory;

/*! @abstract 112: Invalid use of API, can't perform action */
extern NSInteger const kMBLErrorOperationInvalid;

/*! @abstract 113: MetaWear had unexpected data */
extern NSInteger const kMBLErrorUnexpectedData;

/*! @abstract 114: Exception */
extern NSInteger const kMBLErrorUnexpectedException;

/*! @abstract 115: Core Bluetooth not powered on correctly */
extern NSInteger const kMBLErrorBluetoothPoweredOff;

/*! @abstract 116: The platform doesn't support the Bluetooth Low Energy Central/Client role */
extern NSInteger const kMBLErrorBluetoothUnsupported;

/*! @abstract 117: The application is not authorized to use the Bluetooth Low Energy Central/Client role.*/
extern NSInteger const kMBLErrorBluetoothUnauthorized;

/*! @abstract 118: Requested a disconnect while a connection was in progress .*/
extern NSInteger const kMBLErrorDisconnectRequested;

/*! @abstract 119: DFU service was found during a connection .*/
extern NSInteger const kMBLErrorDFUServiceFound;

NS_ASSUME_NONNULL_END
