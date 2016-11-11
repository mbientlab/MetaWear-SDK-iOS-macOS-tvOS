/**
 * MBLMetaWearManager.m
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

#import "MBLMetaWearManager.h"
#import "MBLMetaWearManager+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLCategoryLoader.h"
#import "MBLAnalytics.h"
#import "MBLFirmwareBuild.h"
#import "MBLDeviceInfo.h"
#import "BFTask+MBLExtensions.h"
#import "FastCoder.h"
#import "MBLBluetoothCentralMock.h"
#import "MBLConstants+Private.h"
#import "MBLLogger.h"

#import <CoreBluetooth/CoreBluetooth.h>

static NSString * const kMBLRememberedDevicesKey = @"com.mbientlab.metawear.rememberedDevices";
static NSString * const kMBLApiVersionKey = @"com.mbientlab.metawear.apiversion";

#if TARGET_OS_SIMULATOR
static BOOL useMockManager = YES;
#else
static BOOL useMockManager = NO;
#endif
void MBLSetUseMockManager(BOOL useMock) { useMockManager = useMock; }

@interface MBLMetaWearManager() <MBLBluetoothCentralDelegate, CBCentralManagerDelegate>

@property (nonatomic) id<MBLBluetoothCentral> centralManager;
@property (nonatomic) NSMutableArray *discoveredMetaWears;
@property (nonatomic) NSMutableArray *discoveredMetaBoots;
@property (nonatomic) NSMutableArray *metaWearBlocks;
@property (nonatomic) NSMutableArray *metaBootBlocks;
@property (nonatomic) NSMutableDictionary *peripheralToMetaWear;

@property (nonatomic) NSNumber *allowDuplicates;
@property (nonatomic) NSArray *services;
@property BOOL isScanningMetaWears;
@property BOOL isScanningMetaBoots;
@property (nonatomic) NSMutableArray *centralStateUpdateSources;
@property (nonatomic) NSObject *centralStateUpdateSourcesMutex;
@property (nonatomic, copy) MBLCentralManagerStateHandler stateHandler;

@property (nonatomic) MBLFirmwareBuild *latestFirmware;

- (instancetype)init;
- (void)startScan;
@end


@implementation MBLMetaWearManager

+ (void)initialize {
    if (self == [MBLMetaWearManager class]) {
        // Load all private categories, that we have...
        // Without this call - private categories - will require `-ObjC` in linker flags.
        // By explicitly calling empty method - we can avoid that.
        [MBLCategoryLoader loadPrivateCategories];
    }
}

+ (nonnull instancetype)sharedManager
{
    static MBLMetaWearManager *singleton = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        singleton = [[MBLMetaWearManager alloc] init];
    });
	return singleton;
}

+ (NSOperationQueue *)dispatchQueue
{
    return [MBLMetaWearManager sharedManager].dispatchQueue;
}

- (void)startBluetoothStateNotificationsWithHandler:(MBLCentralManagerStateHandler)handler
{
    self.stateHandler = handler;
    if (handler) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        handler((CBCentralManagerState)self.centralManager.state);
#pragma clang diagnostic pop
    }
}

- (void)stopBluetoothStateNotifications
{
    self.stateHandler = nil;
}

- (void)retrieveSavedMetaWearsWithHandler:(MBLArrayHandler)handler
{
    if (handler) {
        [[self retrieveSavedMetaWearsAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask<NSArray<MBLMetaWear *> *> * _Nonnull task) {
            handler(task.result);
            return nil;
        }];
    }
}

- (BFTask<NSArray<MBLMetaWear *> *> *)retrieveSavedMetaWearsAsync
{
    // If the central isn't ready, save the handler and we will call later on once its ready
    BFTask *head = [BFTask taskWithResult:nil];
    switch (self.centralManager.state) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        case CBCentralManagerStateUnknown:
        case CBCentralManagerStateResetting:
            // Updates are imminent, so wait
            @synchronized(self.centralStateUpdateSourcesMutex) {
                BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
                [self.centralStateUpdateSources addObject:source];
                head = source.task;
            }
            break;
        case CBCentralManagerStateUnsupported:
            return [BFTask taskWithError:[NSError errorWithDomain:kMBLErrorDomain
                                                             code:kMBLErrorBluetoothUnsupported
                                                         userInfo:@{NSLocalizedDescriptionKey : @"The platform doesn't support the Bluetooth Low Energy Central/Client role."}]];
        case CBCentralManagerStateUnauthorized:
            return [BFTask taskWithError:[NSError errorWithDomain:kMBLErrorDomain
                                                             code:kMBLErrorBluetoothUnauthorized
                                                         userInfo:@{NSLocalizedDescriptionKey : @"The application is not authorized to use the Bluetooth Low Energy Central/Client role."}]];
        case CBCentralManagerStatePoweredOff:
            return [BFTask taskWithError:[NSError errorWithDomain:kMBLErrorDomain
                                                             code:kMBLErrorBluetoothPoweredOff
                                                         userInfo:@{NSLocalizedDescriptionKey : @"Core Bluetooth Error.  Please ensure bluetooth is enabled."}]];
        case CBCentralManagerStatePoweredOn:
            // Nothing to wait on!
            break;
#pragma clang diagnostic pop

    }
    
    return [head continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        // We first get the saved CBPeripheral identifiers.
        NSArray *rememberedDevices = [[NSUserDefaults standardUserDefaults] arrayForKey:kMBLRememberedDevicesKey];
        NSMutableArray *identifiers = [NSMutableArray arrayWithCapacity:rememberedDevices.count];
        for (NSString *identifier in rememberedDevices) {
            [identifiers addObject:[[NSUUID alloc] initWithUUIDString:identifier]];
        }
        // Then get usable CBPeripheral objects from the central based on those identifiers
        NSArray *peripherals = [self.centralManager retrievePeripheralsWithIdentifiers:identifiers];
        NSMutableArray *metaWears = [NSMutableArray arrayWithCapacity:peripherals.count];
        // And finally convert those CBPeripheral's to MBLMetaWears!
        for (id<MBLBluetoothPeripheral> peripheral in peripherals) {
            [metaWears addObject:[self metawearFromPeripheral:peripheral andAdvertisementData:nil RSSI:nil]];
        }
        return metaWears;
    }];
}

- (void)startScanForMetaWears:(BOOL)metaWears metaBoots:(BOOL)metaBoots duplicates:(NSNumber *)duplicates handler:(MBLArrayHandler)handler;
{
    assert(handler);
    if (metaWears) {
        [self.metaWearBlocks addObject:handler];
        if (self.discoveredMetaWears.count) {
            handler(self.discoveredMetaWears);
        }
    }
    if (metaBoots) {
        [self.metaBootBlocks addObject:handler];
        if (self.discoveredMetaBoots.count) {
            handler(self.discoveredMetaBoots);
        }
    }
    
    if ((!self.isScanningMetaWears && metaWears) || (!self.isScanningMetaBoots && metaBoots)) {
        self.allowDuplicates = duplicates;
        NSMutableArray *services = [NSMutableArray array];
        if (metaWears) {
            [services addObject:[MBLConstants serviceUUID]];
        }
        if (metaBoots) {
            [services addObject:[MBLConstants DFUServiceUUID]];
        }
        self.services = services;
        
        // Fire up scanning if the central is ready for it, otherwise it will get
        // turned on later when its ready
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if (self.centralManager.state == CBCentralManagerStatePoweredOn) {
#pragma clang diagnostic pop
            [self startScan];
        }
    }
}

- (void)startScanForMetaWearsWithHandler:(MBLArrayHandler)handler
{
    [self startScanForMetaWears:YES metaBoots:NO duplicates:@NO handler:handler];
}

- (void)startScanForMetaWearsAllowDuplicates:(BOOL)duplicates handler:(MBLArrayHandler)handler
{
    [self startScanForMetaWears:YES metaBoots:NO duplicates:duplicates ? @YES : @NO handler:handler];
}

- (void)startScanForMetaBootsAllowDuplicates:(BOOL)duplicates handler:(MBLArrayHandler)handler
{
    [self startScanForMetaWears:NO metaBoots:YES duplicates:duplicates ? @YES : @NO handler:handler];
}

- (void)stopScan
{
    [self.centralManager stopScan];
    
    [self.metaWearBlocks removeAllObjects];
    [self.metaBootBlocks removeAllObjects];
    self.allowDuplicates = nil;
    self.services = nil;
    self.isScanningMetaWears = NO;
    self.isScanningMetaBoots = NO;
}

- (void)connectMetaWear:(MBLMetaWear *)device
{
    // When a MetaWear disconnects we nil out it's CBPeripheral, if the user wants
    // to connect to it again ask the central for a fresh CBPeripheral
    if (!device.peripheral) {
        id<MBLBluetoothPeripheral> peripheral = [[self.centralManager retrievePeripheralsWithIdentifiers:@[device.identifier]] firstObject];
        if (!peripheral) {
            [device didDisconnect:[NSError errorWithDomain:kMBLErrorDomain
                                                      code:kMBLErrorInvalidMetaWearObject
                                                  userInfo:@{NSLocalizedDescriptionKey : @"Couldn't retrieve peripheral.  Please remove and re-install app to clear cache."}]];
            return;
        }
        device.peripheral = peripheral;
        peripheral.delegate = device;
        self.peripheralToMetaWear[peripheral] = device;
    }
    // Short cut if its already connected
    if (device.state == MBLConnectionStateConnected) {
        [device didConnect];
    } else {
        // Otherwise start the connection flow
        [self.centralManager connectPeripheral:device.peripheral options:nil];
    }
}

- (void)disconnectMetaWear:(MBLMetaWear *)device fromPeripheralSide:(BOOL)fromPeripheralSide
{
    // Take the short cut if we're already disconnected!
    if (device.state == MBLConnectionStateDisconnected) {
        [device didDisconnect:nil];
    } else {
        if (fromPeripheralSide) {
            [device.testDebug triggerDisconnect];
        } else {
            if (device.peripheral) {
                [self.centralManager cancelPeripheralConnection:device.peripheral];
            }
        }
    }
}

- (void)rememberMetaWear:(MBLMetaWear *)device
{
    // Get or create an array to hold all the remembered device identifiers
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *devices = [defaults arrayForKey:kMBLRememberedDevicesKey];
    NSArray *newDevices = nil;
    // Add the new device identifier if needed
    if (devices) {
        if (![devices containsObject:device.identifier.UUIDString]) {
            NSMutableArray *tmp = [devices mutableCopy];
            [tmp addObject:device.identifier.UUIDString];
            newDevices = tmp;
        } else {
            newDevices = devices;
        }
    } else {
        newDevices = @[device.identifier.UUIDString];
    }
    // Save the array back to disk
    [defaults setObject:newDevices forKey:kMBLRememberedDevicesKey];
    [defaults synchronize];
}

- (void)forgetMetaWear:(MBLMetaWear *)device
{
    // Remove the identifier from the remembered device array
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *devices = [defaults arrayForKey:kMBLRememberedDevicesKey];
    if (devices) {
        NSMutableArray *tmp = [devices mutableCopy];
        [tmp removeObject:device.identifier.UUIDString];
        [defaults setObject:tmp forKey:kMBLRememberedDevicesKey];
        [defaults synchronize];
    }
}

- (void)clearDiscoveredDevices
{
    [self.discoveredMetaWears removeAllObjects];
    [self.discoveredMetaBoots removeAllObjects];
    [self.peripheralToMetaWear removeAllObjects];
}

#pragma mark - Private helpers

- (instancetype)init
{
    self = [super init];
    if (self) {
        dispatch_queue_t bleQueue = dispatch_queue_create("com.mbientlab.metawear.bleQueue", DISPATCH_QUEUE_SERIAL);
        //self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_queue_create("com.mbientlab.metawear.bleQueue", DISPATCH_QUEUE_SERIAL) options:@{ CBCentralManagerOptionRestoreIdentifierKey:@"com.mbientlab.centralManager"}];
        NSString *version = nil;
        if (useMockManager) {
            self.centralManager = [[MBLBluetoothCentralMock alloc] initWithDelegate:self queue:bleQueue options:nil];
        } else {
            self.centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:bleQueue options:nil];
            version = [[NSUserDefaults standardUserDefaults] stringForKey:kMBLApiVersionKey];
        }
        self.discoveredMetaWears = [NSMutableArray array];
        self.discoveredMetaBoots = [NSMutableArray array];
        self.metaWearBlocks = [NSMutableArray array];
        self.metaBootBlocks = [NSMutableArray array];
        self.peripheralToMetaWear = [NSMutableDictionary dictionary];
        self.dispatchQueue = [NSOperationQueue mainQueue];
        
        self.isScanningMetaWears = NO;
        self.isScanningMetaBoots = NO;
        self.minimumRequiredVersion = MBLFirmwareVersion1_0_4;
        self.logLevel = MBLLogLevelWarning;
        
        self.centralStateUpdateSources = [NSMutableArray array];
        self.centralStateUpdateSourcesMutex = [[NSObject alloc] init];
        
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        // Don't catch expections
        BFTaskSetCatchesExceptions(NO);
#pragma clang diagnostic pop
        
        // If the app changes its API version then we must delete all the cached MBLMetaWear objects,
        // since they are no longer valid
        if (!version || ![version isEqualToString:kMBLAPIVersion]) {
            // Don't use MBLLog since it needs to reference the MetaWearManager which we are setting up now
            NSLog(@"Clearing! %@ -> %@", version, kMBLAPIVersion);
            [[NSUserDefaults standardUserDefaults] setObject:kMBLAPIVersion forKey:kMBLApiVersionKey];
            // When the api version changes in an app you will need to reprogram devices
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kMBLRememberedDevicesKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            // Delete the cachce folder
            NSError *error;
            BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[self logFilename:nil] error:&error];
            if (error) { NSLog(@"%@", error); }
            assert(success);
        }
    }
    return self;
}

- (void)startScan
{
    if ([self.services containsObject:[MBLConstants serviceUUID]]) {
        self.isScanningMetaWears = YES;
    }
    if ([self.services containsObject:[MBLConstants DFUServiceUUID]]) {
        self.isScanningMetaBoots = YES;
    }
    [self.centralManager scanForPeripheralsWithServices:self.services
                                                options:@{CBCentralManagerScanOptionAllowDuplicatesKey : self.allowDuplicates}];
                                                        //CBCentralManagerOptionRestoreIdentifierKey : @"MetaWearCentral"}];
}

- (NSString *)logFilename:(NSString *)filename
{
// tvOS isn't big on persistent local storage, long term we may want to use
// CloudKit or some other supported thing
// https://realm.io/news/is-tvos-the-future-of-apps/
#if TARGET_OS_TV
    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
#else
    NSArray *urls = [[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask];
#endif
    if (urls.count) {
        NSURL *url = urls[0];
        url = [url URLByAppendingPathComponent:@"com.mbientlab.metawear.devices" isDirectory:YES];
        // Make sure we have the folder
        BOOL isDirectory;
        NSError *error;
        if ([[NSFileManager defaultManager] fileExistsAtPath:url.path isDirectory:&isDirectory]) {
            if (!isDirectory) {
                if (![[NSFileManager defaultManager] removeItemAtURL:url error:&error]) {
                    // Don't use MBLLog since it needs to reference the MetaWearManager
                    // which we are setting up now
                    NSLog(@"removeItemAtURL error: %@", error);
                }
            }
        } else {
            isDirectory = NO;
        }
        if (!isDirectory) {
            if (![[NSFileManager defaultManager] createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&error]) {
                NSLog(@"createDirectoryAtURL error: %@", error);
                return nil;
            }
        }
        // Add on the filename
        if (filename) {
            url = [url URLByAppendingPathComponent:filename];
        }
        return url.path;
    }
    NSLog(@"URLsForDirectory:inDomains: nothing found");
    return nil;
}

- (MBLMetaWear *)metawearFromPeripheral:(id<MBLBluetoothPeripheral>)peripheral
                   andAdvertisementData:(NSDictionary *)advertisementData
                                   RSSI:(NSNumber *)RSSI
{
    CBUUID *uuid = [advertisementData[CBAdvertisementDataServiceUUIDsKey] firstObject];
    BOOL isMetaBoot = [uuid isEqual:[MBLConstants DFUServiceUUID]];
    // Updates things we already know about
    NSArray *array = isMetaBoot ? self.discoveredMetaBoots : self.discoveredMetaWears;
    for (MBLMetaWear *device in array) {
        if ([device.identifier isEqual:peripheral.identifier]) {
            device.peripheral = peripheral;
            peripheral.delegate = device;
            [device updateName:peripheral.name];
            device.discoveryTimeRSSI = RSSI;
            self.peripheralToMetaWear[peripheral] = device;
            return device;
        }
    }
    
    // Attempt to load MBLMetaWear from disk
    NSData *data = [NSData dataWithContentsOfFile:[self logFilename:peripheral.identifier.UUIDString]];
    MBLMetaWear *device = [FastCoder objectWithData:data];
    if (!device || [device isKindOfClass:[NSData class]]) {
        device = [[MBLMetaWear alloc] initWithPeripheral:peripheral
                                    andAdvertisementData:advertisementData
                                                 andRSSI:RSSI];
    } else {
        device.peripheral = peripheral;
        peripheral.delegate = device;
        [device updateName:peripheral.name];
        device.discoveryTimeRSSI = RSSI;
    }
    self.peripheralToMetaWear[peripheral] = device;
    if (isMetaBoot) {
        [self.discoveredMetaBoots addObject:device];
    } else {
        [self.discoveredMetaWears addObject:device];
    }
    return device;
}

- (void)stopScanForMetaWears
{
    [self stopScan];
}
- (void)stopScanForMetaBoots
{
    [self stopScan];
}

#pragma mark - CBCentralManagerDelegate

- (void)centralManagerDidUpdateState:(id<MBLBluetoothCentral>)central
{
    MBLCentralManagerStateHandler handler = self.stateHandler;
    if (handler) {
        [self.dispatchQueue addOperationWithBlock:^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            handler((CBCentralManagerState)central.state);
#pragma clang diagnostic pop
        }];
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (central.state == CBCentralManagerStatePoweredOn) {
#pragma clang diagnostic pop
        NSArray *peripherals = [central retrieveConnectedPeripheralsWithServices:@[[MBLConstants serviceUUID]]];
        for (id<MBLBluetoothPeripheral> peripheral in peripherals) {
            [self metawearFromPeripheral:peripheral andAdvertisementData:nil RSSI:nil];
        }
        if ((self.metaWearBlocks.count && !self.isScanningMetaWears) || (self.metaBootBlocks.count && !self.isScanningMetaBoots)) {
            [self startScan];
        }
    } else {
        // TODO: This seems like an iOS bug.  If bluetooth powers off the peripherials disconnect but we don't
        // get a deviceDidDisconnect callback.
        for (MBLMetaWear *device in [self.peripheralToMetaWear allValues]) {
            if (device.state != MBLConnectionStateDisconnected) {
                [device bluetoothPoweredOff];
            }
        }
    }
    
    @synchronized(self.centralStateUpdateSourcesMutex) {
        for (BFTaskCompletionSource *source in self.centralStateUpdateSources) {
            switch (central.state) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                case CBCentralManagerStateUnknown:
                case CBCentralManagerStateResetting:
                    // Updates are imminent, so wait
                    break;
                case CBCentralManagerStateUnsupported:
                    [source trySetError:[NSError errorWithDomain:kMBLErrorDomain
                                                            code:kMBLErrorBluetoothUnsupported
                                                        userInfo:@{NSLocalizedDescriptionKey : @"The platform doesn't support the Bluetooth Low Energy Central/Client role."}]];
                case CBCentralManagerStateUnauthorized:
                    [source trySetError:[NSError errorWithDomain:kMBLErrorDomain
                                                            code:kMBLErrorBluetoothUnauthorized
                                                        userInfo:@{NSLocalizedDescriptionKey : @"The application is not authorized to use the Bluetooth Low Energy Central/Client role."}]];
                case CBCentralManagerStatePoweredOff:
                    [source trySetError:[NSError errorWithDomain:kMBLErrorDomain
                                                            code:kMBLErrorBluetoothPoweredOff
                                                        userInfo:@{NSLocalizedDescriptionKey : @"Core Bluetooth Error.  Please ensure bluetooth is enabled."}]];
                case CBCentralManagerStatePoweredOn:
                    [source trySetResult:nil];
                    break;
#pragma clang diagnostic pop
            }
        }
        [self.centralStateUpdateSources removeAllObjects];
    }
}

- (void)centralManager:(id<MBLBluetoothCentral>)central
 didDiscoverPeripheral:(id<MBLBluetoothPeripheral>)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI
{
    CBUUID *uuid = [advertisementData[CBAdvertisementDataServiceUUIDsKey] firstObject];
    BOOL isMetaBoot = [uuid isEqual:[MBLConstants DFUServiceUUID]];
    [self metawearFromPeripheral:peripheral andAdvertisementData:advertisementData RSSI:RSSI];
    // Make copy incase stop scan is called inside which modifies self.scanForMetaWearBlocks
    NSArray *copyHandlers = isMetaBoot ? [self.metaBootBlocks copy] : [self.metaWearBlocks copy];
    NSArray *copyDevices = isMetaBoot ? [self.discoveredMetaBoots copy] : [self.discoveredMetaWears copy];
    for (MBLArrayHandler callback in copyHandlers) {
        [self.dispatchQueue addOperationWithBlock:^{
            if ((isMetaBoot && self.isScanningMetaBoots) || (!isMetaBoot && self.isScanningMetaWears)) {
                callback(copyDevices);
            }
        }];
    }
}

- (void)centralManager:(id<MBLBluetoothCentral>)central didConnectPeripheral:(id<MBLBluetoothPeripheral>)peripheral
{
    MBLLog(MBLLogLevelInfo, @"Connect: %@", peripheral.description);
    MBLMetaWear *device = self.peripheralToMetaWear[peripheral];
    [device didConnect];
}

- (void)centralManager:(id<MBLBluetoothCentral>)central didFailToConnectPeripheral:(id<MBLBluetoothPeripheral>)peripheral error:(NSError *)error
{
    MBLLog(MBLLogLevelInfo, @"Connect Fail: %@", peripheral.description);
    MBLMetaWear *device = self.peripheralToMetaWear[peripheral];
    [device didDisconnect:error];

}

- (void)centralManager:(id<MBLBluetoothCentral>)central didDisconnectPeripheral:(id<MBLBluetoothPeripheral>)peripheral error:(NSError *)error
{
    MBLLog(MBLLogLevelInfo, @"Disconnect: %@\nError: %@", peripheral.description, error.localizedDescription);
    MBLMetaWear *device = self.peripheralToMetaWear[peripheral];
    if (device.testDebug.triggerDisconnectInProgress && (error.code == CBErrorPeripheralDisconnected || error.code == CBErrorConnectionTimeout)) {
        device.testDebug.triggerDisconnectInProgress = NO;
        [device didDisconnect:nil];
    } else {
        [device didDisconnect:error];
    }
}

//- (void)centralManager:(id<MBLBluetoothCentral>)central willRestoreState:(NSDictionary *)state
//{
//    NSArray *peripherals = state[CBCentralManagerRestoredStatePeripheralsKey];
//    for (id<MBLBluetoothPeripheral> peripheral in peripherals) {
//        [self metawearFromPeripheral:peripheral andAdvertisementData:nil RSSI:nil];
//    }
//}

@end
