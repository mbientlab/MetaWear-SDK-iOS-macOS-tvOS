/**
 * MBLAccelerometerBoschOrientationFormat.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 6/12/15.
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

#import "MBLAccelerometerBoschOrientationFormat.h"
#import "MBLOrientationData+Private.h"

@implementation MBLAccelerometerBoschOrientationFormat

- (instancetype)init
{
    self = [super initEncodedDataWithLength:1];
    return self;
}

- (id)entryFromData:(NSData *)data date:(NSDate *)date
{
    MBLAccelerometerOrientation result;
    uint8_t updsideDown = ((*(uint8_t *)data.bytes) >> 3) & 0x1;
    uint8_t orient = ((*(uint8_t *)data.bytes) >> 1) & 0x3;
    switch (orient) {
        case 0:
            result = MBLAccelerometerOrientationLandscapeRight;
            break;
        case 1:
            result = MBLAccelerometerOrientationLandscapeLeft;
            break;
        case 2:
            result = MBLAccelerometerOrientationPortrait;
            break;
        case 3:
            result = MBLAccelerometerOrientationPortraitUpsideDown;
            break;
        default:
            result = 0;
            NSAssert(NO, @"Unexpected byte from the orientation");
    }
    return [[MBLOrientationData alloc] initWithOrientation:result
                                           facingDirection:updsideDown ? MBLAccelerometerFacingDirectionDownward : MBLAccelerometerFacingDirectionUpward
                                                 timestamp:date
                                                      data:data];
}

- (NSNumber *)numberFromDouble:(double)value
{
    uint8_t orientationValue  = 3;
    if (fabs(value - MBLAccelerometerOrientationLandscapeRight) < DBL_EPSILON) {
        orientationValue = 0;
    } else if (fabs(value - MBLAccelerometerOrientationLandscapeLeft) < DBL_EPSILON) {
        orientationValue = 1;
    } else if (fabs(value - MBLAccelerometerOrientationPortrait) < DBL_EPSILON) {
        orientationValue = 2;
    }
    return [NSNumber numberWithUnsignedChar:(orientationValue << 1) | 0x1];
}

@end
