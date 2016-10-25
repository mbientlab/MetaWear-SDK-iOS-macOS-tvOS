/**
 * MBLAccelerometerBMI160.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 5/27/15.
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

#import <MetaWear/MBLAccelerometerBosch.h>
#import <MetaWear/bmi160.h>
@class MBLNumericData;
@class MBLAccelerometerBMI160MotionEvent;

NS_ASSUME_NONNULL_BEGIN

/**
 Interface to a BMI160 accelerometer
 */
@interface MBLAccelerometerBMI160 : MBLAccelerometerBosch

/**
 Event representing a motion (change of acceleration) event.
 Event callbacks will be provided an empty MBLDataSample object
 */
@property (nonatomic, readonly) MBLAccelerometerBMI160MotionEvent *motionEvent;


/**
 This event will fire when a step pattern is detected. Event callbacks will be provided
 an MBLNumericData object, whose int value is always 1.
 */
@property (nonatomic, readonly) MBLEvent<MBLNumericData *> *stepEvent;
/**
 This data endpoint keeps a running counter in hardware of the number of steps taken.
 Event callbacks will be provided an MBLNumericData object, whose unsigened value is
 the number steps taken.  Note this only counts up when stepEvent is active.
 */
@property (nonatomic, readonly) MBLData<MBLNumericData *> *stepCounter;
/**
 Use this to reset stepCounter to 0
 */
- (BFTask *)resetStepCount;

@end

NS_ASSUME_NONNULL_END
