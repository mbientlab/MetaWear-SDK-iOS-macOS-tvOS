/**
 * MBLEntityModule.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 12/3/15.
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


#import "MBLEntityModule+Private.h"

@interface MBLEntityModule ()
@property (nonatomic) int activeNotifications;
@property (nonatomic) NSMutableArray *entities;
@property (nonatomic) int maxEntities;

@property (nonatomic) MBLRegister *addEntity;
@property (nonatomic) MBLRegister *removeEntity;
@property (nonatomic) MBLRegister *activateEntity;
@property (nonatomic) MBLRegister *deactivateEntity;

@property (nonatomic) MBLRegister *globalNotifications;
@property (nonatomic) MBLRegister *notificationEnable;
@end

@implementation MBLEntityModule

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        self.activeNotifications = 0;
        self.entities = [NSMutableArray array];
        self.maxEntities = 0;
    }
    return self;
}


- (BFTask *)performAsyncInitializationForEntity:(MBLEntityEvent *)entity
{
    if (!self.addEntity) {
        return [BFTask taskWithResult:nil];
    }
    
    return [[BFTask taskFromMetaWearWithBlock:^id _Nonnull{
        assert(entity.index == 0xFF);
        if (self.entities.count >= self.maxEntities) {
            NSError *error = [NSError errorWithDomain:kMBLErrorDomain
                                                 code:kMBLErrorInsufficientMemory
                                             userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"MetaWear out of memory, can't perform action.  Reset the MetaWear and use no more than %d entities", self.maxEntities]}];
            return [BFTask taskWithError:error];
        }
        [self.entities addObject:entity];
        return [self.addEntity writeDataAsync:entity.addEntityParameters];
    }] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        if (task.faulted) {
            [self.entities removeObject:entity];
        } else {
            MBLDataSample *obj = task.result;
            entity.index = *(uint8_t *)obj.data.bytes;
        }
        return task;
    }];
}

- (BFTask *)performAsyncDeinitializationForEntity:(MBLEntityEvent *)entity
{
    if (!self.removeEntity) {
        return [BFTask taskWithResult:nil];
    }
    
    return [[BFTask taskFromMetaWearWithBlock:^id _Nonnull{
        assert(entity.index != 0xFF);
        return [self.removeEntity writeByteAsync:entity.index];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        entity.index = 0xFF;
        [self.entities removeObject:entity];
        return nil;
    }];
}

- (BFTask *)performAsyncActivationForEntity:(MBLEntityEvent *)entity
{
    if (!self.activateEntity) {
        return [BFTask taskWithResult:nil];
    }
    
    return [BFTask taskFromMetaWearWithBlock:^id _Nonnull{
        assert(entity.index != 0xFF);
        return [self.activateEntity writeByteAsync:entity.index];
    }];
}

- (BFTask *)performAsyncDeactivationForEntity:(MBLEntityEvent *)entity
{
    if (!self.deactivateEntity) {
        return [BFTask taskWithResult:nil];
    }
    
    return [BFTask taskFromMetaWearWithBlock:^id _Nonnull{
        assert(entity.index != 0xFF);
        return [self.deactivateEntity writeByteAsync:entity.index];
    }];
}

- (BFTask *)startNotificationsForEntity:(MBLEntityEvent *)entity
{
    if (!self.globalNotifications || !self.notificationEnable) {
        return [BFTask taskWithResult:nil];
    }
    
    return [[BFTask taskFromMetaWearWithBlock:^id _Nonnull{
        // Turn on notifications for this filter
        assert(entity.index != 0xFF);
        uint8_t packet[] = { entity.index, 0x1 };
        return [self.notificationEnable writeDataAsync:[NSData dataWithBytes:&packet length:2]];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        self.activeNotifications++;
        if (self.activeNotifications == 1) {
            // Turn on global notifications
            return [self.globalNotifications startNotificationsWithHandlerAsync:nil];
        }
        return nil;
    }];
}

- (BFTask *)stopNotificationsAsyncForEntity:(MBLEntityEvent *)entity
{
    if (!self.globalNotifications || !self.notificationEnable) {
        return [BFTask taskWithResult:nil];
    }
    
    return [[BFTask taskFromMetaWearWithBlock:^id _Nonnull{
        self.activeNotifications--;
        if (self.activeNotifications == 0) {
            // Turn off global notifications
            return [self.globalNotifications stopNotificationsAsync];
        }
        assert(self.activeNotifications >= 0);
        self.activeNotifications = MAX(self.activeNotifications, 0);
        return nil;
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        // Turn off notifications for this filter
        assert(entity.index != 0xFF);
        uint8_t data[] = { entity.index, 0x0 };
        return [self.notificationEnable writeDataAsync:[NSData dataWithBytes:&data length:2]];
    }];
}

- (BFTask *)isStateValid
{
    return [BFTask taskFromMetaWearWithBlock:^id _Nonnull{
        NSMutableArray *tasks = [NSMutableArray array];
        [tasks addObject:[BFTask taskWithResult:@YES]]; // Base case
        for (MBLEntityEvent *entity in self.entities) {
            [tasks addObject:[entity isStateValid]];
        }
        return [BFTask taskForCompletionOfAllTasksWithResults:tasks];
    }];
}

@end
