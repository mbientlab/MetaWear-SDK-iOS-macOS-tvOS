/**
 * MBLDispatchQueue.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 11/2/15.
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

#import "MBLDispatchQueue.h"
#import "MBLMetaWearManager+Private.h"

@interface MBLDispatchQueue ()
@property (nonatomic) NSObject *queueMutex;
@property (nonatomic) NSOperationQueue *queue;
@property (nonatomic) int suspendCount;
@end

@implementation MBLDispatchQueue

- (instancetype)initWithName:(NSString *)name
{
    self = [super init];
    if (self) {
        self.queueMutex = [[NSObject alloc] init];
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.name = name;
        self.queue.maxConcurrentOperationCount = 1;
        self.suspendCount = 0;
    }
    return self;
}

- (void)addOperationWithBlock:(MBLVoidHandler)block
{
    if (block) {
        @synchronized(self.queueMutex) {
            [self.queue addOperationWithBlock:block];
        }
    }
}

- (BOOL)suspend
{
    BOOL wasSuspended = YES;
    @synchronized(self.queueMutex) {
        if (self.suspendCount == 0) {
            self.queue.suspended = YES;
            wasSuspended = NO;
        }
        self.suspendCount++;
    }
    return wasSuspended;
}

- (void)resume
{
    @synchronized(self.queueMutex) {
        if (self.suspendCount == 1) {
            self.queue.suspended = NO;
        }
        if (self.suspendCount > 0) {
            self.suspendCount--;
        }
    }
}

- (void)forceResume
{
    @synchronized(self.queueMutex) {
        self.suspendCount = 0;
        self.queue.suspended = NO;
    }
}

- (void)reset
{
    @synchronized(self.queueMutex) {
        [self.queue cancelAllOperations];
        self.suspendCount = 0;
        self.queue.suspended = NO;
    }
}

@end
