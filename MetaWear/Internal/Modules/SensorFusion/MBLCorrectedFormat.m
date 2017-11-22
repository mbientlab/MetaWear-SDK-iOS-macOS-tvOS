/**
 * MBLCorrectedFormat.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 11/8/16.
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

#import "MBLCorrectedFormat.h"
#import "MBLAccelerometerData+Private.h"
#import "MBLGyroData+Private.h"
#import "MBLMagnetometerData+Private.h"
#import "MBLConstants.h"

@implementation MBLCorrectedFormat

- (instancetype)initWithType:(MBLCorrectedFormatType)formatType
{
    self = [super initEncodedDataWithLength:13];
    if (self) {
        self.formatType = formatType;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    MBLCorrectedFormat *newFormat = [super copyWithZone:zone];
    newFormat.formatType = self.formatType;
    return newFormat;
}

- (id)entryFromData:(NSData *)data date:(NSDate *)date
{
    const uint8_t *bytes = data.bytes;
    const double x = (double)(*(float *)&bytes[0]);
    const double y = (double)(*(float *)&bytes[4]);
    const double z = (double)(*(float *)&bytes[8]);
    const MBLCalibrationAccuracy accuracy = (MBLCalibrationAccuracy)(*(uint8_t *)&bytes[12]);
    switch (self.formatType) {
        case MBLCorrectedFormatTypeAccelerometer:
            return [[MBLCorrectedAccelerometerData alloc] initWithX:x / 1000.0 y:y / 1000.0 z:z / 1000.0 accuracy:accuracy timestamp:date data:data];
        case MBLCorrectedFormatTypeGyro:
            return [[MBLCorrectedGyroData alloc] initWithX:x y:y z:z timestamp:date data:data];
        case MBLCorrectedFormatTypeMagnetometer:
            return [[MBLCorrectedMagnetometeData alloc] initWithX:x / 1000000.0 y:y / 1000000.0 z:z / 1000000.0 timestamp:date data:data];
    }
    return nil;
}

- (NSNumber *)numberFromDouble:(double)value
{
    [NSException raise:@"Cannot use Sensor Fusion data with filters" format:@""];
    return nil;
}

@end
