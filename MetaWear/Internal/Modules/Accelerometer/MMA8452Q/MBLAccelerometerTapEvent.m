/**
 * MBLAccelerometerTapEvent.m
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

#import "MBLAccelerometerTapEvent.h"
#import "MBLAccelerometerMMA8452Q+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLNumericFormatter.h"
#import "mma8452q.h"

@interface MBLAccelerometerTapEvent ()
@property (nonatomic) MBLRegister *pulseEnable;
@property (nonatomic) MBLRegister *pulseSettings;
@end

@implementation MBLAccelerometerTapEvent

- (instancetype)initWithAccelerometer:(MBLAccelerometerMMA8452Q *)accelerometer
{
    self = [super initWithModule:accelerometer registerId:0xD format:[[MBLFormat alloc] initEncodedDataWithLength:1] identifier:@"mma8452q-tap"];
    if (self) {
        self.pulseEnable = [[MBLRegister alloc] initWithModule:accelerometer registerId:0x0B format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
        self.pulseSettings = [[MBLRegister alloc] initWithModule:accelerometer registerId:0x0C format:[[MBLFormat alloc] initEncodedDataWithLength:8]];
    }
    return self;
}

- (BFTask *)performAsyncActivation
{
    NSMutableArray *tasks = [NSMutableArray array];
    BOOL strobeGlobalEnable = self.module.activateCount;
    MBLAccelerometerMMA8452Q *accelerometer = (MBLAccelerometerMMA8452Q *)self.module;
    mma8452q_pulse_regs_t regs = { 0 };
    // Latch enabled
    regs.pulse_cfg.ele = YES;
    if (accelerometer.tapDetectionAxis & MBLAccelerometerAxisX) {
        if (accelerometer.tapType == MBLAccelerometerTapTypeSingle ||
            accelerometer.tapType == MBLAccelerometerTapTypeBoth) {
            regs.pulse_cfg.xspefe = YES;
        }
        if (accelerometer.tapType == MBLAccelerometerTapTypeDouble ||
            accelerometer.tapType == MBLAccelerometerTapTypeBoth) {
            regs.pulse_cfg.xdpefe = YES;
        }
    }
    if (accelerometer.tapDetectionAxis & MBLAccelerometerAxisY) {
        if (accelerometer.tapType == MBLAccelerometerTapTypeSingle ||
            accelerometer.tapType == MBLAccelerometerTapTypeBoth) {
            regs.pulse_cfg.yspefe = YES;
        }
        if (accelerometer.tapType == MBLAccelerometerTapTypeDouble ||
            accelerometer.tapType == MBLAccelerometerTapTypeBoth) {
            regs.pulse_cfg.ydpefe = YES;
        }
    }
    if (accelerometer.tapDetectionAxis & MBLAccelerometerAxisZ) {
        if (accelerometer.tapType == MBLAccelerometerTapTypeSingle ||
            accelerometer.tapType == MBLAccelerometerTapTypeBoth) {
            regs.pulse_cfg.zspefe = YES;
        }
        if (accelerometer.tapType == MBLAccelerometerTapTypeDouble ||
            accelerometer.tapType == MBLAccelerometerTapTypeBoth) {
            regs.pulse_cfg.zdpefe = YES;
        }
    }
    
    // pulse_thsx.ths defines the X-axis threshold which is used by the system to
    // start the pulse detection procedure.
    regs.pulse_thsx.ths = [accelerometer scalePulseThreshold:3.5];
    // pulse_thst.ths defines the Y-axis threshold which is used by the system to
    // start the pulse detection procedure.
    regs.pulse_thsy.ths = [accelerometer scalePulseThreshold:3.5];
    // pulse_thst.ths defines the Z-axis threshold which is used by the system to
    // start the pulse detection procedure.
    regs.pulse_thyz.ths = [accelerometer scalePulseThreshold:4.0];
    
    // tmlt defines the maximum time interval that can elapse between the start
    // of the acceleration on the selected axis exceeding the specified threshold
    // and the end when the acceleration on the selected axis must go below the
    // specified threshold to be considered a valid pulse.
    regs.pulse_tmlt.tmlt = [accelerometer scalePulseTimeLimit:30.0];
    // ltcy defines the time interval that starts after the first pulse detection.
    // During this time interval, all pulses are ignored.
    regs.pulse_ltcy.ltcy = [accelerometer scalePulseLatency:80.0];
    // define the maximum interval of time that can elapse after the end of the
    // latency interval in which the start of the second pulse event must be
    // detected provided the device has been configured for double pulse detection
    regs.pulse_wind.wind = [accelerometer scaleSecondPulseTimeWindow:300.0];
    
    if (strobeGlobalEnable) {
        [tasks addObject:[accelerometer.globalEnable writeByteAsync:0x0]];
    }
    [tasks addObject:[self.pulseSettings writeDataAsync:[NSData dataWithBytes:&regs length:sizeof(mma8452q_pulse_regs_t)]]];
    [tasks addObject:[self.pulseEnable writeByteAsync:0x1]];
    if (strobeGlobalEnable) {
        [tasks addObject:[accelerometer.globalEnable writeByteAsync:0x1]];
    }
    return [BFTask taskForCompletionOfAllTasks:tasks];
}

- (BFTask *)performAsyncDeactivation
{
    return [self.pulseEnable writeByteAsync:0x0];
}

@end
