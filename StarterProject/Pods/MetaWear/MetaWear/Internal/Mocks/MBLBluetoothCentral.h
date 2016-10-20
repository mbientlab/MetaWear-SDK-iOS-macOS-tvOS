/**
 * MBLBluetoothCentral.h
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
#import "MBLBluetoothPeripheral.h"

@protocol MBLBluetoothCentralDelegate;

NS_ASSUME_NONNULL_BEGIN

/**
 To improve testabilty we need to mock CoreBluetooth objects.  To do this we will make our
 own protocols that are identical the CoreBluetooth interfaces and then code only to these.
 That keeps the bulk of the code CoreBluetooth agnostic and allows us to create mock objects.
 */
@protocol MBLBluetoothCentral <NSObject>
@property id<MBLBluetoothCentralDelegate> delegate;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
@property CBCentralManagerState state;
#pragma clang diagnostic pop

- (id)initWithDelegate:(id<MBLBluetoothCentralDelegate>)delegate queue:(dispatch_queue_t)queue options:(nullable NSDictionary<NSString *, id> *)options;

- (NSArray<id<MBLBluetoothPeripheral>> *)retrievePeripheralsWithIdentifiers:(NSArray<NSUUID *> *)identifiers;
- (NSArray<id<MBLBluetoothPeripheral>> *)retrieveConnectedPeripheralsWithServices:(NSArray<CBUUID *> *)serviceUUIDs;
- (void)scanForPeripheralsWithServices:(nullable NSArray<CBUUID *> *)serviceUUIDs options:(nullable NSDictionary<NSString *, id> *)options;
- (void)stopScan;
- (void)connectPeripheral:(id<MBLBluetoothPeripheral>)peripheral options:(nullable NSDictionary<NSString *, id> *)options;
- (void)cancelPeripheralConnection:(id<MBLBluetoothPeripheral>)peripheral;
@end

// CBPeripheral implements the protocol already!
@interface CBCentralManager (Private) <MBLBluetoothCentral>
@end


/**
 Also mock the delegate
 */
@protocol MBLBluetoothCentralDelegate <NSObject>
@required
- (void)centralManagerDidUpdateState:(id<MBLBluetoothCentral>)central;

@optional
- (void)centralManager:(id<MBLBluetoothCentral>)central willRestoreState:(NSDictionary<NSString *, id> *)dict;
- (void)centralManager:(id<MBLBluetoothCentral>)central didRetrievePeripherals:(NSArray<id<MBLBluetoothPeripheral>> *)peripherals;
- (void)centralManager:(id<MBLBluetoothCentral>)central didRetrieveConnectedPeripherals:(NSArray<id<MBLBluetoothPeripheral>> *)peripherals;
- (void)centralManager:(id<MBLBluetoothCentral>)central didDiscoverPeripheral:(id<MBLBluetoothPeripheral>)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI;
- (void)centralManager:(id<MBLBluetoothCentral>)central didConnectPeripheral:(id<MBLBluetoothPeripheral>)peripheral;
- (void)centralManager:(id<MBLBluetoothCentral>)central didFailToConnectPeripheral:(id<MBLBluetoothPeripheral>)peripheral error:(nullable NSError *)error;
- (void)centralManager:(id<MBLBluetoothCentral>)central didDisconnectPeripheral:(id<MBLBluetoothPeripheral>)peripheral error:(nullable NSError *)error;
@end

NS_ASSUME_NONNULL_END
