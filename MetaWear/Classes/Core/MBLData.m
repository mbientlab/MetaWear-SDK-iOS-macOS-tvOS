/**
 * MBLData.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 1/23/15.
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

#import "MBLData+Private.h"
#import "MBLRegister+Private.h"
#import "MBLTimer+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLTriggeredRead.h"
#import "MBLConstants+Private.h"
#import "BFTask+MBLPrivate.h"
#import "BFTask+MBLExtensions.h"
#import "MBLDownloadOnlyEvent.h"


@implementation MBLData

- (instancetype)initWithModule:(MBLModule *)module registerId:(uint8_t)registerId index:(uint8_t)index format:(MBLFormat *)format identifier:(nullable NSString *)identifier
{
    self = [super initWithModule:module registerId:registerId index:index format:format identifier:identifier];
    if (self) {
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

- (BFTask *)simulatedReadAsync:(BOOL)isLocal
{
    assert([MBLConstants isSimulatorQueue]);
    MBLMetaWear *device = self.module.device;
    
    // Increment the simulator queue
    [device incrementCount];
    return [[[[[BFTask taskFromExecutor:[BFExecutor metaWearExecutor] withBlock:^id _Nonnull{
        return [self initializeAsync];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [self activateAsync];
    }] continueWithExecutor:[BFExecutor simulatorExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
        return isLocal ? [super localReadAsync] : [super readAsync];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        NSAssert(device.command.activatedRegHandler, @"activatedRegHandler need to be set.");
        device.command.activatedRegHandler(self, nil);
        return task;
    }] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        [device decrementCount];
        return task;
    }];
}

- (BFTask *)readAsync
{
    if ([MBLConstants isSimulatorQueue]) {
        return [self simulatedReadAsync:NO];
    }
    
    MBLMetaWear *device = self.module.device;
    [device incrementCount];
    BFTask __block *resultTask = nil;
    return [[[[[[self initializeAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [self activateAsync];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [super readAsync];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        resultTask = task;
        return [self deactivateAsync];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [self deinitializeAsync];
    }] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        [device decrementCount];
        return task.faulted ? task : resultTask;
    }];
}

- (void)addNotificationsHandler:(MBLDataNotificationHandler)handler
{
    dispatch_async([MBLConstants metaWearQueue], ^{
        [super addNotificationWithExecutor:[BFExecutor dispatchExecutor] handler:handler];
    });
}

- (void)removeNotificationHandlers
{
    [super removeNotificationHandlers];
}

- (BFTask *)addLoggingEntry
{
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    MBLEvent *event = [[MBLDownloadOnlyEvent alloc] initWithModule:self.module registerId:self.registerId | 0xC0 index:self.index format:self.format];
    [[[event startLoggingAsync] success:^(id  _Nonnull result) {
        [source trySetResult:event];
    }] failure:^(NSError * _Nonnull error) {
        [source trySetError:error];
    }];
    return source.task;
}

- (MBLEvent *)periodicReadWithPeriod:(uint32_t)period
                          eventCount:(uint16_t)eventCount
{
    return [[MBLTriggeredRead alloc] initWithData:self period:period eventCount:eventCount];
}

- (MBLEvent *)periodicReadWithPeriod:(uint32_t)period
{
    return [self periodicReadWithPeriod:period eventCount:0xFFFF];
}

@end
