/**
 * MBLGyroBMI160Format.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 5/26/15.
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

#import "MBLGyroBMI160Format.h"
#import "MBLGyroBMI160+Private.h"
#import "MBLGyroData+Private.h"
#import "MBLNumericData+Private.h"

@implementation MBLGyroBMI160Format

- (instancetype)initWithGyro:(MBLGyroBMI160 *)gyro packed:(BOOL)packed
{
    self = [super initArrayWithElements:packed ? 9 : 3 elementSize:2 isSigned:YES];
    if (self) {
        self.gyro = gyro;
        self.packed = packed;
    }
    return self;
}

- (instancetype)initWithGyro:(MBLGyroBMI160 *)gyro axis:(uint8_t)axis;
{
    MBLGyroAxis typedAxis = axis;
    switch (typedAxis) {
        case MBLGyroAxisX:
            self = [super initNumberWithLength:2 isSigned:YES offset:0];
            break;
        case MBLGyroAxisY:
            self = [super initNumberWithLength:2 isSigned:YES offset:2];
            break;
        case MBLGyroAxisZ:
            self = [super initNumberWithLength:2 isSigned:YES offset:4];
            break;
    }
    if (self) {
        self.gyro = gyro;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    MBLGyroBMI160Format *newFormat = [super copyWithZone:zone];
    newFormat.gyro = self.gyro;
    newFormat.packed = self.packed;
    return newFormat;
}

- (id)singleEntryFromData:(NSData *)data date:(NSDate *)date
{
    double x = DBL_MIN, y = DBL_MIN, z = DBL_MIN;
    const uint8_t *bytes = data.bytes;
    double scale;
    switch (self.gyro.fullScaleRange) {
        case MBLGyroBMI160Range2000:
            scale = 2000.0 / 32768.0;
            break;
        case MBLGyroBMI160Range1000:
            scale = 1000.0 / 32768.0;
            break;
        case MBLGyroBMI160Range500:
            scale = 500.0 / 32768.0;
            break;
        case MBLGyroBMI160Range250:
            scale = 250.0 / 32768.0;
            break;
        case MBLGyroBMI160Range125:
            scale = 125.0 / 32768.0;
            break;
    }
    x = (double)(*(int16_t *)&bytes[0]) * scale;
    if (self.type == MBLFormatTypeArray) {
        y = (double)(*(int16_t *)&bytes[2]) * scale;
        z = (double)(*(int16_t *)&bytes[4]) * scale;
    }

    if (self.type == MBLFormatTypeArray) {
        return [[MBLGyroData alloc] initWithX:x y:y z:z timestamp:date];
    } else {
        return [[MBLNumericData alloc] initWithNumber:[NSNumber numberWithDouble:x] timestamp:date];
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
    double scale;
    switch (self.gyro.fullScaleRange) {
        case MBLGyroBMI160Range2000:
            scale = 2000.0 / 32768.0;
            break;
        case MBLGyroBMI160Range1000:
            scale = 1000.0 / 32768.0;
            break;
        case MBLGyroBMI160Range500:
            scale = 500.0 / 32768.0;
            break;
        case MBLGyroBMI160Range250:
            scale = 250.0 / 32768.0;
            break;
        case MBLGyroBMI160Range125:
            scale = 125.0 / 32768.0;
            break;
    }
    return [NSNumber numberWithInt:value / scale];
}

@end
