/**
 * MBLBluetoothPeripheralMock.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 9/23/16.
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

#import "MBLBluetoothPeripheralMock.h"
#import "MBLMockUtils.h"
#import "MBLModuleMock.h"
#import "MBLMetaWear+Private.h"
#import "MBLConstants+Private.h"

/*
 Please forgive this hack - since CBMutableCharacteristic and CBMutableService
 arn't allowed on tvOS we create a plain old NSObject with all the properties 
 of interest and just cast it to the CB types - again sorry for the hack
 */
@interface MBLServiceCharacteristicMock : NSObject
@property(retain, readwrite, nonatomic, nullable) CBUUID *UUID;
@property(assign, readwrite, nonatomic) CBCharacteristicProperties properties;
@property(retain, readwrite, nullable) NSData *value;
@property(retain, readwrite, nullable) NSArray<CBCharacteristic *> *characteristics;
- (instancetype)initWithUUID:(CBUUID *)uuid;
@end
@implementation MBLServiceCharacteristicMock
- (instancetype)initWithUUID:(CBUUID *)uuid
{
    self = [super init];
    if (self) {
        self.UUID = uuid;
        self.properties = CBCharacteristicPropertyWriteWithoutResponse | CBCharacteristicWriteWithResponse;
    }
    return self;
}
@end


@interface MBLBluetoothPeripheralMock ()
@property (nonatomic) MBLFirmwareVersion version;
@property (nonatomic) MBLModel model;

@property (nonatomic) NSArray *modules;
@property (nonatomic) MBLModuleMock *testDebug;

@property (nonatomic) CBMutableCharacteristic *command;
@property (nonatomic) CBMutableCharacteristic *notification;

@property (nonatomic) CBMutableCharacteristic *batteryLife;

@property (nonatomic) CBMutableCharacteristic *DISModelNumber;
@property (nonatomic) CBMutableCharacteristic *DISSerialNumber;
@property (nonatomic) CBMutableCharacteristic *DISFirmwareRev;
@property (nonatomic) CBMutableCharacteristic *DISHardwareRev;
@property (nonatomic) CBMutableCharacteristic *DISManufacturerName;

@property (nonatomic) NSTimer *discoveryTimer;
@end

@implementation MBLBluetoothPeripheralMock

- (id)copyWithZone:(NSZone *)zone
{
    MBLBluetoothPeripheralMock *newPeripheral = [[self class] allocWithZone:zone];
    newPeripheral.delegate = self.delegate;
    newPeripheral.name = self.name;
    newPeripheral.state = self.state;
    newPeripheral.services = self.services;
    newPeripheral.identifier = self.identifier;
    
    newPeripheral.discoverServicesWaitTime = self.discoverServicesWaitTime;
    newPeripheral.keyRegister = self.keyRegister;
    newPeripheral.isMetaBoot = self.isMetaBoot;
    
    newPeripheral.hapticHandler = self.hapticHandler;
    newPeripheral.buzzerHandler = self.buzzerHandler;
    
    newPeripheral.version = self.version;
    newPeripheral.model = self.model;
    
    newPeripheral.modules = self.modules;
    newPeripheral.testDebug = self.testDebug;
    
    newPeripheral.command = self.command;
    newPeripheral.notification = self.notification;
    
    newPeripheral.batteryLife = self.batteryLife;
    
    newPeripheral.DISModelNumber = self.DISModelNumber;
    newPeripheral.DISSerialNumber = self.DISSerialNumber;
    newPeripheral.DISFirmwareRev = self.DISFirmwareRev;
    newPeripheral.DISHardwareRev = self.DISHardwareRev;
    newPeripheral.DISManufacturerName = self.DISManufacturerName;
    return newPeripheral;
}

- (BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    if (![object isKindOfClass:[MBLBluetoothPeripheralMock class]]) {
        return NO;
    }
    return [self.identifier isEqual:((MBLBluetoothPeripheralMock *)object).identifier];
}

- (NSUInteger)hash
{
    return self.identifier.hash;
}

