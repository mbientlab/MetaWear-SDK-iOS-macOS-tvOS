/**
 * MBLAccelerometerBoschOrientationEvent.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 6/12/15.
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

#import "MBLAccelerometerBoschOrientationEvent.h"
#import "MBLAccelerometerBoschOrientationFormat.h"
#import "MBLAccelerometerBosch+Private.h"

@interface MBLAccelerometerBoschOrientationEvent ()
@property (nonatomic) MBLRegister *orientInterruptEn;
@property (nonatomic) MBLRegister *orientConfig;
@end

@implementation MBLAccelerometerBoschOrientationEvent

- (instancetype)initWithAccelerometer:(MBLAccelerometerBosch *)accelerometer
{
    self = [super initWithModule:accelerometer registerId:0x11 format:[[MBLAccelerometerBoschOrientationFormat alloc] init]];
    if (self) {
        self.orientInterruptEn = [[MBLRegister alloc] initWithModule:accelerometer registerId:0x0F format:[[MBLFormat alloc] initEncodedDataWithLength:1]];
        self.orientConfig = [[MBLRegister alloc] initWithModule:accelerometer registerId:0x10 format:[[MBLFormat alloc] initEncodedDataWithLength:2]];
    }
    return self;
}

- (BFTask *)performAsyncActivation
{
    /*
    TODO: The defaults seem fine, maybe want to explore these in the future
    bmi160_reg_int_orient_t regs = { 0 };
    regs.int_orient_0.int_orient_blocking;
    regs.int_orient_0.int_orient_hy;
    regs.int_orient_0.int_orient_mode;
    
    regs.int_orient_1.int_orient_axes_ex;
    regs.int_orient_1.int_orient_theta;
    regs.int_orient_1.int_orient_ud_en;
    
    [self.orientConfig writeDataAsync:[NSData dataWithBytes:&regs length:sizeof(bmi160_reg_int_orient_t)]];
    */
    // Write the enable bit for orientation interrupts
    uint8_t data[] = { (1 << 0), 0 };
    int dataSize = sizeof(data) / sizeof(data[0]);
    return [self.orientInterruptEn writeDataAsync:[NSData dataWithBytes:&data length:dataSize]];
}

- (BFTask *)performAsyncDeactivation
{
    // Write the disable bit for orientation interrupts
    uint8_t data[] = { 0, (1 << 0) };
    int dataSize = sizeof(data) / sizeof(data[0]);
    return [self.orientInterruptEn writeDataAsync:[NSData dataWithBytes:&data length:dataSize]];
}

@end
