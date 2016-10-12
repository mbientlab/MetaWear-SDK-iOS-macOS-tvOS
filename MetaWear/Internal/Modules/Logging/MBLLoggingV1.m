/**
 * MBLLoggingV1.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 8/24/15.
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

#import "MBLLoggingV1.h"
#import "MBLRegister+Private.h"
#import "MBLNumericFormatter.h"

@implementation MBLLoggingV1

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        self.logLength = [[MBLRegister alloc] initWithModule:self registerId:0x5 format:[[MBLNumericFormatter alloc] initIntWithLength:4 isSigned:NO]];
        self.logReadout = [[MBLRegister alloc] initWithModule:self registerId:0x6 format:[[MBLFormat alloc] initEncodedDataWithLength:8]];
        self.logReadoutProgress = [[MBLRegister alloc] initWithModule:self registerId:0x8 format:[[MBLNumericFormatter alloc] initIntWithLength:4 isSigned:NO]];
    }
    return self;
}

- (BFTask *)dropAllEntries
{
    uint32_t count = 0xFFFFFFFF;
    return [self.dropEntries writeDataAsync:[NSData dataWithBytes:&count length:4]];
}

- (BFTask *)startReadout:(uint32_t)totalEntries
{
    NSMutableData *params = [NSMutableData dataWithBytes:&totalEntries length:4];
    uint32_t delta;
    if (totalEntries > 2000) {
        delta = totalEntries / 100;
    } else if (totalEntries > 1000) {
        delta = totalEntries / 10;
    } else if (totalEntries > 100) {
        delta = totalEntries / 4;
    } else {
        delta = UINT32_MAX;
    }
    [params appendBytes:&delta length:4];
    return [self.logReadout writeDataAsync:params];
}

@end
