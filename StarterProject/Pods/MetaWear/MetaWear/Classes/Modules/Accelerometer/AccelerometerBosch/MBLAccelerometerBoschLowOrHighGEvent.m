/**
 * MBLAccelerometerBoschLowOrHighGEvent.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 11/4/15.
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

#import "MBLAccelerometerBoschLowOrHighGEvent+Private.h"
#import "MBLEvent+Private.h"
#import "MBLAccelerometerBosch+Private.h"
#import "MBLFormat.h"
#import "bmi160.h"

@interface MBLAccelerometerBoschLowOrHighGEvent ()
@property (nonatomic) MBLRegister *lowGHighGInterruptEn;
@property (nonatomic) MBLRegister *lowGHighGConfig;

@property (nonatomic) double lowOrHighGDurationMultiplier;
@end

@implementation MBLAccelerometerBoschLowOrHighGEvent

- (instancetype)initWithAccelerometer:(MBLAccelerometerBosch *)accelerometer
{
    self = [super initWithModule:accelerometer registerId:0x8 format:[[MBLFormat alloc] initEncodedDataWithLength:1]];
    if (self) {
        // Default settings
        self.lowGDuration = 100.0;
        self.lowGHysteresis = 0.125;
        self.lowGThreshold = 0.2;
        self.lowGMode = NO;
        
        self.highGDuration = 30.0;
        self.highGHysteresis = 0.125;
        self.highGThreshold = 2.0;
        
        // Registers
        self.lowGHighGInterruptEn = [[MBLRegister alloc] initWithModule:accelerometer registerId:0x6 format:[[MBLFormat alloc] initEncodedDataWithLength:1]];
        self.lowGHighGConfig = [[MBLRegister alloc] initWithModule:accelerometer registerId:0x7 format:[[MBLFormat alloc] initEncodedDataWithLength:5]];
    }
    return self;
}

- (BFTask *)performAsyncActivation
{
    NSMutableArray *tasks = [NSMutableArray array];
    MBLAccelerometerBosch *accelerometer = (MBLAccelerometerBosch *)self.module;
    bmi160_reg_int_lowhigh_t regs = { 0 };
    
    // delay in ms = (int_low_dur + 1) * 2.5
    regs.int_lowhigh_0.int_low_dur = MAX((self.lowGDuration / self.lowOrHighGDurationMultiplier) - 1, 0);
    
    // threshold in g = int_low_th * 0.00781
    regs.int_lowhigh_1.int_low_th = self.lowGThreshold / 0.00781;
    
    // int_high_hy * 125mg (2g-range), int_high_hy * 250mg (4g-range), int_high_hy * 500mg (8g-range), int_high_hy * 1000mg (16g-range)
    // if th = 0, then value is 1/2 the constant
    double scale;
    switch (accelerometer.fullScaleRange) {
        case MBLAccelerometerBoschRange2G:
            scale = 0.125;
            break;
        case MBLAccelerometerBoschRange4G:
            scale = 0.250;
            break;
        case MBLAccelerometerBoschRange8G:
            scale = 0.500;
            break;
        case MBLAccelerometerBoschRange16G:
            scale = 1.000;
            break;
    }
    regs.int_lowhigh_2.int_high_hy = self.highGHysteresis / scale;
    
    // Set low-g mode
    regs.int_lowhigh_2.int_low_mode = self.lowGMode;
    
    // hystersis in g = int_low_hy * 0.125
    regs.int_lowhigh_2.int_low_hy = self.lowGHysteresis / 0.125;
    
    // delay in ms = (int_high_dur + 1) * 2.5
    regs.int_lowhigh_3.int_high_dur = MAX((self.highGDuration / self.lowOrHighGDurationMultiplier) - 1, 0);
    
    // int_high_th * 7.81mg (2g-range), int_high_th * 15.63mg (4g-range), int_high_th * 31.25mg (8g-range), int_high_th * 62.5mg (16g-range)
    // if th = 0, then value is 1/2 the constant
    switch (accelerometer.fullScaleRange) {
        case MBLAccelerometerBoschRange2G:
            scale = 0.00781;
            break;
        case MBLAccelerometerBoschRange4G:
            scale = 0.01563;
            break;
        case MBLAccelerometerBoschRange8G:
            scale = 0.03125;
            break;
        case MBLAccelerometerBoschRange16G:
            scale = 0.0625;
            break;
    }
    regs.int_lowhigh_4.int_high_th = self.highGThreshold / scale;
    
    [tasks addObject:[self.lowGHighGConfig writeDataAsync:[NSData dataWithBytes:&regs length:sizeof(bmi160_reg_int_lowhigh_t)]]];
    
    // Write the enable bits
    uint8_t enableMask = 0;
    if (self.highGEnabledAxis & MBLAccelerometerAxisX) {
        enableMask |= (1 << 0);
    }
    if (self.highGEnabledAxis & MBLAccelerometerAxisY) {
        enableMask |= (1 << 1);
    }
    if (self.highGEnabledAxis & MBLAccelerometerAxisZ) {
        enableMask |= (1 << 2);
    }
    if (self.lowGEnabled) {
        enableMask |= (1 << 3);
    }
    uint8_t data[] = { enableMask, 0 };
    int dataSize = sizeof(data) / sizeof(data[0]);
    [tasks addObject:[self.lowGHighGInterruptEn writeDataAsync:[NSData dataWithBytes:&data length:dataSize]]];
    
    return [BFTask taskForCompletionOfAllTasks:tasks];
}

- (BFTask *)performAsyncDeactivation
{
    // Write the disable bit for everything
    uint8_t data[] = { 0, 0xF };
    int dataSize = sizeof(data) / sizeof(data[0]);
    return [self.lowGHighGConfig writeDataAsync:[NSData dataWithBytes:&data length:dataSize]];
}

@end

