/**
 * MBLNumericFormatter.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 5/7/15.
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

#import "MBLNumericFormatter.h"
#import "MBLNumericData+Private.h"

@interface MBLNumericFormatter ()
@property (nonatomic) BOOL isDouble;
@property (nonatomic) double scale;
@end

@implementation MBLNumericFormatter

- (instancetype)initIntWithLength:(uint8_t)length isSigned:(BOOL)isSigned offset:(uint8_t)offset
{
    if (length > 8) {
        [NSException raise:@"Invalid size" format:@"Cannot convert over 8 bytes bytes to int"];
    }
    self = [super initNumberWithLength:length isSigned:isSigned offset:offset];
    if (self) {
        self.isDouble = NO;
    }
    return self;
}

- (instancetype)initIntWithLength:(uint8_t)length isSigned:(BOOL)isSigned
{
    return [self initIntWithLength:length isSigned:isSigned offset:0];
}

- (instancetype)initDoubleWithLength:(uint8_t)length isSigned:(BOOL)isSigned scale:(double)scale offset:(uint8_t)offset
{
    if (length > 8) {
        [NSException raise:@"Invalid size" format:@"Cannot convert over 8 bytes bytes to int"];
    }
    self = [super initNumberWithLength:length isSigned:isSigned offset:offset];
    if (self) {
        self.isDouble = YES;
        self.scale = scale;
    }
    return self;
}

- (instancetype)initDoubleWithLength:(uint8_t)length isSigned:(BOOL)isSigned scale:(double)scale
{
    return [self initDoubleWithLength:length isSigned:isSigned scale:scale offset:0];
}

- (id)copyWithZone:(NSZone *)zone
{
    MBLNumericFormatter *newFormat = [super copyWithZone:zone];
    newFormat.isDouble = self.isDouble;
    newFormat.scale = self.scale;
    return newFormat;
}

// The analyzer doesn't like i64 here, but it fact has been set to a valid value
// this is well tested, so we just silence the analyzer here
#ifndef __clang_analyzer__
- (id)entryFromData:(NSData *)data date:(NSDate *)date
{
    NSNumber *value = nil;
    assert(data.length <= 8);
    if (self.isSigned) {
        int64_t i64 = 0;
        uint8_t *pi64 = (uint8_t *)&i64;
        memcpy(pi64, data.bytes, data.length);
        
        // check if signed and if sign bit is set
        const uint8_t *bytes = data.bytes;
        if (bytes[data.length - 1] & 0x80) {
            for (NSInteger i = data.length; i < sizeof(int64_t); i++) {
                pi64[i] = 0xFF;  // pad the upper order bytes
            }
        }
        if (self.isDouble) {
            value = [NSNumber numberWithDouble:(double)i64 * self.scale];
        } else {
            value = [NSNumber numberWithLongLong:i64];
        }
    } else {
        uint64_t u64 = 0;
        memcpy(&u64, data.bytes, data.length);
        if (self.isDouble) {
            value = [NSNumber numberWithDouble:(double)u64 * self.scale];
        } else {
            value = [NSNumber numberWithUnsignedLongLong:u64];
        }
    }
    return [[MBLNumericData alloc] initWithNumber:value timestamp:date];
}
#endif

- (NSNumber *)numberFromDouble:(double)value
{
    if (self.isDouble) {
        value = value / self.scale;
    }
    return [NSNumber numberWithInt:value];
}

@end
