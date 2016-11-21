/**
 * MBLAccelerometerMMA8452Q.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 5/26/15.
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

#import "MBLAccelerometerMMA8452Q+Private.h"
#import "MBLAccelerometer+Private.h"
#import "mma8452q.h"
#import "MBLRegister+Private.h"
#import "MBLNumericFormatter.h"
#import "MBLAccelerometerDataReadyEvent.h"
#import "MBLAccelerometerFreeFallEvent.h"
#import "MBLAccelerometerOrientationEvent.h"
#import "MBLAccelerometerTapEvent.h"
#import "MBLAccelerometerShakeEvent.h"
#import "MBLAccelerometerData+Private.h"
#import "MBLAccelerometerAxisReadyEvent.h"
#import "MBLLogger.h"
#import "MBLAccelerometerMMA8452QRMSFormat.h"



@interface MBLAccelerometerMMA8452Q()
@property (nonatomic) MBLRegister *dataSettings;
@property (nonatomic) MBLEvent *freeFallEvent;
@property (nonatomic) MBLEvent *orientationEvent;
@property (nonatomic) MBLEvent *tapEvent;
@property (nonatomic) MBLEvent *shakeEvent;
@end

@implementation MBLAccelerometerMMA8452Q

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        self.fullScaleRange = MBLAccelerometerRange8G;
        self.activePowerScheme = MBLAccelerometerPowerSchemeNormal;
        self.tapDetectionAxis = MBLAccelerometerAxisX;
        self.tapType = MBLAccelerometerTapTypeSingle;
        self.shakeThreshold = 0.5;
        self.shakeWidth = 200.0;
        self.freeFallThreshold = 0.2;
        self.freeFallWidth = 100.0;
        
        MBLRegister *globalEnable = [[MBLRegister alloc] initWithModule:self registerId:0x1 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
        self.dataSettings = [[MBLRegister alloc] initWithModule:self registerId:0x3 format:[[MBLFormat alloc] initEncodedDataWithLength:4]];
        self.dataReadyEvent = [[MBLAccelerometerDataReadyEvent alloc] initWithAccelerometer:self];
        self.xAxisReadyEvent = [[MBLAccelerometerAxisReadyEvent alloc] initWithAccelerometer:self axis:MBLAccelerometerAxisX];
        self.yAxisReadyEvent = [[MBLAccelerometerAxisReadyEvent alloc] initWithAccelerometer:self axis:MBLAccelerometerAxisY];
        self.zAxisReadyEvent = [[MBLAccelerometerAxisReadyEvent alloc] initWithAccelerometer:self axis:MBLAccelerometerAxisZ];
        self.freeFallEvent = [[MBLAccelerometerFreeFallEvent alloc] initWithAccelerometer:self];
        self.orientationEvent = [[MBLAccelerometerOrientationEvent alloc] initWithAccelerometer:self];
        self.tapEvent = [[MBLAccelerometerTapEvent alloc] initWithAccelerometer:self];
        self.shakeEvent = [[MBLAccelerometerShakeEvent alloc] initWithAccelerometer:self];
        
        self.rmsDataReadyEvent = [self.dataReadyEvent rmsOfEventWithInputLength:2 inputCount:3 format:[[MBLAccelerometerMMA8452QRMSFormat alloc] initWithAccelerometer:self]];
        self.globalEnable = globalEnable;
    }
    return self;
}

- (BFTask *)performAsyncInitialization
{
    mma8452q_data_regs_t regs = { 0 };
    
    regs.xyz_data_cfg.fs = self.fullScaleRange;
    regs.xyz_data_cfg.hpf_out = self.highPassFilter;
    
    // TODO: setup the High-Pass Filter Cutoff Register
    //regs.hp_filter_cutoff.pulsehpfen
    //regs.hp_filter_cutoff.pulselpfen
    regs.hp_filter_cutoff.sel = self.highPassCutoffFreq;
    
    regs.ctrl_reg1.f_read = self.fastReadMode;
    regs.ctrl_reg1.lnoise = self.lowNoise;
    regs.ctrl_reg1.dr = self.scaleSampleFrequency;
    regs.ctrl_reg1.aslp_rate = self.sleepSampleFrequency;
    
    regs.ctrl_reg2.smods = self.sleepPowerScheme;
    regs.ctrl_reg2.slpe = self.autoSleep;
    regs.ctrl_reg2.mods = self.activePowerScheme;
    
    // TODO: setup the aslp_count, minimum time period of inactivity required before sleeping
    //regs.aslp_count.aslp_count
    return [self.dataSettings writeDataAsync:[NSData dataWithBytes:&regs length:sizeof(mma8452q_data_regs_t)]];
}

#pragma mark - Private helpers

double timeStepForPulseLimeLimit_LPF_EN_1[8][4] = {
    //Normal LPLN HighRes LP
    { 1.25, 1.25, 1.25, 1.25 }, // 800Hz
    { 2.50, 2.50, 2.50, 2.50 }, // 400Hz
    { 5.00, 5.00, 2.50, 5.00 }, // 200Hz
    { 10.0, 10.0, 2.50, 10.0 }, // 100Hz
    { 20.0, 20.0, 2.50, 20.0 }, // 50Hz
    { 20.0, 80.0, 2.50, 80.0 }, // 12.5Hz
    { 20.0, 80.0, 2.50, 160 },  // 6.25Hz
    { 20.0, 80.0, 2.50, 160 },  // 1.56Hz
};

double timeStepForPulseLimeLimit_LPF_EN_0[8][4] = {
    //Normal  LPLN  HighRes  LP
    { 0.625, 0.625, 0.625, 0.625 }, // 800Hz
    { 0.625, 0.625, 0.625, 1.250 }, // 400Hz
    { 1.250, 1.250, 0.625, 2.500 }, // 200Hz
    { 2.500, 2.500, 0.625, 5.000 }, // 100Hz
    { 5.000, 5.000, 0.625, 10.00 }, // 50Hz
    { 5.000, 20.00, 0.625, 40.00 }, // 12.5Hz
    { 5.000, 20.00, 0.625, 40.00 },  // 6.25Hz
    { 5.000, 20.00, 0.625, 40.00 },  // 1.56Hz
};

// Time Step for PULSE Latency is exactly double the tables above
// Time Step for PULSE Detection Window is exactly double the tables above
// Portrait/Landscape Debounce Counter is equal to timeStepForPulseLimeLimit_LPF_EN_1
// FreeFall/Motion Debounce Counter is equal to timeStepForPulseLimeLimit_LPF_EN_1
// Transient Debounce Counter is equal to timeStepForPulseLimeLimit_LPF_EN_1

- (uint8_t)scalePulseThreshold:(double)accelerationInGs
{
    if (accelerationInGs < 0.0) {
        MBLLog(MBLLogLevelWarning, @"[Accelerometer] no negative pulse thresholds");
        accelerationInGs = accelerationInGs * -1;
    }
    if (accelerationInGs > 8.0) {
        MBLLog(MBLLogLevelWarning, @"[Accelerometer] pulse threshold must be <= 8.0 G's");
        return 0xff;
    }
    // scale it to 0 - 127
    return (uint8_t)(accelerationInGs / 0.063);
}

- (uint8_t)scalePulseTimeLimit:(double)timeInMsec
{
    if (timeInMsec < 0.0) {
        MBLLog(MBLLogLevelWarning, @"[Accelerometer] no negative pulse time limit please");
        timeInMsec = 0.0;
    } else if (timeInMsec > timeStepForPulseLimeLimit_LPF_EN_0[self.scaleSampleFrequency][self.activePowerScheme] * 255.0) {
        MBLLog(MBLLogLevelWarning, @"[Accelerometer] pulse time limit requested is greater than max allowed");
        return 0xff;
    }
    // The ticks are scaled based on the current mode of the accelerometer
    return (uint8_t)(timeInMsec / timeStepForPulseLimeLimit_LPF_EN_0[self.scaleSampleFrequency][self.activePowerScheme]);
}

- (uint8_t)scalePulseLatency:(double)timeInMsec
{
    if (timeInMsec < 0.0) {
        MBLLog(MBLLogLevelWarning, @"[Accelerometer] no negative puse latency please");
        timeInMsec = 0.0;
    } else if (timeInMsec > timeStepForPulseLimeLimit_LPF_EN_0[self.scaleSampleFrequency][self.activePowerScheme] * 255.0) {
        MBLLog(MBLLogLevelWarning, @"[Accelerometer] pulse latency requested is greater than max allowed");
        return 0xff;
    }
    // The ticks are scaled based on the current mode of the accelerometer
    return (uint8_t)(timeInMsec / (timeStepForPulseLimeLimit_LPF_EN_0[self.scaleSampleFrequency][self.activePowerScheme] * 2));
}

- (uint8_t)scaleSecondPulseTimeWindow:(double)timeInMsec
{
    if (timeInMsec < 0.0) {
        MBLLog(MBLLogLevelWarning, @"[Accelerometer] no negative pulse time windows please");
        timeInMsec = 0.0;
    } else if (timeInMsec > timeStepForPulseLimeLimit_LPF_EN_0[self.scaleSampleFrequency][self.activePowerScheme] * 255.0) {
        MBLLog(MBLLogLevelWarning, @"[Accelerometer] pulse time windown requested is greater than max allowed");
        return 0xff;
    }
    // The ticks are scaled based on the current mode of the accelerometer
    return (uint8_t)(timeInMsec / (timeStepForPulseLimeLimit_LPF_EN_0[self.scaleSampleFrequency][self.activePowerScheme] * 2));
}

- (uint8_t)scalePortraitLandscapeDebounceCounter:(double)timeInMsec
{
    if (timeInMsec < 0.0) {
        MBLLog(MBLLogLevelWarning, @"[Accelerometer] cannot have negative debounce counter value");
        timeInMsec = 0.0;
    } else if (timeInMsec > timeStepForPulseLimeLimit_LPF_EN_0[self.scaleSampleFrequency][self.activePowerScheme] * 255.0) {
        MBLLog(MBLLogLevelWarning, @"[Accelerometer] debounce counter value requested is greater than max allowed");
        return 0xff;
    }
    // The ticks are scaled based on the current mode of the accelerometer
    return (uint8_t)(timeInMsec / timeStepForPulseLimeLimit_LPF_EN_1[self.scaleSampleFrequency][self.activePowerScheme]);
}

- (uint8_t)scaleFreeFallMotionDebounceCounter:(double)timeInMsec
{
    return [self scalePortraitLandscapeDebounceCounter:timeInMsec];
}

- (uint8_t)scaleTransientDebounceCounter:(double)timeInMsec
{
    return [self scalePortraitLandscapeDebounceCounter:timeInMsec];
}

- (uint8_t)scaleSampleFrequency
{
    if (self.sampleFrequency > 400) {
        return 0;
    } else if (self.sampleFrequency > 200) {
        return 1;
    } else if (self.sampleFrequency > 100) {
        return 2;
    } else if (self.sampleFrequency > 50) {
        return 3;
    } else if (self.sampleFrequency > 12.5) {
        return 4;
    } else if (self.sampleFrequency > 6.25) {
        return 5;
    } else if (self.sampleFrequency > 1.56) {
        return 6;
    } else {
        return 7;
    }
}

@end
