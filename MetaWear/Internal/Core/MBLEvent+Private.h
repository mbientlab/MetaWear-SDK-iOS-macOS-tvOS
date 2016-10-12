/**
 * MBLEvent+Private.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 10/13/14.
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

#import "MBLEvent.h"
#import "MBLRegister+Private.h"
#import "MBLModule+Private.h"
#import "MBLFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface MBLEvent (Private)
@property (nonatomic, readonly) NSMutableArray *loggingIds;
@property (nonatomic, readonly) NSMutableArray *commandIds;
@property (nonatomic, readonly) NSMutableArray *commandActivatedRegisters;

- (instancetype)initWithModule:(MBLModule *)module registerId:(uint8_t)registerId index:(uint8_t)index format:(MBLFormat *)format;
- (instancetype)initWithModule:(MBLModule *)module registerId:(uint8_t)registerId format:(MBLFormat *)format;

/**
 @param lookahead Distance to look ahead from a peak candidate to determine
 if it is the actual peak '(sample / period) / f' where '4 >= f >= 1.25' might be a good value
 @param delta This specifies a minimum difference between a min/max and
 the following points in order to be considered a local min/max. Prevents
 the method from picking up false mins/maxs. To work well delta should
 be set to delta >= RMSnoise * 5.
 */
- (MBLEvent *)maxPeakDetectorOfEventWithLookahead:(uint8_t)lookahead delta:(uint32_t)delta extraPeakWidth:(uint8_t)extraPeakWidth isSigned:(BOOL)isSigned;
- (MBLEvent *)minPeakDetectorOfEventWithLookahead:(uint8_t)lookahead delta:(uint32_t)delta extraPeakWidth:(uint8_t)extraPeakWidth isSigned:(BOOL)isSigned;

- (MBLFilter *)modifyEventUsingOperation:(MBLArithmeticOperation)op withData:(double)data;

- (MBLEvent *)punchDetectorOfEventWithLookahead:(uint8_t)lookahead delta:(int16_t)delta areaThreshold:(uint16_t)areaThreshold startThreshold:(uint16_t)startThreshold;

- (MBLFilter *)fallDetectorOfEventWithAccel:(uint8_t)accelShift gyro:(uint8_t)gyroShift;

@end

NS_ASSUME_NONNULL_END