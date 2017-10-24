/**
 * MBLFirmwareUpdateManager.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 10/9/14.
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

#import "MBLFirmwareUpdateManager.h"
#import "MBLMetaWear+Private.h"
#import "MBLAnalytics.h"
#import "MBLConstants.h"
#import "MBLDeviceInfo.h"
#import "MBLMetaWearManager+Private.h"
#import "MBLConstants+Private.h"
#import "BFTask+MBLExtensions.h"
#import "MBLLogger.h"


@interface MBLFirmwareUpdateManager() <CBCentralManagerDelegate, CBPeripheralDelegate>
@property (nonatomic) MBLFirmwareBuild *firmware;
@property (nonatomic) NSUUID *identifier;

@property (nonatomic) BFTaskCompletionSource *source;
@property (nonatomic) BOOL updateDone;
@property (nonatomic) int recoveryTries;
@property (nonatomic) NSTimer *connectionWatchdog;
@property (nonatomic) NSError *recievedError;
@property (nonatomic) NSString *modelNumber;
@property (nonatomic) NSString *hardwareRev;

@property (nonatomic) CBCentralManager *centralManager;
@property (nonatomic) CBPeripheral *peripheral;
@end

@implementation MBLFirmwareUpdateManager

- (instancetype)initWithFirmware:(MBLFirmwareBuild *)firmware
                      identifier:(NSUUID *)identifier
{
    self = [super init];
    if (self) {
        self.firmware = firmware;
        self.identifier = identifier;
        
        self.updateDone = NO;
        self.recoveryTries = 2;
    }
    return self;
}

- (BFTask<MBLFirmwareUpdateInfo *> *)startUpdate
{
    self.source = [BFTaskCompletionSource taskCompletionSource];
    // We assume that we just call the "jump to bootloader" on the MetaWear so we give it some
    // time to reset and get into the bootloader.  This wait time is ad-hoc, but experiments
    // show it works well
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    });
    return self.source.task;
}

+ (BFTask<NSArray<MBLFirmwareBuild *> *> *)getAllFirmwareForDeviceAsync:(MBLDeviceInfo *)device
{
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    // To get the latest firmware version we parse the json from our website, make sure to do
    // this on a backgroud thread to avoid hanging the UI.
    NSURL *url = [NSURL URLWithString:@"https://mbientlab.com/releases/metawear/info1.json"];
    [[NSURLSession.sharedSession dataTaskWithRequest:[[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10] completionHandler:^(NSData *data, NSURLResponse * response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (error) {
            [source trySetError:error];
            return;
        } else if (httpResponse.statusCode != 200) {
            [source trySetError:[NSError errorWithDomain:kMBLErrorDomain
                                                    code:kMBLErrorNoAvailableFirmware
                                                userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Firmware URL %@ returned code %ld", url, (long)httpResponse.statusCode]}]];
            return;
        }
        
        NSMutableArray<MBLFirmwareBuild *> *allFirmwares = [NSMutableArray array];
        NSDictionary *info = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (info) {
            NSString *buildFlavor = @"vanilla";
            NSString *hardwareRev = device.hardwareRevision ? device.hardwareRevision : @"0.1";
            NSString *modelNumber = device.modelNumber ? device.modelNumber : @"0";
            // The info1.json is a nested dictionary
            NSDictionary *potentialVersions = info[hardwareRev][modelNumber][buildFlavor];
            NSSet *validVersions = [potentialVersions keysOfEntriesPassingTest:^BOOL(NSString *key, NSDictionary *obj, BOOL *stop) {
                return ![MBLConstants versionString:kMBLAPIVersion isLessThan:obj[@"min-ios-version"]];
            }];
            NSArray *sortedVersions = [validVersions sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES]]];
            for (NSString *version in sortedVersions) {
                [allFirmwares addObject:[[MBLFirmwareBuild alloc] initWithHardwareRev:hardwareRev
                                                                          modelNumber:modelNumber
                                                                          buildFlavor:buildFlavor
                                                                          firmwareRev:version
                                                                             filename:potentialVersions[version][@"filename"]]];
            }
        }
        if (allFirmwares.count == 0) {
            [source trySetError:[NSError errorWithDomain:kMBLErrorDomain
                                                    code:kMBLErrorNoAvailableFirmware
                                                userInfo:@{NSLocalizedDescriptionKey : @"No valid firmware releases found.  Please update your application and if problem persists, email developers@mbientlab.com"}]];
            return;
        }
        [source trySetResult:allFirmwares];
    }] resume];
    return source.task;
}

+ (BFTask<MBLFirmwareBuild *> *)getLatestFirmwareForDeviceAsync:(MBLDeviceInfo *)device
{
    return [[MBLFirmwareUpdateManager getAllFirmwareForDeviceAsync:device] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask<NSArray<MBLFirmwareBuild *> *> *t) {
        return t.result.lastObject;
    }];
}


- (void)attemptRecoveryWithError:(NSError *)error
{
    // Lets cache only the first encountered error
    if (!self.recievedError) {
        self.recievedError = error;
    }
    // See if we have any retries remaining
    if (self.recoveryTries) {
        self.recoveryTries--;
        // Clear all the state and wait a few seconds before firing up the scanner again
        self.updateDone = NO;
        self.centralManager = nil;
        [self.connectionWatchdog invalidate];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        });
    } else {
        // If out of retries then report the first encountered error
        [self.source trySetError:self.recievedError];
    }
}

- (BOOL)sanityCheck
{
    // If we were given a firmware model, it damn well better match
    if (self.firmware.modelNumber && self.modelNumber) {
        // Sanity check the model number
        if (![self.modelNumber isEqualToString:self.firmware.modelNumber]) {
            self.recoveryTries = 0;
            [self attemptRecoveryWithError:[NSError errorWithDomain:kMBLErrorDomain
                                                               code:kMBLErrorWrongFirmwareModelNumber
                                                           userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Couldn't perform DFU, bad model number given.  Given %@, but expected %@", self.firmware.modelNumber, self.modelNumber]}]];
            return NO;
        }
    }
    // If we were given a hardware rev, it damn well better match
    if (self.firmware.hardwareRev && self.hardwareRev) {
        // Sanity check the model number
        if (![self.hardwareRev isEqualToString:self.firmware.hardwareRev]) {
            self.recoveryTries = 0;
            [self attemptRecoveryWithError:[NSError errorWithDomain:kMBLErrorDomain
                                                               code:kMBLErrorWrongFirmwareModelNumber
                                                           userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Couldn't perform DFU, bad hardware rev given.  Given %@, but expected %@", self.firmware.hardwareRev, self.hardwareRev]}]];
            return NO;
        }
    }
    // Make sure local file is ready to go
    if (!self.firmware.firmwareLocalFile) {
        [self attemptRecoveryWithError:[NSError errorWithDomain:kMBLErrorDomain
                                                           code:kMBLErrorOperationInvalid
                                                       userInfo:@{NSLocalizedDescriptionKey : @"Couldn't perform DFU, firmware wasn't downloaded first."}]];
        return NO;
    }
    return YES;
}

- (void)modelNumberReadFinished
{
    // Exit if sanity isn't found
    if (![self sanityCheck]) {
        return;
    }
    // Report the successful result!
    self.peripheral.delegate = nil;
    self.centralManager.delegate = nil;
    [self.source trySetResult:[[MBLFirmwareUpdateInfo alloc] initWithFirmwareUrl:self.firmware.firmwareLocalFile
                                                                          target:self.peripheral
                                                                  centralManager:self.centralManager]];
}

- (void)connectionWatchdogTimeout:(NSTimer *)timer
{
    [self.centralManager stopScan];
    [self attemptRecoveryWithError:[NSError errorWithDomain:kMBLErrorDomain
                                                       code:kMBLErrorNoFirmwareUpdater
                                                   userInfo:@{NSLocalizedDescriptionKey : @"MetaWear device didn't enter firmware update mode.  Please wait 60 seconds and try update again."}]];
}


#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        case CBCentralManagerStateUnknown:
        case CBCentralManagerStateResetting:
            // Updates are imminent, so wait
            break;
        case CBCentralManagerStateUnsupported:
            [self.source trySetError:[NSError errorWithDomain:kMBLErrorDomain
                                                    code:kMBLErrorBluetoothUnsupported
                                                userInfo:@{NSLocalizedDescriptionKey : @"The platform doesn't support the Bluetooth Low Energy Central/Client role."}]];
        case CBCentralManagerStateUnauthorized:
            [self.source trySetError:[NSError errorWithDomain:kMBLErrorDomain
                                                    code:kMBLErrorBluetoothUnauthorized
                                                userInfo:@{NSLocalizedDescriptionKey : @"The application is not authorized to use the Bluetooth Low Energy Central/Client role."}]];
        case CBCentralManagerStatePoweredOff:
            [self.source trySetError:[NSError errorWithDomain:kMBLErrorDomain
                                                    code:kMBLErrorBluetoothPoweredOff
                                                userInfo:@{NSLocalizedDescriptionKey : @"Core Bluetooth Error.  Please ensure bluetooth is enabled."}]];
        case CBCentralManagerStatePoweredOn:
            // As soon as the central is ready, start scanning!
            [self.centralManager scanForPeripheralsWithServices:@[[MBLConstants DFUServiceUUID]] options:nil];
            MBLLog(MBLLogLevelInfo, @"Scanning for MetaBoot...");
            // For saftey we set up a timer, and will signal error if we fail to find the
            // requested MetaBoot device within 10 seconds
            self.connectionWatchdog = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(connectionWatchdogTimeout:) userInfo:nil repeats:NO];
            break;
#pragma clang diagnostic pop
    }
}

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    if ((self.identifier == nil) || [peripheral.identifier isEqual:self.identifier]) {
        MBLLog(MBLLogLevelInfo, @"Found MetaBoot");
        // We found what we were looking for so stop the scan and let the DFU code know what device to update
        self.identifier = peripheral.identifier;
        [self.connectionWatchdog invalidate];
        [central stopScan];
        self.peripheral = peripheral;
        [central connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    peripheral.delegate = self;
    [peripheral discoverServices:@[[MBLConstants DISServiceUUID]]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self attemptRecoveryWithError:error];
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [self attemptRecoveryWithError:error];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        [self attemptRecoveryWithError:error];
        return;
    }
    for (CBService *service in peripheral.services) {
        if ([service.UUID isEqual:[MBLConstants DISServiceUUID]]) {
            [peripheral discoverCharacteristics:@[[MBLConstants DISModelNumberUUID], [MBLConstants DISHardwareRevUUID]] forService:service];
            return;
        }
    }
    [self modelNumberReadFinished];
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    if (error) {
        [self attemptRecoveryWithError:error];
        return;
    }
    if ([service.UUID isEqual:[MBLConstants DISServiceUUID]]) {
        NSMutableArray *characteristicsToRead = [NSMutableArray array];
        for (CBCharacteristic *characteristic in service.characteristics) {
            if ([characteristic.UUID isEqual:[MBLConstants DISModelNumberUUID]] ||
                [characteristic.UUID isEqual:[MBLConstants DISHardwareRevUUID]]) {
                [characteristicsToRead addObject:characteristic];
            }
        }
        if (characteristicsToRead.count == 2) {
            for (CBCharacteristic *characteristic in characteristicsToRead) {
                [peripheral readValueForCharacteristic:characteristic];
            }
            return;
        }
    }
    [self modelNumberReadFinished];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        [self attemptRecoveryWithError:error];
        return;
    }
    if ([characteristic.UUID isEqual:[MBLConstants DISModelNumberUUID]]) {
        self.modelNumber = [[NSString alloc] initWithBytes:characteristic.value.bytes
                                                    length:characteristic.value.length
                                                  encoding:NSASCIIStringEncoding];
    }
    if ([characteristic.UUID isEqual:[MBLConstants DISHardwareRevUUID]]) {
        self.hardwareRev = [[NSString alloc] initWithBytes:characteristic.value.bytes
                                                    length:characteristic.value.length
                                                  encoding:NSASCIIStringEncoding];
    }
    if (self.modelNumber && self.hardwareRev) {
        [self modelNumberReadFinished];
    }
}

@end
