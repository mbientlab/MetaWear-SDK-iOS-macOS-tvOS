/**
 * MBLAccelerometerBoschLowOrHighGEvent.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 11/4/15.
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
#import <MetaWear/MBLAccelerometer.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBLAccelerometerBoschLowOrHighGEvent : MBLEvent<MBLDataSample *>


#pragma mark - Beta API (Subject to change)

/**
 The BMI160 combines low-g and high-g detection, so below we expose the
 raw registers as a first enabling step.  Over time this will become
 better encapsulated.
 */

/**
 Set to YES if you want low-g events
 */
@property (nonatomic) BOOL lowGEnabled;
/**
 Time in ms that acceleration must stay below lowGThreshold before an event is triggered.
 */
@property (nonatomic) double lowGDuration;
/**
 Acceleration in G's that acceleration must stay below to be consided a low-g event.
 */
@property (nonatomic) double lowGThreshold;
/**
 Hysteresis for the low-g threshold.
 */
@property (nonatomic) double lowGHysteresis;
/**
 Set to YES for axis-summing mode (summed absolute value of all axis must be below lowGThreshold).
 Set to NO for single-axis mode (absolute value of each axis is compared to lowGThreshold).
 */
@property (nonatomic) BOOL lowGMode;


/**
 Bitmask for axis enabled for high-g detection.
 */
@property (nonatomic) MBLAccelerometerAxis highGEnabledAxis;
/**
 Time in ms that acceleration must stay above highGThreshold before an event is triggered.
 */
@property (nonatomic) double highGDuration;
/**
 Acceleration in G's that acceleration must stay above to be consided a high-g event.
 */
@property (nonatomic) double highGThreshold;
/**
 Hysteresis for the high-g threshold.
 */
@property (nonatomic) double highGHysteresis;

@end

NS_ASSUME_NONNULL_END
