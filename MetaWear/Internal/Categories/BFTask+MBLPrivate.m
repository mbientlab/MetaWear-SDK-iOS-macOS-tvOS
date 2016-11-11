/**
 * BFTask+Private.m
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

#import "BFTask+MBLPrivate.h"
#import "MBLConstants+Private.h"

@implementation BFExecutor (MBLPrivate)

+ (BFExecutor *)metaWearExecutor
{
    static BFExecutor *singleton;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        singleton = [BFExecutor executorWithDispatchQueue:[MBLConstants metaWearQueue]];
    });
    return singleton;
}

+ (BFExecutor *)simulatorExecutor
{
    static BFExecutor *singleton;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        // Time simulator queue is like a sub-queue of metaWearQueue
        singleton = [BFExecutor executorWithBlock:^void(void(^block)()) {
            dispatch_async([MBLConstants metaWearQueue], ^{
                dispatch_sync([MBLConstants simulatorQueue], block);
            });
        }];
    });
    return singleton;
}
@end

@implementation BFTask (Private)

- (BFTask *)successOnMetaWear:(MBLPrivateSuccessBlock)block
{
    return [self continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        block(task.result);
        return task;
    }];
}

- (BFTask *)failureOnMetaWear:(MBLPrivateErrorBlock)block
{
    return [self continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        if (task.error) {
            block(task.error);
        }
        return task;
    }];
}

- (BFTask *)continueOnMetaWearWithSuccessBlock:(MBLPrivateContinuationBlock)block
{
    BFExecutor *executor = [MBLConstants isSimulatorQueue] ? [BFExecutor simulatorExecutor] : [BFExecutor metaWearExecutor];
    return [self continueWithExecutor:executor withSuccessBlock:block];
}

- (BFTask *)continueOnMetaWearWithBlock:(MBLPrivateContinuationBlock)block
{
    BFExecutor *executor = [MBLConstants isSimulatorQueue] ? [BFExecutor simulatorExecutor] : [BFExecutor metaWearExecutor];
    return [self continueWithExecutor:executor withBlock:block];
}

+ (instancetype)taskFromMetaWearWithBlock:(id (^)())block {
    BFExecutor *executor = [MBLConstants isSimulatorQueue] ? [BFExecutor simulatorExecutor] : [BFExecutor metaWearExecutor];
    return [[self taskWithResult:nil] continueWithExecutor:executor withBlock:^id(BFTask *task) {
        return block();
    }];
}

+ (instancetype)taskFromSimulatorWithBlock:(id (^)())block
{
    return [[self taskWithResult:nil] continueWithExecutor:[BFExecutor simulatorExecutor] withBlock:^id(BFTask *task) {
        return block();
    }];
}

@end

void MBLForceLoadCategory_BFTask_Private()
{
    NSString *string = nil;
    [string description];
}
