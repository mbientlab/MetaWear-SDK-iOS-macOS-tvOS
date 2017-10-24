/**
 * MBLModule.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 10/22/14.
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

#import "MBLModule+Private.h"
#import "MBLRegister+Private.h"
#import "MBLEvent+Private.h"
#import "MBLFilter.h"
#import "MBLConstants+Private.h"
#import "BFTask+MBLPrivate.h"

@interface MBLModule ()
@property (nonatomic, weak) MBLMetaWear *device;
@property (nonatomic) NSMutableArray *registers;
@property (nonatomic) MBLModuleInfo *moduleInfo;

@property (nonatomic) int initializeCount;
@property (nonatomic) int activateCount;
@property (nonatomic) MBLRegister *globalEnable;
@end

@implementation MBLModule {
    BFTask          *initializeTask;
    BFTask          *deinitializeTask;
    BFTask          *activateTask;
    BFTask          *deactivateTask;
}

+ (instancetype)objectWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    return [[self alloc] initWithDevice:device moduleInfo:moduleInfo];
}

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super init];
    if (self) {
        self.device = device;
        self.registers = [NSMutableArray array];
        self.moduleInfo = moduleInfo;
        
        self.initializeCount = 0;
        self.activateCount = 0;
        
        initializeTask = [BFTask taskWithResult:nil];
        deinitializeTask = [BFTask taskWithResult:nil];
        activateTask = [BFTask taskWithResult:nil];
        deactivateTask = [BFTask taskWithResult:nil];
    }
    return self;
}

- (id)awakeAfterFastCoding
{
    initializeTask = [BFTask taskWithResult:nil];
    deinitializeTask = [BFTask taskWithResult:nil];
    activateTask = [BFTask taskWithResult:nil];
    deactivateTask = [BFTask taskWithResult:nil];
    
    return self;
}

- (BFTask *)isStateValid
{
    return [BFTask taskForCompletionOfAllTasksWithResults:@[[BFTask taskWithResult:@YES]]];
}

- (void)addRegister:(MBLRegister *)reg
{
    dispatch_async([MBLConstants metaWearQueue], ^{
        [self.registers addObject:reg];
    });
}

- (BFTask *)getRegister:(NSData *)data
{
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    const uint8_t *bytes = data.bytes;
    // Decompose the data coming from the MetaWear firmware, see the firwmare API guide
    // for details on the protocol
    uint8_t registerId = *(bytes + 1) & 0x3F; // Strip off the "[local] read bit"
    uint8_t index = 0xFF;
    // If the register contains an index it would be at byte 3, note the index isn't required
    if (data.length > 2) {
        index = *(bytes + 2);
    }
    dispatch_async([MBLConstants metaWearQueue], ^{
        for (MBLRegister *obj in self.registers) {
            // See if we have a register id match
            if ((obj.registerId & 0x3F) == registerId) {
                // If the register doesn't expect an index then give it the data!  However, if it does
                // then the indexs must match.
                if (obj.index == 0xFF) {
                    [source trySetResult:obj];
                } else if (obj.index == index) {
                    [source trySetResult:obj];
                }
            }
        }
        [source trySetResult:nil];
    });
    return source.task;
}

- (void)recievedData:(NSData *)data error:(NSError *)error
{
    // Decompose the data coming from the MetaWear firmware, see the firwmare API guide
    // for details on the protocol
    uint8_t registerId = (*(uint8_t *)(data.bytes + 1)) & 0x7F; // Strip off the "read bit"
    uint8_t index = 0xFF;
    // If the register contains an index it would be at byte 3, note the index isn't required
    if (data.length > 2) {
        index = *(uint8_t *)(data.bytes + 2);
    }
    // sync because a new register is created inside [obj recievedData:error:], which then
    // breaks this because the collection would be modified while iterating
    dispatch_async([MBLConstants metaWearQueue], ^{
        for (MBLRegister *obj in self.registers) {
            // See if we have a register id match
            if ((obj.registerId & 0x7F) == registerId) {
                // If the register doesn't expect an index then give it the data!  However, if it does
                // then the indexs must match.
                if (obj.index == 0xFF) {
                    [obj recievedData:[data subdataWithRange:NSMakeRange(2, data.length - 2)] error:error];
                } else if (obj.index == index) {
                    [obj recievedData:[data subdataWithRange:NSMakeRange(3, data.length - 3)] error:error];
                }
            }
        }
    });
}

- (void)deviceDisconnected:(NSError *)error
{
    for (MBLRegister *obj in self.registers) {
        [obj deviceDisconnected:error];
    }
}

- (BFTask *)deviceConnected
{
    NSMutableArray *tasks = [NSMutableArray arrayWithCapacity:self.registers.count];
    for (MBLRegister *obj in self.registers) {
        [tasks addObject:[obj deviceConnected]];
    }
    return [BFTask taskForCompletionOfAllTasks:tasks];
}

- (BFTask *)initializeAsync
{
    return [BFTask taskFromMetaWearWithBlock:^id{
        self.initializeCount++;
        if (self.initializeCount == 1) {
            initializeTask = [[self performAsyncInitialization] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
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
            deinitializeTask = [[self performAsyncDeinitialization] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
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
            activateTask = [[self performAsyncActivation] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
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
            activateTask = [[self performAsyncDeactivation] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
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
    if (self.globalEnable) {
        return [self.globalEnable writeByteAsync:0x1];
    }
    return [BFTask taskWithResult:nil];
}

- (BFTask *)performAsyncDeactivation
{
    if (self.globalEnable) {
        return [self.globalEnable writeByteAsync:0x0];
    }
    return [BFTask taskWithResult:nil];
}

@end