- (instancetype)initWithVersion:(MBLFirmwareVersion)version model:(MBLModel)model
{
    self = [super init];
    if (self) {
        self.name = @"MetaWear";
        self.state = CBPeripheralStateDisconnected;
        self.identifier = [[NSUUID alloc] initWithUUIDString:[NSString stringWithFormat:@"E621%04X-C36C-495A-93FC-0C247A3E6E5F", model]];
        
        [self resetKnobs];

        self.version = version;
        self.model = model;

        self.modules = @[[NSNull null],
                         [MBLModuleMock mechanicalSwitch:self],
                         [MBLModuleMock led:self],
                         [MBLModuleMock accelerometer:self],
                         [MBLModuleMock temperature:self],
                         [MBLModuleMock gpio:self],
                         [NSNull null],
                         [NSNull null],
                         [MBLModuleMock hapticBuzzer:self],
                         [NSNull null],
                         [NSNull null],
                         [MBLModuleMock logging:self],
                         [NSNull null],
                         [MBLModuleMock serial:self],
                         [NSNull null],
                         [NSNull null],
                         [NSNull null],
                         [NSNull null],
                         [MBLModuleMock barometer:self],
                         [NSNull null],
                         [NSNull null],
                         [NSNull null],
                         [NSNull null],
                         [NSNull null],
                         [NSNull null],
                         [NSNull null]];
        self.testDebug = [MBLModuleMock testDebug:self];
    }
    return self;
}

- (void)resetKnobs
{
    self.discoverServicesWaitTime = 0.1;
    [self.discoveryTimer invalidate];
    self.keyRegister = 0;
    self.isMetaBoot = NO;
    self.failServiceDiscoveryOnce = NO;
}

//- (NSData *)getAddEntityResponse:(NSData *)data
//{
//    NSData *response = nil;
//    
//    uint8_t const *byte = data.bytes;
//    uint8_t moduleId = *byte;
//    byte++;
//    uint8_t regId = *byte;
//    uint8_t responseId = 0xFF;
//    if (moduleId == 0x9 && regId == 0x2) {
//        responseId = self.dataFilterCount++;
//    } else if (moduleId == 0xA && regId == 0x2) {
//        responseId = self.eventCount++;
//    } else if (moduleId == 0xB && regId == 0x2) {
//        responseId = self.logCount++;
//    } else if (moduleId == 0xC && regId == 0x2) {
//        responseId = self.timerCount++;
//    } else if (moduleId == 0xE && regId == 0x3) {
//        responseId = self.ancsCount++;
//    } else if (moduleId == 0xF && regId == 0x2) {
//        responseId = self.macroCount++;
//    }
//    if (responseId != 0xFF) {
//        response = [MBLMockUtils dataFromString:[NSString stringWithFormat:@"%02X-%02X-%02X", moduleId, regId, responseId]];
//    }
//    return response;
//}

- (void)readRSSI
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate peripheral:self didReadRSSI:@-45.0 error:nil];
    });
}

- (void)discoverServices:(NSArray<CBUUID *> *)serviceUUIDs
{
    NSMutableArray *services = [NSMutableArray array];
    for (CBUUID *uuid in serviceUUIDs) {
        // DFU Service IFF MetaBoot mode requested
        if (self.isMetaBoot != [uuid isEqual:[MBLConstants DFUServiceUUID]]) {
            continue;
        }
#if TARGET_OS_TV
        [services addObject:[[MBLServiceCharacteristicMock alloc] initWithUUID:uuid]];
#else
        [services addObject:[[CBMutableService alloc] initWithType:uuid primary:YES]];
#endif
    }
    self.services = services;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.discoveryTimer = [NSTimer scheduledTimerWithTimeInterval:self.discoverServicesWaitTime target:self selector:@selector(didDiscover:) userInfo:nil repeats:NO];
    });
}

- (void)didDiscover:(NSTimer *)timer
{
    NSError *error = nil;
    if (self.failServiceDiscoveryOnce) {
        self.failServiceDiscoveryOnce = NO;
        error = [NSError errorWithDomain:kMBLErrorDomain code:kMBLErrorUnexpectedServices userInfo:nil];
    }
    [self.delegate peripheral:self didDiscoverServices:error];
}

