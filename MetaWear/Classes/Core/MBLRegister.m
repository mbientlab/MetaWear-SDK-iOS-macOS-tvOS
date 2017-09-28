/**
 * MBLRegister.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 10/8/14.
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

#import "MBLRegister+Private.h"
#import "MBLMetaWearManager+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLModule+Private.h"
#import "BFTask+MBLPrivate.h"
#import "BFTask+MBLExtensions.h"
#import "MBLConstants+Private.h"
#import "MBLLogger.h"

typedef NS_OPTIONS(uint8_t, MBLRegisterState) {
    MBLRegisterStateNeedsResponse  = 1 << 0,
    MBLRegisterStateWriteResponds  = 1 << 1,
    MBLRegisterStateIsNotifying    = 1 << 2,
    MBLRegisterStateIsLogging      = 1 << 3,
    MBLRegisterStateHasCommands    = 1 << 4
};

@interface MBLRegister ()
@property (nonatomic, weak) MBLModule *module;
@property (nonatomic) uint8_t registerId;
@property (nonatomic) uint8_t index;
@property (nonatomic) MBLRegisterState state;
@property (nonatomic) MBLFormat *format;
@property (nonatomic, nullable) NSString *identifier;

@property (nonatomic) int16_t initializeCount;
@property (nonatomic) int16_t activateCount;
@end

@implementation MBLRegister {
    NSMutableArray  *taskSources;
    NSMutableArray  *notifyCallbacks;
    
    BFTask          *initializeTask;
    BFTask          *deinitializeTask;
    BFTask          *activateTask;
    BFTask          *deactivateTask;
    BFTask          *startNotificationTask;
    BFTask          *stopNotificationTask;
}

- (instancetype)initWithModule:(MBLModule *)module registerId:(uint8_t)registerId index:(uint8_t)index format:(MBLFormat *)format identifier:(nullable NSString *)identifier
{
    self = [super init];
    if (self) {
        self.module = module;
        self.registerId = registerId;
        self.index = index;
        self.needsResponse = NO;
        self.format = format;
        self.identifier = identifier;
        
        self.initializeCount = 0;
        self.activateCount = 0;
        
        taskSources = [NSMutableArray array];
        notifyCallbacks = [NSMutableArray array];
        
        initializeTask = [BFTask taskWithResult:nil];
        deinitializeTask = [BFTask taskWithResult:nil];
        activateTask = [BFTask taskWithResult:nil];
        deactivateTask = [BFTask taskWithResult:nil];
        startNotificationTask = [BFTask taskWithResult:nil];
        stopNotificationTask = [BFTask taskWithResult:nil];
        
        // This is a special dummy register for testing
        if (registerId != 0xFF) {
            [module addRegister:self];
        }
    }
    return self;
}
- (instancetype)initWithModule:(MBLModule *)module registerId:(uint8_t)registerId format:(MBLFormat *)format identifier:(NSString *)identifier
{
    return [self initWithModule:module registerId:registerId index:0xFF format:format identifier:identifier];
}
- (instancetype)initWithModule:(MBLModule *)module registerId:(uint8_t)registerId index:(uint8_t)index format:(MBLFormat *)format
{
    return [self initWithModule:module registerId:registerId index:index format:format identifier:nil];
}
- (instancetype)initWithModule:(MBLModule *)module registerId:(uint8_t)registerId format:(MBLFormat *)format
{
    return [self initWithModule:module registerId:registerId index:0xFF format:format identifier:nil];
}

- (id)awakeAfterFastCoding
{
    taskSources = [NSMutableArray array];
    notifyCallbacks = [NSMutableArray array];
    
    initializeTask = [BFTask taskWithResult:nil];
    deinitializeTask = [BFTask taskWithResult:nil];
    activateTask = [BFTask taskWithResult:nil];
    deactivateTask = [BFTask taskWithResult:nil];
    startNotificationTask = [BFTask taskWithResult:nil];
    stopNotificationTask = [BFTask taskWithResult:nil];
    
    return self;
}

- (BOOL)needsResponse
{
    assert([MBLConstants isMetaWearQueue]);
    return self.state & MBLRegisterStateNeedsResponse;
}

- (void)setNeedsResponse:(BOOL)needsResponse
{
    if (needsResponse) {
        self.state |= MBLRegisterStateNeedsResponse;
    } else {
        self.state &= ~MBLRegisterStateNeedsResponse;
    }
}

- (BOOL)writeResponds
{
    assert([MBLConstants isMetaWearQueue]);
    return self.state & MBLRegisterStateWriteResponds;
}

- (void)setWriteResponds:(BOOL)writeResponds
{
    if (writeResponds) {
        self.state |= MBLRegisterStateWriteResponds;
    } else {
        self.state &= ~MBLRegisterStateWriteResponds;
    }
}

- (BOOL)isNotifyingImpl
{
    assert([MBLConstants isMetaWearQueue]);
    return self.state & MBLRegisterStateIsNotifying;
}

- (void)setIsNotifyingImpl:(BOOL)isNotifying
{
    assert([MBLConstants isMetaWearQueue]);
    if (isNotifying) {
        self.state |= MBLRegisterStateIsNotifying;
    } else {
        self.state &= ~MBLRegisterStateIsNotifying;
    }
}

- (BOOL)isLoggingImpl
{
    assert([MBLConstants isMetaWearQueue]);
    return self.state & MBLRegisterStateIsLogging;
}

- (void)setIsLoggingImpl:(BOOL)isLogging
{
    assert([MBLConstants isMetaWearQueue]);
    if (isLogging) {
        self.state |= MBLRegisterStateIsLogging;
    } else {
        self.state &= ~MBLRegisterStateIsLogging;
    }
}

- (BOOL)hasCommandsImpl
{
    assert([MBLConstants isMetaWearQueue]);
    return self.state & MBLRegisterStateHasCommands;
}

- (void)setHasCommandsImpl:(BOOL)hasCommands
{
    assert([MBLConstants isMetaWearQueue]);
    if (hasCommands) {
        self.state |= MBLRegisterStateHasCommands;
    } else {
        self.state &= ~MBLRegisterStateHasCommands;
    }
}

- (BFTask *)sendByteToDevice:(uint8_t)byte isRead:(BOOL)isRead
{
    return [self sendDataToDevice:[NSData dataWithBytes:&byte length:1] isRead:isRead isLocal:NO];
}

- (BFTask *)sendDataToDevice:(NSData *)parameters isRead:(BOOL)isRead isLocal:(BOOL)isLocal
{
    MBLMetaWear *device = self.module.device;
    if (device.state == MBLConnectionStateDisconnected) {
        NSError *error = [NSError errorWithDomain:kMBLErrorDomain
                                             code:kMBLErrorNotConnected
                                         userInfo:@{NSLocalizedDescriptionKey : @"MetaWear not connected, can't perform operation.  Please connect to MetaWear before performing read operations."}];
        return [BFTask taskWithError:error];
        
    }
    if (!self.module.moduleInfo.moduleId || !self.registerId) {
        NSError *error = [NSError errorWithDomain:kMBLErrorDomain
                                             code:kMBLErrorNotConnected
                                         userInfo:@{NSLocalizedDescriptionKey : @"Attempted to communicate with invalid module/register."}];
        return [BFTask taskWithError:error];
    }
    
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    [device incrementCount];
    [BFTask taskFromMetaWearWithBlock:^id{
        if ([MBLConstants isSimulatorQueue]) {
            [source trySetResult:nil];
        } else if (isRead || self.writeResponds) {
            [taskSources addObject:source];
        } else {
            [source trySetResult:nil];
        }
        
        uint8_t header[] = { self.module.moduleInfo.moduleId, self.registerId };
        int headerSize = sizeof(header) / sizeof(header[0]);
        if (isRead) {
            header[1] |= 0x80;
        }
        if (isLocal) {
            header[1] |= 0x40;
        }
        NSMutableData *data = [NSMutableData dataWithBytes:header length:headerSize];
        [data appendData:parameters];
        [device writeCommandRegister:data withResponse:self.needsResponse];
        return nil;
    }];
    // Make sure the decrement is placed on the queue in such a way that it happens after
    // all the read callbacks have finished
    [source.task continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        [BFTask taskFromMetaWearWithBlock:^id{
            [device decrementCount];
            return nil;
        }];
        return nil;
    }];
    return source.task;
}

- (BFTask *)readAsync
{
    return [self sendDataToDevice:[self readParameters] isRead:YES isLocal:NO];
}

- (nonnull BFTask *)readForcedIndexAsync:(uint8_t)index
{
    return [self sendDataToDevice:[NSData dataWithBytes:&index length:1] isRead:YES isLocal:NO];
}

- (BFTask *)localReadAsync
{
    return [self sendDataToDevice:[self readParameters] isRead:YES isLocal:YES];
}

- (NSData *)readParameters
{
    NSData *params = nil;
    if (self.index != 0xFF) {
        params = [NSData dataWithBytes:&_index length:1];
    }
    return params;
}


- (BFTask *)writeByteAsync:(uint8_t)byte
{
    return [self writeDataAsync:[NSData dataWithBytes:&byte length:1]];
}

- (BFTask *)writeDataAsync:(NSData *)params
{
    return [self sendDataToDevice:params isRead:NO isLocal:NO];
}

- (BFTask *)startNotificationsWithHandlerAsync:(MBLObjectHandler)handler
{
    return [self startNotificationsWithExecutorAsync:[BFExecutor dispatchExecutor] withHandler:handler];
}

- (BFTask *)startNotificationsWithExecutorAsync:(BFExecutor *)executor withHandler:(nullable MBLObjectHandler)handler
{
    MBLMetaWear *device = self.module.device;
    if (device.state != MBLConnectionStateConnected) {
        NSError *error = [NSError errorWithDomain:kMBLErrorDomain
                                             code:kMBLErrorNotConnected
                                         userInfo:@{NSLocalizedDescriptionKey : @"MetaWear not connected, can't perform operation.  Please connect to MetaWear before streaming data."}];
        if (handler) {
            [executor execute:^{
                handler(nil, error);
            }];
        }
        return [BFTask taskWithError:error];
    }
    
    [device incrementCount];
    return [BFTask taskFromMetaWearWithBlock:^id{
        [self addNotificationWithExecutor:executor handler:handler];
        // Shortcut if we are already all setup
        if (!self.isNotifyingImpl) {
            self.isNotifyingImpl = YES;
            
            startNotificationTask = [[[[self initializeAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
                return [self performAsyncStartNotifications];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
                return [self activateAsync];
            }] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                [device decrementCount];
                return task;
            }];
        } else {
            [device decrementCount];
        }
        return startNotificationTask;
    }];
}

- (BFTask *)performAsyncStartNotifications
{
    // Indexed registers and periodic read registers arn't equiped to take notification bytes
    if (self.index == 0xFF && !(self.registerId & 0x80)) {
        return [self sendByteToDevice:0x1 isRead:NO];
    }
    return [BFTask taskWithResult:nil];
}

- (BFTask *)stopNotificationsAsync
{
    MBLMetaWear *device = self.module.device;
    if (device.state != MBLConnectionStateConnected) {
        NSError *error = [NSError errorWithDomain:kMBLErrorDomain
                                             code:kMBLErrorNotConnected
                                         userInfo:@{NSLocalizedDescriptionKey : @"MetaWear not connected, can't perform operation.  Notifications will automatically be stopped on next connect."}];
        return [BFTask taskWithError:error];
    }
    
    [device incrementCount];
    return [BFTask taskFromMetaWearWithBlock:^id{
        // Do nothing if we notifications are not enabled
        if (self.isNotifyingImpl) {
            self.isNotifyingImpl = NO;
            
            [self removeNotificationHandlers];
            
            stopNotificationTask = [[[[self deactivateAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
                return [self performAsyncStopNotificationsAsync];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
                return [self deinitializeAsync];
            }] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                [device decrementCount];
                return task;
            }];
        } else {
            [device decrementCount];
        }
        return stopNotificationTask;
    }];
}

- (BFTask *)performAsyncStopNotificationsAsync
{
    // Indexed registers and periodic read registers arn't equiped to take notification bytes
    if (self.index == 0xFF && !(self.registerId & 0x80)) {
        return [self sendByteToDevice:0x0 isRead:NO];
    }
    return [BFTask taskWithResult:nil];
}

- (void)addNotificationWithExecutor:(BFExecutor *)executor handler:(MBLObjectHandler)handler
{
    assert([MBLConstants isMetaWearQueue]);
    if (handler) {
        MBLObjectHandler wrappedHandler = ^(id obj, NSError *error) {
            [executor execute:^{
                handler(obj, error);
            }];
        };
        [notifyCallbacks addObject:wrappedHandler];
    }
}

- (void)removeNotificationHandlers
{
    dispatch_async([MBLConstants metaWearQueue], ^{
        [notifyCallbacks removeAllObjects];
    });
}

- (void)recievedData:(NSData *)data error:(NSError *)error
{
    assert([MBLConstants isMetaWearQueue]);
    id formattedObj = nil;
    if (data) {
        // Transform the NSData into a register specific object
        MBLFormat *format = self.format;
        NSData *trimmed = [data subdataWithRange:NSMakeRange(format.offset, MIN(format.length, data.length - format.offset))];
        formattedObj = [format entryFromData:trimmed date:[NSDate date]];
    }
    
    // Callbacks are used for one time read/write calls, so the block is deleted
    // immediately after it's used
    if (taskSources.count) {
        // We assume the data comes back in the order it was requested
        BFTaskCompletionSource *source = taskSources.firstObject;
        [taskSources removeObjectAtIndex:0];
        if (error) {
            [source trySetError:error];
        } else {
            [source trySetResult:formattedObj];
        }
    }
    
    // Notify Callbacks are used when we subscribe to MetaWear registers, so we don't
    // delete them until removeNotificationHandlers is called
    for (MBLObjectHandler callback in notifyCallbacks) {
        // callback are alredy wrapped to execute on the correct queue
        if ([formattedObj conformsToProtocol:@protocol(NSFastEnumeration)]) {
            for (id obj in formattedObj) {
                callback(obj, error);
            }
        } else {
            callback(formattedObj, error);
        }
    }
}

- (void)deviceDisconnected:(NSError *)error
{
    assert([MBLConstants isMetaWearQueue]);
    BOOL noError = error == nil;
    if (!error) {
        error = [NSError errorWithDomain:kMBLErrorDomain
                                    code:kMBLErrorUnexpectedDisconnect
                                userInfo:@{NSLocalizedDescriptionKey : @"Unexpected disconnect.  Please connect again to perform operation."}];
    }
    
    // Let anyone who is waiting on a callback know it's not going to happen
    for (BFTaskCompletionSource *source in taskSources) {
        [source trySetError:error];
    }
    [taskSources removeAllObjects];
    
    // Special warning letting the SDK user know they forgot to clean up a notifying resource
    if (self.isNotifyingImpl && noError) {
        MBLLog(MBLLogLevelWarning, @"Forgot to stop all notifications before disconnecting");
    }
    for (MBLObjectHandler callback in notifyCallbacks) {
        [[MBLMetaWearManager dispatchQueue] addOperationWithBlock:^{
            callback(nil, error);
        }];
    }
    [notifyCallbacks removeAllObjects];
}

- (BFTask *)deviceConnected
{
    if (self.isNotifyingImpl) {
        return [self stopNotificationsAsync];
    }
    return [BFTask taskWithResult:nil];
}

- (BFTask *)initializeAsync
{
    return [BFTask taskFromMetaWearWithBlock:^id{
        self.initializeCount++;
        if (self.initializeCount == 1) {
            // Initialize the module then initialize us
            initializeTask = [[[self.module initializeAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
                return [self performAsyncInitialization];
            }] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                if (task.faulted) {
                    self.initializeCount--;
                }
                return task;
            }];
        }
        return initializeTask;
    }];
}

- (BFTask *)deinitializeAsync
{
    return [BFTask taskFromMetaWearWithBlock:^id{
        self.initializeCount--;
        if (self.initializeCount == 0) {
            // Deinitialize us then deinitialize the module
            deinitializeTask = [[[self performAsyncDeinitialization] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
                return [self.module deinitializeAsync];
            }] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                if (task.faulted) {
                    self.initializeCount++;
                }
                return task;
            }];
        }
        NSAssert(self.initializeCount >= 0, @"init/deinit calls unbalanced.");
        self.initializeCount = MAX(self.initializeCount, 0);
        return deinitializeTask;
    }];
}

- (BFTask *)activateAsync
{
    return [BFTask taskFromMetaWearWithBlock:^id{
        self.activateCount++;
        if (self.activateCount == 1) {
            activateTask = [[[self performAsyncActivation] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
                return [self.module activateAsync];
            }] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                if (task.faulted) {
                    self.activateCount--;
                }
                return task;
            }];
        }
        return activateTask;
    }];
}

- (BFTask *)deactivateAsync
{
    return [BFTask taskFromMetaWearWithBlock:^id{
        self.activateCount--;
        if (self.activateCount == 0) {
            activateTask = [[[self.module deactivateAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
                return [self performAsyncDeactivation];
            }] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                if (task.faulted) {
                    self.activateCount++;
                }
                return task;
            }];
        }
        NSAssert(self.activateCount >= 0, @"activate/deactivate calls unbalanced.");
        self.activateCount = MAX(self.activateCount, 0);
        return activateTask;
    }];
}

- (BFTask *)performAsyncInitialization
{
    return [BFTask taskWithResult:nil];
}

- (BFTask *)performAsyncDeinitialization
{
    return [BFTask taskWithResult:nil];
}

- (BFTask *)performAsyncActivation
{
    return [BFTask taskWithResult:nil];
}

- (BFTask *)performAsyncDeactivation
{
    return [BFTask taskWithResult:nil];
}

@end
