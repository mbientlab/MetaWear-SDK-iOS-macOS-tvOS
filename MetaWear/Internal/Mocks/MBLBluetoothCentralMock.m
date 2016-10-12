/**
 * MBLBluetoothCentralMock.m
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

#import "MBLBluetoothCentralMock.h"
#import "MBLBluetoothPeripheralMock.h"
#import "MBLMockPeripheralFactory.h"

@interface MBLBluetoothCentralMock ()
@property (nonatomic) NSDictionary<NSUUID *, MBLBluetoothPeripheralMock *> *peripherals;
@property (nonatomic) BOOL isScanning;
@end

@implementation MBLBluetoothCentralMock

- (id)initWithDelegate:(id<MBLBluetoothCentralDelegate>)delegate queue:(dispatch_queue_t)queue options:(NSDictionary<NSString *, id> *)options
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.queue = queue;
        
        [self resetKnobs];
        
        MBLBluetoothPeripheralMock *metawearR = [[MBLBluetoothPeripheralMock alloc] initWithVersion:MBLFirmwareVersion1_2_5
                                                                                              model:MBLModelMetaWearR];
        MBLBluetoothPeripheralMock *metawearC = [[MBLBluetoothPeripheralMock alloc] initWithVersion:MBLFirmwareVersion1_2_5
                                                                                              model:MBLModelMetaWearC];
        self.peripherals = @{ metawearR.identifier : metawearR,
                              metawearC.identifier : metawearC};
        
        // Simulate the initial state tranistion of a the typical CoreBluetooth beast
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        self.state = CBCentralManagerStateUnknown;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), queue, ^{
            self.state = CBCentralManagerStatePoweredOn;
            [self.delegate centralManagerDidUpdateState:self];
        });
#pragma clang diagnostic pop
    }
    return self;
}

- (void)resetKnobs
{
    self.connectWaitTime = 0.1;
}

- (NSArray<id<MBLBluetoothPeripheral>> *)retrievePeripheralsWithIdentifiers:(NSArray<NSUUID *> *)identifiers
{
    NSMutableArray *array = [NSMutableArray array];
    [self.peripherals enumerateKeysAndObjectsUsingBlock:^(NSUUID *key, MBLBluetoothPeripheralMock *obj, BOOL *stop) {
        if ([identifiers containsObject:key]) {
            [array addObject:obj];
        }
    }];
    return array;
}

- (NSArray<id<MBLBluetoothPeripheral>> *)retrieveConnectedPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs
{
    return [NSArray array];
}

- (void)scanForPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs options:(NSDictionary<NSString *, id> *)options
{
    self.isScanning = YES;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.peripherals enumerateKeysAndObjectsUsingBlock:^(NSUUID *key, MBLBluetoothPeripheralMock *obj, BOOL *stop) {
            if (self.isScanning) {
                [self.delegate centralManager:self
                        didDiscoverPeripheral:obj
                            advertisementData:@{}
                                         RSSI:@-45.0];
            }
        }];
    });
}

- (void)stopScan
{
    self.isScanning = NO;
}

- (void)connectPeripheral:(id<MBLBluetoothPeripheral>)peripheral options:(NSDictionary<NSString *, id> *)options
{
    if (peripheral.state == CBPeripheralStateConnecting) {
        return;
    }
    // Slight delay realism
    peripheral.state = CBPeripheralStateConnecting;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.connectWaitTime * NSEC_PER_SEC)), self.queue, ^{
        peripheral.state = CBPeripheralStateConnected;
        [self.delegate centralManager:self didConnectPeripheral:peripheral];
    });
}

- (void)cancelPeripheralConnection:(id<MBLBluetoothPeripheral>)peripheral
{
    // Slight delay for realism
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), self.queue, ^{
        peripheral.state = CBPeripheralStateDisconnected;
        [self.delegate centralManager:self didDisconnectPeripheral:peripheral error:nil];
    });
}

@end