+ (CBMutableCharacteristic *)readOnly:(CBUUID *)uuid
{
#if TARGET_OS_TV
    return (CBMutableCharacteristic *)[[MBLServiceCharacteristicMock alloc] initWithUUID:uuid];
#else
    return [[CBMutableCharacteristic alloc] initWithType:uuid
                                              properties:CBCharacteristicPropertyRead
                                                   value:nil
                                             permissions:CBAttributePermissionsReadable];
#endif
}
+ (CBMutableCharacteristic *)readWrite:(CBUUID *)uuid
{
#if TARGET_OS_TV
    return (CBMutableCharacteristic *)[[MBLServiceCharacteristicMock alloc] initWithUUID:uuid];
#else
    return [[CBMutableCharacteristic alloc] initWithType:uuid
                                              properties:
            CBCharacteristicPropertyRead |
            CBCharacteristicPropertyWriteWithoutResponse |
            CBCharacteristicPropertyWrite
                                                   value:nil
                                             permissions:
            CBAttributePermissionsReadable	|
            CBAttributePermissionsWriteable];
#endif
}
+ (CBMutableCharacteristic *)readNotify:(CBUUID *)uuid
{
#if TARGET_OS_TV
    return (CBMutableCharacteristic *)[[MBLServiceCharacteristicMock alloc] initWithUUID:uuid];
#else
    return [[CBMutableCharacteristic alloc] initWithType:uuid
                                              properties:
            CBCharacteristicPropertyRead |
            CBCharacteristicPropertyNotify
                                                   value:nil
                                             permissions:
            CBAttributePermissionsReadable];
#endif
}


- (void)discoverCharacteristics:(NSArray<CBUUID *> *)characteristicUUIDs forService:(CBService *)service
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSMutableArray *characteristics = [NSMutableArray array];
        if ([service.UUID isEqual:[MBLConstants serviceUUID]]) {
            for (CBUUID *uuid in characteristicUUIDs) {
                if ([uuid isEqual:[MBLConstants commandUUID]]) {
                    self.command = [MBLBluetoothPeripheralMock readWrite:uuid];
                    [characteristics addObject:self.command];
                } else if ([uuid isEqual:[MBLConstants notificationUUID]]) {
                    self.notification = [MBLBluetoothPeripheralMock readNotify:uuid];
                    [characteristics addObject:self.notification];
                }
            }
        } else if ([service.UUID isEqual:[MBLConstants batteryServiceUUID]]) {
            for (CBUUID *uuid in characteristicUUIDs) {
                if ([uuid isEqual:[MBLConstants batteryLifeUUID]]) {
                    self.batteryLife = [MBLBluetoothPeripheralMock readOnly:uuid];
                    [characteristics addObject:self.batteryLife];
                }
            }
        } else if ([service.UUID isEqual:[MBLConstants DISServiceUUID]]) {
            for (CBUUID *uuid in characteristicUUIDs) {
                if ([uuid isEqual:[MBLConstants DISManufacturerNameUUID]]) {
                    self.DISManufacturerName = [MBLBluetoothPeripheralMock readOnly:uuid];
                    [characteristics addObject:self.DISManufacturerName];
                } else if ([uuid isEqual:[MBLConstants DISSerialNumberUUID]]) {
                    self.DISSerialNumber = [MBLBluetoothPeripheralMock readOnly:uuid];
                    [characteristics addObject:self.DISSerialNumber];
                } else if ([uuid isEqual:[MBLConstants DISHardwareRevUUID]]) {
                    self.DISHardwareRev = [MBLBluetoothPeripheralMock readOnly:uuid];
                    [characteristics addObject:self.DISHardwareRev];
                } else if ([uuid isEqual:[MBLConstants DISFirmwareRevUUID]]) {
                    self.DISFirmwareRev = [MBLBluetoothPeripheralMock readOnly:uuid];
                    [characteristics addObject:self.DISFirmwareRev];
                } else if ([uuid isEqual:[MBLConstants DISModelNumberUUID]]) {
                    self.DISModelNumber = [MBLBluetoothPeripheralMock readOnly:uuid];
                    [characteristics addObject:self.DISModelNumber];
                }
            }
        }
        ((CBMutableService *)service).characteristics = characteristics;
        [self.delegate peripheral:self didDiscoverCharacteristicsForService:service error:nil];
    });
}

- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic
{
    NSData *result = nil;
    CBUUID *uuid = characteristic.UUID;
    if ([uuid isEqual:[MBLConstants DISManufacturerNameUUID]]) {
        result = [@"MbientLab Inc" dataUsingEncoding:NSASCIIStringEncoding];
    } else if ([uuid isEqual:[MBLConstants DISSerialNumberUUID]]) {
        result = [@"FFFFFFFF" dataUsingEncoding:NSASCIIStringEncoding];
    } else if ([uuid isEqual:[MBLConstants DISHardwareRevUUID]]) {
        switch (self.model) {
            case MBLModelMetaWearR:
                result = [@"0.2" dataUsingEncoding:NSASCIIStringEncoding];
                break;
            case MBLModelMetaWearRG:
            case MBLModelMetaWearRPro:
            case MBLModelMetaWearC:
            case MBLModelMetaWearCPro:
            case MBLModelMetaEnvironment:
            case MBLModelMetaDetector:
                result = [@"0.3" dataUsingEncoding:NSASCIIStringEncoding];
                break;
            case MBLModelMetaHealth:
            case MBLModelMetaTracker:
            case MBLModelMetaMotionR:
            case MBLModelMetaMotionC:
                result = [@"0.1" dataUsingEncoding:NSASCIIStringEncoding];
                break;
            default:
                break;
        }        
    } else if ([uuid isEqual:[MBLConstants DISFirmwareRevUUID]]) {
        result = [MBLFirmwareVersionString(self.version) dataUsingEncoding:NSASCIIStringEncoding];
    } else if ([uuid isEqual:[MBLConstants DISModelNumberUUID]]) {
        switch (self.model) {
            case MBLModelMetaWearR:
                result = [@"0" dataUsingEncoding:NSASCIIStringEncoding];
                break;
            case MBLModelMetaWearRG:
            case MBLModelMetaWearRPro:
                result = [@"1" dataUsingEncoding:NSASCIIStringEncoding];
                break;
            case MBLModelMetaWearC:
            case MBLModelMetaWearCPro:
            case MBLModelMetaEnvironment:
            case MBLModelMetaDetector:
                result = [@"2" dataUsingEncoding:NSASCIIStringEncoding];
                break;
            case MBLModelMetaHealth:
                result = [@"3" dataUsingEncoding:NSASCIIStringEncoding];
                break;
            case MBLModelMetaTracker:
                result = [@"4" dataUsingEncoding:NSASCIIStringEncoding];
                break;
            case MBLModelMetaMotionR:
                result = [@"5" dataUsingEncoding:NSASCIIStringEncoding];
                break;
            case MBLModelMetaMotionC:
                result = [@"6" dataUsingEncoding:NSASCIIStringEncoding];
                break;
            default:
                break;
        }
    } else if ([uuid isEqual:[MBLConstants batteryLifeUUID]]) {
        uint8_t battery = 99;
        result = [NSData dataWithBytes:&battery length:sizeof(battery)];
    }

    if (result) {
        ((CBMutableCharacteristic *)characteristic).value = result;
        [self.delegate peripheral:self didUpdateValueForCharacteristic:characteristic error:nil];
    }
}

- (void)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type
{
    if (type == CBCharacteristicWriteWithResponse) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate peripheral:self didWriteValueForCharacteristic:characteristic error:nil];
        });
    }
    message_payload_t const *msg = data.bytes;
    if (msg->mod_id < self.modules.count) {
        id module = self.modules[msg->mod_id];
        if ([module respondsToSelector:@selector(processMessage:)]) {
            [module processMessage:msg];
        } else {
            if (msg->red_id == 0x80) {
                // Response to mod info reads with a null response
                [self messageSend:msg->mod_id regId:msg->red_id notifyen:1 data:nil];
            }
        }
    } else if (msg->mod_id == 0xFE) {
        if ([self.testDebug respondsToSelector:@selector(processMessage:)]) {
            [self.testDebug processMessage:msg];
        } else if (msg->red_id == 0x80) {
            // Response to mod info reads with a null response
            [self messageSend:msg->mod_id regId:msg->red_id notifyen:1 data:nil];
        }
    }
}

- (void)setNotifyValue:(BOOL)enabled forCharacteristic:(CBCharacteristic *)characteristic
{
    // We will assume its always notifiying
}

- (void)messageSend:(uint8_t)modId regId:(uint8_t)regId notifyen:(uint8_t)notifyen data:(NSData *)data
{
    if (notifyen) {
        dispatch_async(dispatch_get_main_queue(), ^{
            uint8_t header[] = { modId, regId };
            NSMutableData *msg = [NSMutableData dataWithBytes:header length:sizeof(header)];
            [msg appendData:data];
            self.notification.value = msg;
            [self.delegate peripheral:self didUpdateValueForCharacteristic:self.notification error:nil];
        });
    }
}

@end
