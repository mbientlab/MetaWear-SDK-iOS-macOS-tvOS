/**
 * MBLAccelerometerBMI160MotionEvent.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 7/20/15.
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

#import "MBLAccelerometerBMI160MotionEvent+Private.h"
#import "MBLEvent+Private.h"
#import "MBLAccelerometerBMI160+Private.h"
#import "MBLFormat.h"
#import "MBLMetaWear+Private.h"
#import "MBLConstants+Private.h"

@interface MBLAccelerometerBMI160MotionEvent ()
@property (nonatomic) MBLRegister *motionInterruptEn;
@property (nonatomic) MBLRegister *motionConfig;
@end

@implementation MBLAccelerometerBMI160MotionEvent

- (instancetype)initWithAccelerometer:(MBLAccelerometerBMI160 *)accelerometer
{
    self = [super initWithModule:accelerometer registerId:0x0B format:[[MBLFormat alloc] initEncodedDataWithLength:1]];
    if (self) {
        // Default Settings
        self.slowNoMotionEnabled = NO;
        self.useSlowMotion = NO;
        self.slowNoMotionDuration = 0.0;
        self.slowNoMotionThreshold = 0.2;
        
        self.significantAnyMotionEnabled = NO;
        self.useSignificantMotion = NO;
        self.anyMotionDuration = 0;
        self.anyMotionThreshold = 0.2;
        self.significantMotionSkipTime = 3.0;
        self.significantMotionProofTime = 0.5;        
        
        // Registers
        self.motionInterruptEn = [[MBLRegister alloc] initWithModule:accelerometer registerId:0x09 format:[[MBLFormat alloc] initEncodedDataWithLength:1]];
        self.motionConfig = [[MBLRegister alloc] initWithModule:accelerometer registerId:0x0A format:[[MBLFormat alloc] initEncodedDataWithLength:4]];
    }
    return self;
}

- (BFTask *)performAsyncActivation
{
    NSMutableArray *tasks = [NSMutableArray array];
    MBLAccelerometerBMI160 *accelerometer = (MBLAccelerometerBMI160 *)self.module;
    bmi160_reg_int_motion_t regs = { 0 };
    
    const double msPerSample = 1000.0 / accelerometer.sampleFrequency;
    
    // slope interrupt trigger if int_anym_dur + 1 consecutive slope data points are above
    // the slope interrupt threshold (int_anymo_th) (Clamp to 3 only 2-bit field)
    int int_anym_dur = round(self.anyMotionDuration / msPerSample) - 1;
    regs.int_motion_0.int_anym_dur = [MBLConstants clampInt:int_anym_dur low:0 high:0x3];

    int int_slo_nomo_dur = 0;
    if (self.useSlowMotion) {
        // if slow-motion (int_no_mot_sel = 0) then int_slo_nomo_dur + 1 consecutive slope data
        // points must be above the slow/no-motion threshold (int_slo_no_mot_th) for the
        // slow-/no-motion interrupt to trigger.
        int_slo_nomo_dur = round((msPerSample / self.slowNoMotionDuration)) - 1;
        int_slo_nomo_dur = [MBLConstants clampInt:int_slo_nomo_dur low:0 high:0x3];
    } else {
        // If no-motion (int_no_mot_sel = 1) then int_slo_nomo_dur defines time for which no slope
        // data point must exceed the slow/no-motion threshold (int_slow_no_mot_th) for slow/no-motion
        // interrupt to trigger:
        // switch (int_slo_no_mot_dur<5:4>)
        //   case 0:
        //     return (int_slo_no_mot_dur<3:0> + 1) * 1.28s
        //   case 1:
        //     return (int_slo_no_mot_dur<3:0> + 5) * 5.12s
        //   case 2:
        //     return (int_slo_no_mot_dur<4:0> + 11) * 10.24s
        double slo_nomo_second = self.slowNoMotionDuration / 1000.0;
        if (slo_nomo_second > 102.4 ) {
            int_slo_nomo_dur = (round(slo_nomo_second / 10.24) - 11);
            int_slo_nomo_dur = [MBLConstants clampInt:int_slo_nomo_dur low:0 high:0x1F];
            int_slo_nomo_dur |= 0x20;
        } else if (slo_nomo_second > 20.48) {
            int_slo_nomo_dur = (round(slo_nomo_second / 5.12) - 5);
            int_slo_nomo_dur = [MBLConstants clampInt:int_slo_nomo_dur low:0 high:0xF];
            int_slo_nomo_dur |= 0x10;
        } else {
            int_slo_nomo_dur = (round(slo_nomo_second / 1.28) - 1);
            int_slo_nomo_dur = [MBLConstants clampInt:int_slo_nomo_dur low:0 high:0xF];
            int_slo_nomo_dur |= 0x00;
        }
    }
    regs.int_motion_0.int_slo_nomo_dur = int_slo_nomo_dur;
    
    // Threshold of the any-motion interrupt (int_anymo_th * 1.955 * maxG)
    // switch (fullScaleRange):
    //   case 2g:
    //     return int_anymo_th * 3.91 mg
    //   case 4g:
    //     return int_anymo_th * 7.81 mg
    //   case 8g:
    //     return int_anymo_th * 15.63 mg
    //   case 16g:
    //     return int_anymo_th * 31.25 mg
    // if int_anymo_th == 0, then value is half the scale factor
    double scale;
    switch (accelerometer.fullScaleRange) {
        case MBLAccelerometerBoschRange2G:
            scale = 3.91;
            break;
        case MBLAccelerometerBoschRange4G:
            scale = 7.81;
            break;
        case MBLAccelerometerBoschRange8G:
            scale = 15.63;
            break;
        case MBLAccelerometerBoschRange16G:
            scale = 31.25;
            break;
    }
    regs.int_motion_1.int_anymo_th = round((self.anyMotionThreshold * 1000.0) / scale);
    
    
    // Threshold for slow/no-motion interrupt, functions same as int_anymo_th
    regs.int_motion_2.int_slo_nomo_th = round((self.slowNoMotionThreshold * 1000.0) / scale);
    
    // Proof time of the signification motion interrupt: 0=0.25s, 1=0.5s, 2=1s, 3=2s
    int int_sig_mot_proof = 0;
    if (self.significantMotionProofTime > 1.0) {
        int_sig_mot_proof = 3;
    } else if (self.significantMotionProofTime > 0.5) {
        int_sig_mot_proof = 2;
    } else if (self.significantMotionProofTime > 0.25) {
        int_sig_mot_proof = 1;
    }
    regs.int_motion_3.int_sig_mot_proof = int_sig_mot_proof;
    
    // '1' ('0') Selects the signification (anymotion) interrupt function
    regs.int_motion_3.int_sig_mot_sel = self.useSignificantMotion ? 1 : 0;
    
    // Skip time of the signification motion interrupt: 0=1.5s, 1=3s, 2=6s, 3=12s
    int int_sig_mot_skip = 0;
    if (self.significantMotionSkipTime > 6.0) {
        int_sig_mot_skip = 3;
    } else if (self.significantMotionProofTime > 3.0) {
        int_sig_mot_skip = 2;
    } else if (self.significantMotionProofTime > 1.5) {
        int_sig_mot_skip = 1;
    }
    regs.int_motion_3.int_sig_mot_skip = int_sig_mot_skip;
    
    // '1' ('0') Selects no-motion (slow-motion) interrupt function
    regs.int_motion_3.int_slo_nomo_sel = self.useSlowMotion ? 0 : 1;
    
    [tasks addObject:[self.motionConfig writeDataAsync:[NSData dataWithBytes:&regs length:sizeof(bmi160_reg_int_motion_t)]]];
    
    // Write the enable bits for motion interrupts
    uint8_t enableBitmask = 0;
    if (self.significantAnyMotionEnabled) {
        enableBitmask |= (0x7 << 0);
    }
    if (self.slowNoMotionEnabled) {
        enableBitmask |= (0x7 << 3);
    }
    uint8_t data[] = { enableBitmask, 0 };
    int dataSize = sizeof(data) / sizeof(data[0]);
    [tasks addObject:[self.motionInterruptEn writeDataAsync:[NSData dataWithBytes:&data length:dataSize]]];
    
    return [BFTask taskForCompletionOfAllTasks:tasks];
}

- (BFTask *)performAsyncDeactivation
{
    // Write the disable bits for motion interrupts
    uint8_t data[] = { 0, 0x3F };
    int dataSize = sizeof(data) / sizeof(data[0]);
    return [self.motionInterruptEn writeDataAsync:[NSData dataWithBytes:&data length:dataSize]];
}

@end
