/**
 * MBLDataSample.m
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
#import "MBLDataSample+Private.h"

@interface MBLDataSample ()
@property (nonatomic) NSDate *timestamp;
@property (nonatomic) NSData *data;
@end

@implementation MBLDataSample

- (instancetype)initWithTimestamp:(NSDate *)timestamp data:(NSData *)data
{
    self = [super init];
    if (self) {
        self.timestamp = timestamp;
        self.data = data;
    }
    return self;
}

- (NSString *)description
{
    if (self.data) {
        return [NSString stringWithFormat:@"%@ %@", [NSDateFormatter localizedStringFromDate:self.timestamp
                                                                                   dateStyle:NSDateFormatterMediumStyle
                                                                                   timeStyle:NSDateFormatterMediumStyle], self.data];
    } else {
        return [NSDateFormatter localizedStringFromDate:self.timestamp
                                              dateStyle:NSDateFormatterMediumStyle
                                              timeStyle:NSDateFormatterMediumStyle];
    }
}

- (NSString *)csvRepresentation
{
    uint8_t const *bytes = self.data.bytes;
    NSInteger length = self.data.length;
    NSMutableString *str = [NSMutableString string];
    if (length > 0) {
        [str appendFormat:@"%02X", *bytes];
        bytes++;
    }
    for (int i = 1; i < length; i++, bytes++) {
        [str appendFormat:@"-%02X", *bytes];
    }
    return [NSString stringWithFormat:@"%f,%@\n", self.timestamp.timeIntervalSince1970, str];
}

@end
