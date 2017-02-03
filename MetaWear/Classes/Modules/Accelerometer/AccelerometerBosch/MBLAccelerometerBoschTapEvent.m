/**
 * MBLAccelerometerBoschTapEvent.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 6/13/15.
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

#import "MBLAccelerometerBoschTapEvent+Private.h"
#import "MBLAccelerometerBosch+Private.h"
#import "MBLEvent+Private.h"
#import "MBLFormat.h"

@interface MBLAccelerometerBoschTapEvent ()
@property (nonatomic) MBLRegister *tapInterruptEn;
@property (nonatomic) MBLRegister *tapConfig;
@end

@implementation MBLAccelerometerBoschTapEvent

- (instancetype)initWithAccelerometer:(MBLAccelerometerBosch *)accelerometer
{
    self = [super initWithModule:accelerometer registerId:0xE format:[[MBLFormat alloc] initEncodedDataWithLength:1]];
    if (self) {
        self.tapInterruptEn = [[MBLRegister alloc] initWithModule:accelerometer registerId:0x0C format:[[MBLFormat alloc] initEncodedDataWithLength:1]];
        self.tapConfig = [[MBLRegister alloc] initWithModule:accelerometer registerId:0x0D format:[[MBLFormat alloc] initEncodedDataWithLength:2]];
        
        self.type = MBLAccelerometerTapTypeSingle;
        self.threshold = 2.0;
        self.duration = MBLAccelerometerBoschTapDuration250ms;
        self.quiet = MBLAccelerometerBoschTapQuiet30ms;
        self.shock = MBLAccelerometerBoschTapShock50ms;
    }
    return self;
}

- (BFTask *)performAsyncActivation
{
    NSMutableArray *tasks = [NSMutableArray array];
    MBLAccelerometerBosch *accelerometer = (MBLAccelerometerBosch *)self.module;
    bmi160_reg_int_tap_t regs = { 0 };
    
    // 0 -> 50 ms, 1 -> 100 ms, 2 -> 150 ms, 3 -> 200 ms, 4 -> 250 ms, 5 -> 375 ms, 6 -> 500 ms, 7 -> 700 ms
    regs.int_tap_0.int_tap_dur = self.duration;
    // selects a tap quiet duration of 0 -> 30 ms, 1 -> 20 ms
    regs.int_tap_0.int_tap_quiet = self.quiet;
    // selects a tap shock duration of 0 -> 50 ms, 1 -> 75 ms
    regs.int_tap_0.int_tap_shock = self.shock;
    
    // th * 62.5mg (2g-range), th * 125mg (4g-range), th * 250mg (8g-range), th * 500mg (16g-range)
    // if th = 0, then value is 1/2 the constant
    double scale;
    switch (accelerometer.fullScaleRange) {
        case MBLAccelerometerBoschRange2G:
            scale = 62.5;
            break;
        case MBLAccelerometerBoschRange4G:
            scale = 125;
            break;
        case MBLAccelerometerBoschRange8G:
            scale = 250;
            break;
        case MBLAccelerometerBoschRange16G:
            scale = 500;
            break;
    }
    regs.int_tap_1.int_tap_th = round((self.threshold * 1000.0) / scale);
    [tasks addObject:[self.tapConfig writeDataAsync:[NSData dataWithBytes:&regs length:sizeof(bmi160_reg_int_tap_t)]]];

    uint8_t enableMask;
    switch (self.type) {
        case MBLAccelerometerTapTypeSingle:
            enableMask = (1 << 1);
            break;
        case MBLAccelerometerTapTypeDouble:
            enableMask = (1 << 0);
            break;
        case MBLAccelerometerTapTypeBoth:
            enableMask = (1 << 1) | (1 << 0);
            break;
    }
    
    // Write the enable bit for tap detection interrupts
    uint8_t data[] = { enableMask , 0 };
    int dataSize = sizeof(data) / sizeof(data[0]);
    [tasks addObject:[self.tapInterruptEn writeDataAsync:[NSData dataWithBytes:&data length:dataSize]]];
    
    return [BFTask taskForCompletionOfAllTasks:tasks];
}

- (BFTask *)performAsyncDeactivation
{
    // Write the disable bit for tap detection interrupts
    uint8_t data[] = { 0, (1 << 0) | (1 << 1) };
    int dataSize = sizeof(data) / sizeof(data[0]);
    return [self.tapInterruptEn writeDataAsync:[NSData dataWithBytes:&data length:dataSize]];
}

@end
