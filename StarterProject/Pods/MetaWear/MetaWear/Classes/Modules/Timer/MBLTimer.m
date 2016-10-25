/**
 * MBLTimer.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 1/12/15.
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

#import "MBLTimer+Private.h"
#import "MBLTimerEvent+Private.h"
#import "MBLRegister+Private.h"
#import "MBLModule+Private.h"
#import "MBLNumericFormatter.h"
#import "MBLDataSample.h"
#import "MBLMetaWearManager+Private.h"
#import "MBLEntityEvent+Private.h"
#import "MBLDeviceInfo.h"
#import "MBLMetaWear+Private.h"
#import "BFTask+Private.h"
#import "MBLConstants+Private.h"


static const uint16_t MW_TIMER_REPEAT_FOREVER = 0xFFFF;

@interface MBLTimer ()

@end

@implementation MBLTimer

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        MBLRegister *globalEnable = [[MBLRegister alloc] initWithModule:self registerId:0x1 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
        MBLRegister *addTimer = [[MBLRegister alloc] initWithModule:self registerId:0x2 format:[[MBLFormat alloc] initEncodedDataWithLength:7]];
        MBLRegister *startTimer = [[MBLRegister alloc] initWithModule:self registerId:0x3 format:[MBLFormat writeOnly]];
        MBLRegister *stopTimer = [[MBLRegister alloc] initWithModule:self registerId:0x4 format:[MBLFormat writeOnly]];
        MBLRegister *removeTimer = [[MBLRegister alloc] initWithModule:self registerId:0x5 format:[MBLFormat writeOnly]];
        MBLRegister *notification = [[MBLRegister alloc] initWithModule:self registerId:0x6 format:[[MBLFormat alloc] initEncodedDataWithLength:1]];
        MBLRegister *notificationEnable = [[MBLRegister alloc] initWithModule:self registerId:0x7 format:[MBLFormat writeOnly]];
        
        int maxTimers = 4; // This was the old default
        if (moduleInfo.moduleData.length) {
            maxTimers = *(uint8_t *)moduleInfo.moduleData.bytes;
        }
        
        NSString *curVersion = device.deviceInfo.firmwareRevision;
        if ([MBLConstants versionString:curVersion isLessThan:@"1.1.0"]) {
            startTimer.needsResponse = YES;
        }
        
        addTimer.writeResponds = YES;
        
        self.globalEnable = globalEnable;
        
        self.addEntity = addTimer;
        self.removeEntity = removeTimer;
        
        self.activateEntity = startTimer;
        self.deactivateEntity = stopTimer;
        
        self.globalNotifications = notification;
        self.notificationEnable = notificationEnable;
        
        self.maxEntities = maxTimers;
    }
    return self;
}

- (BFTask *)startTimer:(MBLTimerEvent *)timer
{
    return [BFTask taskFromMetaWearWithBlock:^id _Nonnull{
        if (timer.index != 0xFF) {
            return [self.activateEntity writeByteAsync:timer.index];
        }
        return nil;
    }];
}

- (BFTask *)stopTimer:(MBLTimerEvent *)timer
{
    return [BFTask taskFromMetaWearWithBlock:^id _Nonnull{
        if (timer.index != 0xFF) {
            return [self.deactivateEntity writeByteAsync:timer.index];
        }
        return nil;
    }];
}

- (MBLTimerEvent *)eventWithPeriod:(uint32_t)period
                       eventCount:(uint16_t)eventCount
                         autoStart:(BOOL)autoStart
                    triggerOnStart:(BOOL)triggerOnStart
{
    // Since all filters get their data through the single timerNotification register in
    // the timer module, we create a dummy register which is optionally notified
    // when we see a global notification which matches our filter id
    mw_timer_param_t params = {0};
    params.period = period;
    params.repeat_count = eventCount;
    params.notify_on_start = triggerOnStart ? 1 : 0;
    
    return [[MBLTimerEvent alloc] initWithModule:self
                                      registerId:self.globalNotifications.registerId
                             addEntityParameters:[NSData dataWithBytes:&params length:sizeof(mw_timer_param_t)]
                                          format:[[MBLFormat alloc] initEncodedDataWithLength:0]
                                       autoStart:autoStart];
}

- (MBLTimerEvent *)eventWithPeriod:(uint32_t)period
                       eventCount:(uint16_t)eventCount
                         autoStart:(BOOL)autoStart
{
    return [self eventWithPeriod:period eventCount:eventCount autoStart:autoStart triggerOnStart:YES];
}

- (MBLTimerEvent *)eventWithPeriod:(uint32_t)period
                       eventCount:(uint16_t)eventCount
{
    return [self eventWithPeriod:period eventCount:eventCount autoStart:YES];
}

- (MBLTimerEvent *)eventWithPeriod:(uint32_t)period
{
    return [self eventWithPeriod:period eventCount:MW_TIMER_REPEAT_FOREVER];
}

@end
