/**
 * MBLAccelerometerShakeEvent.m
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

#import "MBLAccelerometerShakeEvent.h"
#import "MBLAccelerometerMMA8452Q+Private.h"
#import "MBLNumericFormatter.h"
#import "mma8452q.h"

@interface MBLAccelerometerShakeEvent ()
@property (nonatomic) MBLRegister *transientEnable;
@property (nonatomic) MBLRegister *transientSettings;
@end

@implementation MBLAccelerometerShakeEvent

- (instancetype)initWithAccelerometer:(MBLAccelerometerMMA8452Q *)accelerometer
{
    self = [super initWithModule:accelerometer registerId:0x10 format:[[MBLFormat alloc] initEncodedDataWithLength:1] identifier:@"mma8452q-shake"];
    if (self) {
        self.transientEnable = [[MBLRegister alloc] initWithModule:accelerometer registerId:0x0E format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
        self.transientSettings = [[MBLRegister alloc] initWithModule:accelerometer registerId:0x0F format:[[MBLFormat alloc] initEncodedDataWithLength:4]];
    }
    return self;
}

- (BFTask *)performAsyncActivation
{
    NSMutableArray *tasks = [NSMutableArray array];
    BOOL strobeGlobalEnable = self.module.activateCount;
    MBLAccelerometerMMA8452Q *accelerometer = (MBLAccelerometerMMA8452Q *)self.module;
    mma8452q_transient_regs_t regs = { 0 };
    
    regs.transient_cfg.ele = YES;
    regs.transient_cfg.ztefe = YES;
    regs.transient_cfg.ytefe = YES;
    regs.transient_cfg.xtefe = YES;
    
    regs.transient_ths.ths = [accelerometer scalePulseThreshold:accelerometer.shakeThreshold];
    
    regs.transient_count.dbnce = [accelerometer scaleTransientDebounceCounter:accelerometer.shakeWidth];

    if (strobeGlobalEnable) {
        [tasks addObject:[accelerometer.globalEnable writeByteAsync:0x0]];
    }
    [tasks addObject:[self.transientSettings writeDataAsync:[NSData dataWithBytes:&regs length:sizeof(mma8452q_transient_regs_t)]]];
    [tasks addObject:[self.transientEnable writeByteAsync:0x1]];
    if (strobeGlobalEnable) {
        [tasks addObject:[accelerometer.globalEnable writeByteAsync:0x1]];
    }
    return [BFTask taskForCompletionOfAllTasks:tasks];
}

- (BFTask *)performAsyncDeactivation
{
    return [self.transientEnable writeByteAsync:0x0];
}

@end
