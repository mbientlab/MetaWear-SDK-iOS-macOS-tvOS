/**
 * MBLMetaWear+Private.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 8/2/14.
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

#import "MBLMetaWear.h"
#import "MBLDataProcessor.h"
#import "MBLLogging.h"
#import "MBLCommand.h"
#import "MBLTestDebug.h"
#import "MBLMacro.h"
#import "MBLDispatchQueue.h"
#import "MBLNonVolatileState.h"
#import "MBLBluetoothPeripheral.h"
#import "MBLFirmwareUpdateInfo.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^MBLSimulationHandler)(uint8_t module, uint8_t opcode, NSData *parameters);

// Properties that certain privileged people need access too
@interface MBLMetaWear (Private) <MBLBluetoothPeripheralDelegate>
@property (nonatomic, nonnull) NSUUID *identifier;
@property (nonatomic) NSDictionary *advertisementData;
@property (nonatomic, nullable) NSString *mac;
@property (nonatomic, nullable) NSNumber *discoveryTimeRSSI;
@property (nonatomic) BOOL isMetaBoot;

@property (nonatomic) id<MBLBluetoothPeripheral> peripheral;
@property (nonatomic) BOOL bypassSetup;

@property (nonatomic, nullable, readonly) MBLDataProcessor *dataProcessor;
@property (nonatomic, nullable, readonly) MBLLogging *logging;
@property (nonatomic, nullable, readonly) MBLCommand *command;
@property (nonatomic, nullable, readonly) MBLTestDebug *testDebug;
@property (nonatomic, nullable, readonly) MBLMacro *macro;
@property (nonatomic, nullable) MBLDeviceInfo *deviceInfo;

@property (nonatomic, readonly) MBLNonVolatileState *nonVolatileState;

@property (nonatomic, readonly) MBLDispatchQueue *zeroCountQueue;

@property (nonatomic, nullable) NSArray *modules;

- (instancetype)initWithPeripheral:(id<MBLBluetoothPeripheral>)peripheral;

- (void)didConnect;
- (void)didDisconnect:(nullable NSError *)error;

/// Because of iOS oddity we need to manually notify the peripheral
/// if bluetooth is powered off
- (void)bluetoothPoweredOff;

/// Send raw bytes over BLE to the MetaWear command register
- (void)writeCommandRegister:(NSData *)data withResponse:(BOOL)withResponse;

/**
 The simulation feature allow you to execute API calls but instead
 of sending the resulting bytes across the BLE link to the MetaWear,
 they will just be passed into handler.
 
 Note you must wait on waitForSimulatorTurn before calling startSimulationWithHandler:
 and must call stopSimulation when finished
 */
- (BFTask *)waitForSimulatorTurn;
- (void)startSimulationWithHandler:(MBLSimulationHandler)handler;
- (void)stopSimulation;

/**
 The sniffer allows you to see what bytes are being sent across the BLE link
 */
- (void)startSnifferWithHandler:(MBLDataHandler)handler;
- (void)stopSniffer;

/**
 The count feature allows us to keep track of the number of outstanding
 transactions going to the MetaWear.  Use incrementCount to indicate when
 a new operation has started and decrementCount when it finishes. 
 Use the waitForCommandCompletion: to get a callback when all transactions 
 are complete.
 */
- (void)incrementCount;
- (void)decrementCount;
- (BFTask *)waitForCommandCompletion;
- (BFTask *)waitForSimulatorCompletion;

- (BFTask<MBLFirmwareUpdateInfo *> *)prepareForFirmwareUpdateToVersionAsync:(nullable MBLFirmwareBuild *)firmware;

- (void)updateName:(NSString *)name;

@end

NS_ASSUME_NONNULL_END
