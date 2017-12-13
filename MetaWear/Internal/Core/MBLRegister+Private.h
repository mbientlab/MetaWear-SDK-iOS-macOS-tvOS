/**
 * MBLRegister+Private.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 10/28/14.
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

#import "MBLRegister.h"
#import "MBLConstants.h"
#import "MBLFormat.h"
#import <Bolts/Bolts.h>

@class MBLMetaWear;
@class MBLModule;

NS_ASSUME_NONNULL_BEGIN

@interface MBLRegister (Private)
@property (nonatomic, weak, nullable) MBLModule *module;
@property (nonatomic) uint8_t registerId;
@property (nonatomic) uint8_t index;
@property (nonatomic) MBLFormat *format;
@property (nonatomic, nullable) NSString *identifier;

@property (nonatomic) int16_t initializeCount;
@property (nonatomic) int16_t activateCount;

// State Accessors
@property (nonatomic) BOOL needsResponse;
@property (nonatomic) BOOL writeResponds;
@property (nonatomic) BOOL isNotifyingImpl;
@property (nonatomic) BOOL isLoggingImpl;
@property (nonatomic) BOOL hasCommandsImpl;


- (instancetype)initWithModule:(MBLModule *)module registerId:(uint8_t)registerId index:(uint8_t)index format:(MBLFormat *)format;
- (instancetype)initWithModule:(MBLModule *)module registerId:(uint8_t)registerId format:(MBLFormat *)format;
- (instancetype)initWithModule:(MBLModule *)module registerId:(uint8_t)registerId index:(uint8_t)index format:(MBLFormat *)format identifier:(nullable NSString *)identifier;
- (instancetype)initWithModule:(MBLModule *)module registerId:(uint8_t)registerId format:(MBLFormat *)format identifier:(NSString *)identifier;

// readAsync here conflicts with the paramerized type readAsync on MBLData
- (BFTask *)readAsync NS_SWIFT_NAME(readRegisterAsync());
- (BFTask *)readForcedIndexAsync:(uint8_t)index;
- (BFTask *)localReadAsync;
- (nullable NSData *)readParameters;

- (BFTask *)writeDataAsync:(nullable NSData *)data;
- (nonnull BFTask *)writeByteAsync:(uint8_t)byte;

- (void)addNotificationWithExecutor:(BFExecutor *)executor handler:(MBLObjectHandler)handler;
- (void)removeNotificationHandlers NS_SWIFT_NAME(removeRegisterNotificationHandlers());

// conflicts with the paramerized types on MBLEvent
- (BFTask *)startNotificationsWithHandlerAsync:(nullable MBLObjectHandler)handler;
- (BFTask *)startNotificationsWithExecutorAsync:(BFExecutor *)executor withHandler:(nullable MBLObjectHandler)handler NS_SWIFT_NAME(startRegisterNotificationsAsync(executor:handler:));
- (BFTask *)stopNotificationsAsync NS_SWIFT_NAME(stopRegisterNotificationsAsync());

- (void)recievedData:(nullable NSData *)data error:(nullable NSError *)error;
- (void)deviceDisconnected:(nullable NSError *)error;
- (BFTask *)deviceConnected;


- (BFTask *)initializeAsync;
- (BFTask *)deinitializeAsync;
- (BFTask *)activateAsync;
- (BFTask *)deactivateAsync;

- (BFTask *)performAsyncInitialization;
- (BFTask *)performAsyncDeinitialization;

- (BFTask *)performAsyncActivation;
- (BFTask *)performAsyncDeactivation;

- (BFTask *)performAsyncStartNotifications;
- (BFTask *)performAsyncStopNotificationsAsync;

@end

NS_ASSUME_NONNULL_END
