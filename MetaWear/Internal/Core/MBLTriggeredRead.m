/**
 * MBLTriggeredRead.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 1/27/15.
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

#import "MBLTriggeredRead.h"
#import "MBLData+Private.h"
#import "MBLEvent+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLTimer+Private.h"
#import "MBLMetaWearManager+Private.h"
#import "BFTask+MBLPrivate.h"
#import "MBLTimerEvent+Private.h"

typedef struct __attribute__((packed)) {
    uint8_t				module_id;
    uint8_t				register_id;
    uint8_t				index;
    uint8_t				offset:5;
    uint8_t				len:3;
} filter_param_t;

@interface MBLTriggeredRead ()
@property (nonatomic) MBLData *data;
@property (nonatomic) MBLEvent *trigger;
@end

@implementation MBLTriggeredRead

- (instancetype)initWithData:(MBLData *)data
                     trigger:(MBLEvent *)trigger
{
    self = [super initWithModule:data.module registerId:data.registerId | 0x80 format:data.format];
    if (self) {
        self.data = data;
        self.trigger = trigger;
    }
    return self;
}

- (instancetype)initWithData:(MBLData *)data
                      period:(uint32_t)period
                  eventCount:(uint16_t)eventCount
{
    return [self initWithData:data trigger:[data.module.device.timer eventWithPeriod:period eventCount:eventCount]];
}

- (BFTask *)performAsyncInitialization
{
    return [[self.data initializeAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        BOOL localRead = !self.isNotifyingImpl;
        if (localRead) {
            self.registerId |= 0x40; // Set the local read bit
        }
        self.index = self.data.index;
        return task;
    }];
}

- (BFTask *)performAsyncDeinitialization
{
    return [[self.data deinitializeAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        self.registerId &= 0xBF; // Clear the local read bit
        self.index = 0xFF;
        return task;
    }];
}

- (BFTask *)performAsyncActivation
{
    return [[self.data activateAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        BOOL localRead = !self.isNotifyingImpl;
        return [self.trigger programCommandsToRunOnEventAsync:^{
            [self.data simulatedReadAsync:localRead];
        }];
    }];
}

- (BFTask *)performAsyncDeactivation
{
    return [[self.data deactivateAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [self.trigger eraseCommandsToRunOnEventAsync];
    }];
}

@end

