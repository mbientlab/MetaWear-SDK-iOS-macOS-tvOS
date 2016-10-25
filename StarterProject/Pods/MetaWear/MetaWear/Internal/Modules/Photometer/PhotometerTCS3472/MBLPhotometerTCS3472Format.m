/**
 * MBLPhotometerTCS3472Format.m
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

#import "MBLPhotometerTCS3472Format.h"
#import "MBLRGBData+Private.h"
#import "MBLNumericData+Private.h"

@implementation MBLPhotometerTCS3472Format

- (instancetype)init
{
    self = [super initArrayWithLength:8 elements:4];
    return self;
}

- (instancetype)initWithOffset:(uint8_t)offset
{
    self = [super initNumberWithLength:2 isSigned:NO offset:offset];
    return self;
}

- (id)entryFromData:(NSData *)data date:(NSDate *)date
{
    double red = DBL_MIN, green = DBL_MIN, blue = DBL_MIN, clear = DBL_MIN;
    const uint8_t *bytes = data.bytes;
    
    clear = (double)(*(uint16_t *)&bytes[0]);
    if (self.type == MBLFormatTypeArray) {
        red = (double)(*(uint16_t *)&bytes[2]);
        green = (double)(*(uint16_t *)&bytes[4]);
        blue = (double)(*(uint16_t *)&bytes[6]);
    }
    
    if (self.type == MBLFormatTypeArray) {
        return [[MBLRGBData alloc] initWithRed:red green:green blue:blue clear:clear timestamp:date];
    } else {
        return [[MBLNumericData alloc] initWithNumber:[NSNumber numberWithDouble:clear] timestamp:date];
    }
}

- (NSNumber *)numberFromDouble:(double)value
{
    return [NSNumber numberWithInt:value];
}

@end
