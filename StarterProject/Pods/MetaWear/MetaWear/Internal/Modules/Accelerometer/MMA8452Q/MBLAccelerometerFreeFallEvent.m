/**
 * MBLAccelerometerFreeFallEvent.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 10/23/14.
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

#import "MBLAccelerometerFreeFallEvent.h"
#import "MBLAccelerometerMMA8452Q+Private.h"
#import "MBLNumericFormatter.h"
#import "mma8452q.h"

@interface MBLAccelerometerFreeFallEvent ()
@property (nonatomic) MBLRegister *motionEnable;
@property (nonatomic) MBLRegister *motionSettings;
@end

@implementation MBLAccelerometerFreeFallEvent

- (instancetype)initWithAccelerometer:(MBLAccelerometerMMA8452Q *)accelerometer
{
    self = [super initWithModule:accelerometer registerId:0x7 format:[[MBLFormat alloc] initEncodedDataWithLength:1]];
    if (self) {
        self.motionEnable = [[MBLRegister alloc] initWithModule:accelerometer registerId:0x05 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
        self.motionSettings = [[MBLRegister alloc] initWithModule:accelerometer registerId:0x06 format:[[MBLFormat alloc] initEncodedDataWithLength:4]];
    }
    return self;
}

- (BFTask *)performAsyncActivation
{
    NSMutableArray *tasks = [NSMutableArray array];
    BOOL strobeGlobalEnable = self.module.activateCount;
    MBLAccelerometerMMA8452Q *accelerometer = (MBLAccelerometerMMA8452Q *)self.module;
    mma8452q_ff_mt_regs_t regs = { 0 };
    
    regs.ff_mt_cfg.ele = YES; // Event flags are latched into FF_MT_SRC register
    
    regs.ff_mt_cfg.oae = NO; // Freefall Flag (Logical AND combination)
    regs.ff_mt_cfg.zefe = YES; // Make sure all axis are in low G's
    regs.ff_mt_cfg.yefe = YES;
    regs.ff_mt_cfg.xefe = YES;
    
    regs.ff_mt_ths.ths = [accelerometer scalePulseThreshold:accelerometer.freeFallThreshold];
    regs.ff_mt_count.count = [accelerometer scaleFreeFallMotionDebounceCounter:accelerometer.freeFallWidth];
    
    if (strobeGlobalEnable) {
        [tasks addObject:[accelerometer.globalEnable writeByteAsync:0x0]];
    }
    [tasks addObject:[self.motionSettings writeDataAsync:[NSData dataWithBytes:&regs length:sizeof(mma8452q_ff_mt_regs_t)]]];
    [tasks addObject:[self.motionEnable writeByteAsync:0x1]];
    if (strobeGlobalEnable) {
        [tasks addObject:[accelerometer.globalEnable writeByteAsync:0x1]];
    }
    return [BFTask taskForCompletionOfAllTasks:tasks];
}

- (BFTask *)performAsyncDeactivation
{
    return [self.motionEnable writeByteAsync:0x0];
}

@end
