/**
 * MBLAccelerometerBMI160StepEvent.m
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

#import "MBLAccelerometerBMI160StepEvent.h"
#import "MBLAccelerometerBMI160+Private.h"
#import "MBLNumericFormatter.h"

@interface MBLAccelerometerBMI160StepEvent ()
@property (nonatomic) MBLRegister *stepCounterInterruptEn;
@property (nonatomic) MBLRegister *stepCounterConfig;
@end

@implementation MBLAccelerometerBMI160StepEvent

- (instancetype)initWithAccelerometer:(MBLAccelerometerBMI160 *)accelerometer
{
    self = [super initWithModule:accelerometer registerId:0x19 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
    if (self) {
        self.stepCounterInterruptEn = [[MBLRegister alloc] initWithModule:accelerometer registerId:0x17 format:[[MBLFormat alloc] initEncodedDataWithLength:1]];
        self.stepCounterConfig = [[MBLRegister alloc] initWithModule:accelerometer registerId:0x18 format:[[MBLFormat alloc] initEncodedDataWithLength:2]];
    }
    return self;
}

- (BFTask *)performAsyncActivation
{
    NSMutableArray *tasks = [NSMutableArray array];
    bmi160_reg_step_conf_t regs = { 0 };
    
    // No real descriptions given, just the defaut values for "Normal Mode"
    regs.step_conf_0.alpha = 0;
    regs.step_conf_0.min_threshold = 2;
    regs.step_conf_0.steptime_min = 5;
    regs.step_conf_1.min_step_buf = 3;
    regs.step_conf_1.step_cnt_en = 1;
    
    [tasks addObject:[self.stepCounterConfig writeDataAsync:[NSData dataWithBytes:&regs length:sizeof(bmi160_reg_step_conf_t)]]];
    
    // Write the enable bit for tap detection interrupts
    uint8_t data[] = { (1 << 0) , 0 };
    int dataSize = sizeof(data) / sizeof(data[0]);
    [tasks addObject:[self.stepCounterInterruptEn writeDataAsync:[NSData dataWithBytes:&data length:dataSize]]];
    
    return [BFTask taskForCompletionOfAllTasks:tasks];
}

- (BFTask *)performAsyncDeactivation
{
    // Write the disable bit for tap detection interrupts
    uint8_t data[] = { 0, (1 << 0) };
    int dataSize = sizeof(data) / sizeof(data[0]);
    return [self.stepCounterInterruptEn writeDataAsync:[NSData dataWithBytes:&data length:dataSize]];
}

@end
