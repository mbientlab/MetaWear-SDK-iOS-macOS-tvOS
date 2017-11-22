/**
 * MBLMagnetometerBMM150Format.m
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

#import "MBLMagnetometerBMM150Format.h"
#import "MBLMagnetometerData+Private.h"
#import "MBLNumericData+Private.h"

/**
 Magnetometer axis
 */
typedef NS_ENUM(uint8_t, MBLMagnetometerAxis) {
    MBLMagnetometerAxisX = 0,
    MBLMagnetometerAxisY = 1,
    MBLMagnetometerAxisZ = 2
};

@implementation MBLMagnetometerBMM150Format

- (instancetype)initWithPacked:(BOOL)packed
{
    self = [super initArrayWithElements:packed ? 9 : 3 elementSize:2 isSigned:YES];
    if (self) {
        self.packed = packed;
    }
    return self;
}

- (instancetype)initWithAxis:(uint8_t)axis
{
    MBLMagnetometerAxis typedAxis = axis;
    switch (typedAxis) {
        case MBLMagnetometerAxisX:
            self = [super initNumberWithLength:2 isSigned:YES offset:0];
            break;
        case MBLMagnetometerAxisY:
            self = [super initNumberWithLength:2 isSigned:YES offset:2];
            break;
        case MBLMagnetometerAxisZ:
            self = [super initNumberWithLength:2 isSigned:YES offset:4];
            break;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    MBLMagnetometerBMM150Format *newFormat = [super copyWithZone:zone];
    newFormat.packed = self.packed;
    return newFormat;
}

- (id)singleEntryFromData:(NSData *)data date:(NSDate *)date
{
    double x = DBL_MIN, y = DBL_MIN, z = DBL_MIN;
    const uint8_t *bytes = data.bytes;
    double scale = 0.0000000625; // Firmware units are 1/16 uT, we want T
    
    x = (double)(*(int16_t *)&bytes[0]) * scale;
    if (self.type == MBLFormatTypeArray) {
        y = (double)(*(int16_t *)&bytes[2]) * scale;
        z = (double)(*(int16_t *)&bytes[4]) * scale;
    }
    
    if (self.type == MBLFormatTypeArray) {
        return [[MBLMagnetometerData alloc] initWithX:x y:y z:z timestamp:date data:data];
    } else {
        return [[MBLNumericData alloc] initWithNumber:[NSNumber numberWithDouble:x] timestamp:date data:data];
    }
}

- (id)entryFromData:(NSData *)data date:(NSDate *)date
{
    if (self.packed) {
        return @[[self singleEntryFromData:[data subdataWithRange:NSMakeRange(0, 6)] date:date],
                 [self singleEntryFromData:[data subdataWithRange:NSMakeRange(6, 6)] date:date],
                 [self singleEntryFromData:[data subdataWithRange:NSMakeRange(12, 6)] date:date]];
    } else {
        return [self singleEntryFromData:data date:date];
    }
}

- (NSNumber *)numberFromDouble:(double)value
{
    double scale = 0.0000000625; // Firmware units are 1/16 uT, we are given T
    return [NSNumber numberWithInt:value / scale];
}

@end
