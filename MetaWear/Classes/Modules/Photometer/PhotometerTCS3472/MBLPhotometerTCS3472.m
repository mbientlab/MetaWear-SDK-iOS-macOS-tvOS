/**
 * MBLPhotometerTCS3472.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 2/17/16.
 * Copyright 2016 MbientLab Inc. All rights reserved.
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

#import "MBLPhotometerTCS3472.h"
#import "MBLPhotometer+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLRegister+Private.h"
#import "MBLData+Private.h"
#import "MBLPhotometerTCS3472Format.h"
#import "MBLConstants+Private.h"

typedef struct __attribute__((packed)) {
    uint8_t     atime;
} tcs3472_reg_atime_t;

typedef struct __attribute__((packed)) {
    uint8_t     again:2;
    uint8_t     :6;
} tcs3472_reg_control_t;

typedef struct __attribute__((packed)) {
    tcs3472_reg_atime_t     atime;
    tcs3472_reg_control_t   control;
    uint8_t                 led_enable;
} mw_rgbcolor_mode_t;

@interface MBLPhotometerTCS3472()
@property (nonatomic) MBLRegister *mode;
@end

@implementation MBLPhotometerTCS3472

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        self.color = [[MBLData alloc] initWithModule:self registerId:0x1 format:[[MBLPhotometerTCS3472Format alloc] init] identifier:@"color"];
        self.redColor = [[MBLData alloc] initWithModule:self registerId:0x1 format:[[MBLPhotometerTCS3472Format alloc] initWithOffset:2] identifier:@"color[1]"];
        self.greenColor = [[MBLData alloc] initWithModule:self registerId:0x1 format:[[MBLPhotometerTCS3472Format alloc] initWithOffset:4] identifier:@"color[2]"];
        self.blueColor = [[MBLData alloc] initWithModule:self registerId:0x1 format:[[MBLPhotometerTCS3472Format alloc] initWithOffset:6] identifier:@"color[3]"];
        self.clearColor = [[MBLData alloc] initWithModule:self registerId:0x1 format:[[MBLPhotometerTCS3472Format alloc] initWithOffset:0] identifier:@"color[0]"];
        
        self.mode = [[MBLRegister alloc] initWithModule:self registerId:0x2 format:[[MBLFormat alloc] initEncodedDataWithLength:3]];
        
        self.gain = MBLPhotometerTCS3472Gain1X;
        self.integrationTime = 50.0;
        self.ledFlash = NO;
    }
    return self;
}

- (void)setIntegrationTime:(double)integrationTime
{
    _integrationTime = [MBLConstants clampDouble:integrationTime low:2.4 high:614.4];
}

- (BFTask *)performAsyncInitialization
{
    mw_rgbcolor_mode_t regs = { 0 };
    
    regs.atime.atime = 256 - round(self.integrationTime / 2.4);
    regs.control.again = self.gain;
    regs.led_enable = self.ledFlash ? 1 : 0;

    return [self.mode writeDataAsync:[NSData dataWithBytes:&regs length:sizeof(mw_rgbcolor_mode_t)]];
}

@end
