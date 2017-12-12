/**
 * MBLConstants.m
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

#import "MBLConstants.h"
#import "MBLConstants+Private.h"

NSString *const kMBLAPIVersion = @"2.10.0";
// This needs to get stepped any time we change the layout of any of the classes,
// adding or removing member variables, ect.  Or otherwise need apps to have their
// cache cleared when updating to this API.
NSString *const kMBLBinaryVersion = @"1";

NSString *MBLFirmwareVersionString(MBLFirmwareVersion version)
{
    switch (version) {
        case MBLFirmwareVersion1_0_4:
            return @"1.0.4";
        case MBLFirmwareVersion1_0_5:
            return @"1.0.5";
        case MBLFirmwareVersion1_0_6:
            return @"1.0.6";
        case MBLFirmwareVersion1_0_7:
            return @"1.0.7";
        case MBLFirmwareVersion1_1_0:
            return @"1.1.0";
        case MBLFirmwareVersion1_1_1:
            return @"1.1.1";
        case MBLFirmwareVersion1_1_2:
            return @"1.1.2";
        case MBLFirmwareVersion1_2_0:
            return @"1.2.0";
        case MBLFirmwareVersion1_2_1:
            return @"1.2.1";
        case MBLFirmwareVersion1_2_2:
            return @"1.2.2";
        case MBLFirmwareVersion1_2_3:
            return @"1.2.3";
        case MBLFirmwareVersion1_2_4:
            return @"1.2.4";
        case MBLFirmwareVersion1_2_5:
            return @"1.2.5";
        case MBLFirmwareVersion1_3_0:
            return @"1.3.0";
        case MBLFirmwareVersion1_3_1:
            return @"1.3.1";
        case MBLFirmwareVersion1_3_2:
            return @"1.3.2";
        case MBLFirmwareVersion1_3_3:
            return @"1.3.3";
        case MBLFirmwareVersion1_3_4:
            return @"1.3.4";
        case MBLFirmwareVersion1_3_5:
            return @"1.3.5";
        case MBLFirmwareVersion1_3_6:
            return @"1.3.6";
    }
}

NSString *MBLModelString(MBLModel model)
{
    switch (model) {
        case MBLModelUnknown:
            return @"Unknown";
        case MBLModelMetaWearR:
            return @"MetaWear R";
        case MBLModelMetaWearRG:
            return @"MetaWear RG";
        case MBLModelMetaWearRPro:
            return @"MetaWear RPro";
        case MBLModelMetaWearC:
            return @"MetaWear C";
        case MBLModelMetaWearCPro:
            return @"MetaWear CPro";
        case MBLModelMetaEnvironment:
            return @"MetaEnvironment";
        case MBLModelMetaDetector:
            return @"MetaDetector";
        case MBLModelMetaHealth:
            return @"MetaHealth";
        case MBLModelMetaTracker:
            return @"MetaTracker";
        case MBLModelMetaMotionR:
            return @"MetaMotion R";
        case MBLModelMetaMotionC:
            return @"MetaMotion C";
    }
}

NSString *MBLCalibrationAccuracyString(MBLCalibrationAccuracy accuracy)
{
    switch (accuracy) {
        case MBLCalibrationAccuracyUnreliable:
            return @"Unreliable";
        case MBLCalibrationAccuracyLow:
            return @"Low";
        case MBLCalibrationAccuracyMedium:
            return @"Medium";
        case MBLCalibrationAccuracyHigh:
            return @"High";
    }
}

#pragma mark - Errors

NSString *const kMBLErrorDomain = @"com.mbientlab";

NSInteger const kMBLErrorUnexpectedServices = 100;
NSInteger const kMBLErrorUnexpectedCharacteristics = 101;
NSInteger const kMBLErrorNoFirmwareUpdater = 102;
NSInteger const kMBLErrorInvalidMetaWearObject = 103;
NSInteger const kMBLErrorInsufficientCharge = 104;
NSInteger const kMBLErrorOutdatedFirmware = 105;
NSInteger const kMBLErrorUnexpectedDisconnect = 106;
NSInteger const kMBLErrorConnectionTimeout = 107;
NSInteger const kMBLErrorWrongFirmwareModelNumber = 108;
NSInteger const kMBLErrorNoAvailableFirmware = 109;
NSInteger const kMBLErrorNotConnected = 110;
NSInteger const kMBLErrorInsufficientMemory = 111;
NSInteger const kMBLErrorOperationInvalid = 112;
NSInteger const kMBLErrorUnexpectedData = 113;
NSInteger const kMBLErrorUnexpectedException = 114;
NSInteger const kMBLErrorBluetoothPoweredOff = 115;
NSInteger const kMBLErrorBluetoothUnsupported = 116;
NSInteger const kMBLErrorBluetoothUnauthorized = 117;


static const uint8_t simulatorKey;
static uint8_t simulatorContext;
static const uint8_t metaWearKey;
static uint8_t metaWearContext;

@implementation MBLConstants

+ (dispatch_queue_t)metaWearQueue;
{
    static dispatch_queue_t singleton;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        singleton = dispatch_queue_create("com.mbientlab.metawear.metaWearQueue", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(singleton, &metaWearKey, &metaWearContext, nil);
    });
    return singleton;
}

+ (dispatch_queue_t)simulatorQueue
{
    static dispatch_queue_t singleton;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        singleton = dispatch_queue_create("com.mbientlab.metawear.simulator", DISPATCH_QUEUE_SERIAL);
        dispatch_queue_set_specific(singleton, &simulatorKey, &simulatorContext, nil);
    });
    return singleton;
}

+ (BOOL)isSimulatorQueue
{
    return (&simulatorContext == dispatch_get_specific(&simulatorKey));
}

+ (BOOL)isMetaWearQueue
{
    return ((&metaWearContext == dispatch_get_specific(&metaWearKey)) || [MBLConstants isSimulatorQueue]);
}

+ (CBUUID *)serviceUUID
{
    return [CBUUID UUIDWithString:@"326A9000-85CB-9195-D9DD-464CFBBAE75A"];
}
+ (CBUUID *)commandUUID
{
    return [CBUUID UUIDWithString:@"326A9001-85CB-9195-D9DD-464CFBBAE75A"];
}
+ (CBUUID *)notificationUUID
{
    return [CBUUID UUIDWithString:@"326A9006-85CB-9195-D9DD-464CFBBAE75A"];
}

+ (CBUUID *)DFUServiceUUID
{
    return [CBUUID UUIDWithString:@"00001530-1212-EFDE-1523-785FEABCD123"];
}

+ (CBUUID *)batteryServiceUUID
{
    return [CBUUID UUIDWithString:@"180F"];
}
+ (CBUUID *)batteryLifeUUID
{
    return [CBUUID UUIDWithString:@"2A19"];
}

+ (CBUUID *)DISServiceUUID
{
    return [CBUUID UUIDWithString:@"180A"];
}
+ (CBUUID *)DISModelNumberUUID
{
    return [CBUUID UUIDWithString:@"2A24"];
}
+ (CBUUID *)DISSerialNumberUUID
{
    return [CBUUID UUIDWithString:@"2A25"];
}
+ (CBUUID *)DISFirmwareRevUUID
{
    return [CBUUID UUIDWithString:@"2A26"];
}
+ (CBUUID *)DISHardwareRevUUID
{
    return [CBUUID UUIDWithString:@"2A27"];
}
+ (CBUUID *)DISManufacturerNameUUID
{
    return [CBUUID UUIDWithString:@"2A29"];
}

+ (BOOL)versionString:(NSString *)a isLessThan:(NSString *)b
{
    NSArray *aVersion = [a componentsSeparatedByString:@"."];
    NSArray *bVersion = [b componentsSeparatedByString:@"."];
    long size = MIN(aVersion.count, bVersion.count);
    
    for (int i = 0; i < size; i++) {
        if ([aVersion[i] intValue] == [bVersion[i] intValue]) {
            continue;
        }
        return [aVersion[i] intValue] < [bVersion[i] intValue];
    }
    return aVersion.count < bVersion.count;
}

#define CLAMP(x, low, high) ({\
__typeof__(x) __x = (x); \
__typeof__(low) __low = (low);\
__typeof__(high) __high = (high);\
__x > __high ? __high : (__x < __low ? __low : __x);\
})

+ (double)clampDouble:(double)x low:(double)low high:(double)high
{
    return CLAMP(x, low, high);
}

+ (double)clampInt:(int)x low:(int)low high:(int)high
{
    return CLAMP(x, low, high);
}

@end
