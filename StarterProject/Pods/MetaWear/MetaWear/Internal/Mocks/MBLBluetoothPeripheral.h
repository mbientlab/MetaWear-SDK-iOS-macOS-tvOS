/**
 * MBLBluetoothPeripheral.h
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

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol MBLBluetoothPeripheralDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 To improve testabilty we need to mock CoreBluetooth objects.  To do this we will make our
 own protocols that are identical the CoreBluetooth interfaces and then code only to these.
 That keeps the bulk of the code CoreBluetooth agnostic and allows us to create mock objects.
 */
@protocol MBLBluetoothPeripheral <NSObject, NSCopying>
@property id<MBLBluetoothPeripheralDelegate> delegate;
@property NSString *name;
@property CBPeripheralState state;
@property NSArray<CBService *> *services;
@property NSUUID *identifier;

- (void)readRSSI;
- (void)discoverServices:(nullable NSArray<CBUUID *> *)serviceUUIDs;
- (void)discoverCharacteristics:(nullable NSArray<CBUUID *> *)characteristicUUIDs forService:(CBService *)service;
- (void)readValueForCharacteristic:(CBCharacteristic *)characteristic;
- (void)writeValue:(NSData *)data forCharacteristic:(CBCharacteristic *)characteristic type:(CBCharacteristicWriteType)type;
- (void)setNotifyValue:(BOOL)enabled forCharacteristic:(CBCharacteristic *)characteristic;
@end

// CBPeripheral implements the protocol already!
@interface CBPeripheral (Private) <MBLBluetoothPeripheral>
@end


/**
 Also mock the delegate
 */
@protocol MBLBluetoothPeripheralDelegate <NSObject>
@optional
- (void)peripheral:(id<MBLBluetoothPeripheral>)peripheral didReadRSSI:(NSNumber *)RSSI error:(nullable NSError *)error;
- (void)peripheral:(id<MBLBluetoothPeripheral>)peripheral didDiscoverServices:(nullable NSError *)error;
- (void)peripheral:(id<MBLBluetoothPeripheral>)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(nullable NSError *)error;
- (void)peripheral:(id<MBLBluetoothPeripheral>)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error;
- (void)peripheral:(id<MBLBluetoothPeripheral>)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(nullable NSError *)error;
@end

NS_ASSUME_NONNULL_END
