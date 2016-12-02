/**
 * MBLAccelerometerBoschFlatEvent.m
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

#import "MBLAccelerometerBoschFlatEvent+Private.h"
#import "MBLEvent+Private.h"
#import "MBLAccelerometerBosch+Private.h"
#import "MBLAccelerometerBoschFlatFormat.h"

@interface MBLAccelerometerBoschFlatEvent ()
@property (nonatomic) MBLRegister *flatInterruptEn;
@property (nonatomic) MBLRegister *flatConfig;
@end

@implementation MBLAccelerometerBoschFlatEvent

- (instancetype)initWithAccelerometer:(MBLAccelerometerBosch *)accelerometer
{
    self = [super initWithModule:accelerometer registerId:0x14 format:[[MBLAccelerometerBoschFlatFormat alloc] init]];
    if (self) {
        self.flatInterruptEn = [[MBLRegister alloc] initWithModule:accelerometer registerId:0x12 format:[[MBLFormat alloc] initEncodedDataWithLength:1]];
        self.flatConfig = [[MBLRegister alloc] initWithModule:accelerometer registerId:0x13 format:[[MBLFormat alloc] initEncodedDataWithLength:2]];
        
        self.flatThreshold = 6.0;
        self.flatDelay = MBLAccelerometerBoschFlatTime640ms;
    }
    return self;
}

- (BFTask *)performAsyncActivation
{
    NSMutableArray *tasks = [NSMutableArray array];
    bmi160_reg_int_flat_t regs = { 0 };
    
    // defines threshold for detection of flat position in range from 0 to 44.8
    // Since there are 6 bits to this field, each LSB is 44.8 / 63 = 0.71111111
    regs.int_flat_0.int_flat_theta = round(self.flatThreshold / 0.71111111);
    // defines flat interrupt hystersis, no units given..thanks bosch
    regs.int_flat_1.int_flat_hy = 1;
    // delay time for which the flat value must remain stable for flat
    //. interrupt to be generated: 0 -> 0ms, 1 -> 640 ms, 2-> 1280 ms, 3 -> 2560 ms
    regs.int_flat_1.int_flag_hold = self.flatDelay;

    [tasks addObject:[self.flatConfig writeDataAsync:[NSData dataWithBytes:&regs length:sizeof(bmi160_reg_int_flat_t)]]];

    // Write the enable bit for tap detection interrupts
    uint8_t data[] = { (1 << 0) , 0 };
    int dataSize = sizeof(data) / sizeof(data[0]);
    [tasks addObject:[self.flatInterruptEn writeDataAsync:[NSData dataWithBytes:&data length:dataSize]]];
    
    return [BFTask taskForCompletionOfAllTasks:tasks];
}

- (BFTask *)performAsyncDeactivation
{
    // Write the disable bit for tap detection interrupts
    uint8_t data[] = { 0, (1 << 0) };
    int dataSize = sizeof(data) / sizeof(data[0]);
    return [self.flatInterruptEn writeDataAsync:[NSData dataWithBytes:&data length:dataSize]];
}

@end
