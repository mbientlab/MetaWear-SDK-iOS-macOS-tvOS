/**
 * MBLMacAddressFormat.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 12/16/15.
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

#import "MBLMacAddressFormat.h"
#import "MBLFormat.h"
#import "MBLStringData+Private.h"

@implementation MBLMacAddressFormat

- (instancetype)initWithAddressType:(BOOL)hasAddressType
{
    uint8_t length = hasAddressType ? 7 : 6;
    self = [super initEncodedDataWithLength:length];
    if (self) {
        self.hasAddressType = hasAddressType;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    MBLMacAddressFormat *newFormat = [super copyWithZone:zone];
    newFormat.hasAddressType = self.hasAddressType;
    return newFormat;
}

- (id)entryFromData:(NSData *)data date:(NSDate *)date
{
    if ((self.hasAddressType && data.length != 7) || (!self.hasAddressType && data.length != 6)) {
        return [[MBLStringData alloc] initWithString:@"N/A" timestamp:date data:data];
    }
    uint8_t const *macBytes = data.bytes;
    uint8_t const offset = self.hasAddressType ? 1 : 0;
    NSString *macStr = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X", macBytes[5 + offset], macBytes[4 + offset], macBytes[3 + offset], macBytes[2 + offset], macBytes[1 + offset], macBytes[0 + offset]];
    return [[MBLStringData alloc] initWithString:macStr timestamp:date data:data];
}

- (NSNumber *)numberFromDouble:(double)value
{
    [NSException raise:@"Cannout use MAC Address with filters" format:@""];
    return nil;
}

@end
