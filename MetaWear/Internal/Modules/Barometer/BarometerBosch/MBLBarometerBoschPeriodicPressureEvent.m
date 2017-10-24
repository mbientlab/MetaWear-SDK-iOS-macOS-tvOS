/**
 * MBLBarometerBoschPeriodicPressureEvent.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 7/24/15.
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

#import "MBLBarometerBoschPeriodicPressureEvent.h"
#import "MBLBarometerBosch.h"
#import "MBLNumericFormatter.h"

@interface MBLBarometerBoschPeriodicPressureEvent ()
@property (nonatomic) MBLRegister *cyclicEnable;
@end

@implementation MBLBarometerBoschPeriodicPressureEvent

- (instancetype)initWithBarometer:(MBLBarometerBosch *)barometer
{
    self = [super initWithModule:barometer registerId:0x01 format:[[MBLNumericFormatter alloc] initDoubleWithLength:4 isSigned:NO scale:1.0 / 256.0] identifier:@"pressure"];
    if (self) {
        self.cyclicEnable = [[MBLRegister alloc] initWithModule:barometer registerId:0x04 format:[[MBLFormat alloc] initEncodedDataWithLength:2]];
    }
    return self;
}

- (BFTask *)performAsyncActivation
{
    // Enable cyclic mode without altitude conversion
    uint8_t data[] = { 1, 0 };
    int dataSize = sizeof(data) / sizeof(data[0]);
   return  [self.cyclicEnable writeDataAsync:[NSData dataWithBytes:&data length:dataSize]];
}

- (BFTask *)performAsyncDeactivation
{
    // Write the disable bit for orientation interrupts
    uint8_t data[] = { 0, 0 };
    int dataSize = sizeof(data) / sizeof(data[0]);
    return [self.cyclicEnable writeDataAsync:[NSData dataWithBytes:&data length:dataSize]];
}

@end
