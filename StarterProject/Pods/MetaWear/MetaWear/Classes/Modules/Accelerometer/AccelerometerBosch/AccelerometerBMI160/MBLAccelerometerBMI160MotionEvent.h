/**
 * MBLAccelerometerBMI160MotionEvent.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 7/20/15.
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

#import <MetaWear/MBLEvent.h>
@class MBLDataSample;

NS_ASSUME_NONNULL_BEGIN


@interface MBLAccelerometerBMI160MotionEvent : MBLEvent<MBLDataSample *>

#pragma mark - Beta API (Subject to change)

/**
 The BMI160 combines Slow/No-Motion and Any/Signification-Motion detection, so below
 we expose the raw registers as a first enabling step.  Over time this will become
 better encapsulated.
 */

#pragma mark - Slow-Motion/No-Motion
/**
 Set to YES if you want slow/no-motion events
 */
@property (nonatomic) BOOL slowNoMotionEnabled;
/**
 Set to YES if you want slow-motion, set to NO if you want no-motion
 */
@property (nonatomic) BOOL useSlowMotion;
/**
 No-Motion: Time in ms for which no slope data point must exceeed slow/no-mothion threshold
 Slow-Motion:  Time in ms for which slope data points must be above the slow/no-motion threshold
 */
@property (nonatomic) double slowNoMotionDuration;
/**
 Threshold in G's for detecting slow/no-motion events
 */
@property (nonatomic) double slowNoMotionThreshold;


#pragma mark - Significant-Motion/Any-Motion
/**
 Set to YES if you want significant/any-motion events
 */
@property (nonatomic) BOOL significantAnyMotionEnabled;
/**
 Set to YES if you want significant-motion, set to NO if you want any-motion
 */
@property (nonatomic) BOOL useSignificantMotion;
/**
 Time in ms for which slope data points must be above the anyMotionThreshold threshold
 */
@property (nonatomic) double anyMotionDuration;
/**
 Threshold in G's for detecting any-motion events
 */
@property (nonatomic) double anyMotionThreshold;
/**
 Significant-Motion is a combination of any-motion events.  It's a state machine that works as
 follows, 1) Any-Motion Detected. 2) Sleep for significantMotionSkipTime. 3) Look for Any-Motion
 again within significantMotionProofTime, and if found trigger a significant-motion event.
 Units are in seconds
*/
@property (nonatomic) double significantMotionSkipTime;
@property (nonatomic) double significantMotionProofTime;

@end

NS_ASSUME_NONNULL_END
