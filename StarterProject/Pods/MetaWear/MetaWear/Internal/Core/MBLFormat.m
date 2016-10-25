/**
 * MBLFormat.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 5/6/15.
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

#import "MBLFormat.h"
#import "MBLDataSample+Private.h"

@implementation MBLFormat

+ (instancetype)writeOnly
{
    return [[MBLFormat alloc] initEncodedDataWithLength:0];
}

- (instancetype)initNumberWithLength:(uint8_t)length isSigned:(BOOL)isSigned offset:(uint8_t)offset
{
    self = [super init];
    if (self) {
        self.length = length;
        self.type = MBLFormatTypeNumber;
        self.offset = offset;
        self.isSigned = isSigned;
    }
    return self;
}

- (instancetype)initNumberWithLength:(uint8_t)length isSigned:(BOOL)isSigned
{
    return [self initNumberWithLength:length isSigned:isSigned offset:0];
}

- (instancetype)initArrayWithLength:(uint8_t)length elements:(uint8_t)elements
{
    self = [super init];
    if (self) {
        self.length = length;
        self.type = MBLFormatTypeArray;
        self.elements = elements;
    }
    return self;
}

- (instancetype)initEncodedDataWithLength:(uint8_t)length
{
    self = [super init];
    if (self) {
        self.length = length;
        self.type = MBLFormatTypeEncodedData;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    MBLFormat *newFormat = [[self class] allocWithZone:zone];
    newFormat.length = self.length;
    newFormat.type = self.type;
    newFormat.offset = self.offset;
    newFormat.elements = self.elements;
    newFormat.isSigned = self.isSigned;
    return newFormat;
}

- (id)entryFromData:(NSData *)data date:(NSDate *)date
{
    return [[MBLDataSample alloc] initWithTimestamp:date data:data];
}

- (NSNumber *)numberFromDouble:(double)value
{
    [NSException raise:@"Derived class must implement numberFromDouble:" format:@""];
    return nil;
}

@end
