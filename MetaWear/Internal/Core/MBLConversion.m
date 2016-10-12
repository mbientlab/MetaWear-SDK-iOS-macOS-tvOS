/**
 * MBLConversion.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 5/5/15.
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

#import "MBLConversion.h"

@implementation MBLConversion

+ (BOOL)number:(NSNumber *)number toInt32:(int32_t *)int32Pointer
{
    double boundsCheck = number.doubleValue;
    if (boundsCheck < INT32_MIN || boundsCheck > INT32_MAX) {
        return NO;
    }
    int32_t value = number.intValue;
    memcpy(int32Pointer, &value, sizeof(int32_t));
    return YES;
}

+ (BOOL)number:(NSNumber *)number toUint32:(uint32_t *)uint32Pointer
{
    double boundsCheck = number.doubleValue;
    if (boundsCheck < 0 || boundsCheck > UINT32_MAX) {
        return NO;
    }
    uint32_t value = number.unsignedIntValue;
    memcpy(uint32Pointer, &value, sizeof(uint32_t));
    return YES;
}


+ (BOOL)number:(NSNumber *)number toInt16:(int16_t *)int16Pointer
{
    double boundsCheck = number.doubleValue;
    if (boundsCheck < INT16_MIN || boundsCheck > INT16_MAX) {
        return NO;
    }
    int16_t value = number.shortValue;
    memcpy(int16Pointer, &value, sizeof(int16_t));
    return YES;
}

+ (BOOL)number:(NSNumber *)number toUint16:(uint16_t *)uint16Pointer
{
    double boundsCheck = number.doubleValue;
    if (boundsCheck < 0 || boundsCheck > UINT16_MAX) {
        return NO;
    }
    uint16_t value = number.unsignedShortValue;
    memcpy(uint16Pointer, &value, sizeof(uint16_t));
    return YES;
}

+ (BOOL)number:(NSNumber *)number toInt8:(int8_t *)int8Pointer
{
    double boundsCheck = number.doubleValue;
    if (boundsCheck < INT8_MIN || boundsCheck > INT8_MAX) {
        return NO;
    }
    int8_t value = number.charValue;
    memcpy(int8Pointer, &value, sizeof(int8_t));
    return YES;
}

+ (BOOL)number:(NSNumber *)number toUint8:(uint8_t *)uint8Pointer
{
    double boundsCheck = number.doubleValue;
    if (boundsCheck < 0 || boundsCheck > UINT8_MAX) {
        return NO;
    }
    uint8_t value = number.unsignedCharValue;
    memcpy(uint8Pointer, &value, sizeof(uint8_t));
    return YES;
}

@end
