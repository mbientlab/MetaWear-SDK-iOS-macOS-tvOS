/**
 * MBLMagnetometerBMM150PeriodicMagneticFieldEvent.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 1/6/16.
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

#import "MBLMagnetometerBMM150PeriodicMagneticFieldEvent.h"
#import "MBLMagnetometer.h"
#import "MBLMagnetometerBMM150Format.h"

@interface MBLMagnetometerBMM150PeriodicMagneticFieldEvent ()
@property (nonatomic) MBLRegister *dataEnable;
@end

@implementation MBLMagnetometerBMM150PeriodicMagneticFieldEvent

- (instancetype)initWithMagnetometer:(MBLMagnetometer *)magnetometer
{
    self = [super initWithModule:magnetometer registerId:0x05 format:[[MBLMagnetometerBMM150Format alloc] initWithPacked:NO]];
    if (self) {
        self.dataEnable = [[MBLRegister alloc] initWithModule:magnetometer registerId:0x02 format:[[MBLFormat alloc] initEncodedDataWithLength:2]];
    }
    return self;
}

- (BFTask *)performAsyncActivation
{
    // Write the enable bit for mag data ready interrupts
    uint8_t data[] = { (1 << 0) , 0 };
    int dataSize = sizeof(data) / sizeof(data[0]);
    return [self.dataEnable writeDataAsync:[NSData dataWithBytes:&data length:dataSize]];
}


- (BFTask *)performAsyncDeactivation
{
    // Write the disable bit for mag data ready interrupts
    uint8_t data[] = { 0, (1 << 0) };
    int dataSize = sizeof(data) / sizeof(data[0]);
    return [self.dataEnable writeDataAsync:[NSData dataWithBytes:&data length:dataSize]];
}

@end
