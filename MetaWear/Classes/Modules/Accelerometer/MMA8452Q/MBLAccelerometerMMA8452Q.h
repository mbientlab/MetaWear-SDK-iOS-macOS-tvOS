/**
 * MBLAccelerometerMMA8452Q.h
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

#import <MetaWear/MBLAccelerometer.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Accelerometer sensitiviy ranges
 */
typedef NS_ENUM(uint8_t, MBLAccelerometerRange) {
    MBLAccelerometerRange2G = 0,
    MBLAccelerometerRange4G = 1,
    MBLAccelerometerRange8G = 2
};

/**
 Accelerometer sleep sample frequencies
 */
typedef NS_ENUM(uint8_t, MBLAccelerometerSleepSampleFrequency) {
    MBLAccelerometerSleepSampleFrequency50Hz = 0,
    MBLAccelerometerSleepSampleFrequency12_5Hz = 1,
    MBLAccelerometerSleepSampleFrequency6_25Hz = 2,
    MBLAccelerometerSleepSampleFrequency1_56Hz = 3
};

/**
 Accelerometer power modes
 */
typedef NS_ENUM(uint8_t, MBLAccelerometerPowerScheme) {
    MBLAccelerometerPowerSchemeNormal = 0,
    MBLAccelerometerPowerSchemeLowNoiseLowPower = 1,
    MBLAccelerometerPowerSchemeHighResolution = 2,
    MBLAccelerometerPowerSchemeLowerPower = 3,
};

/**
 Accelerometer high-pass filter cutoff frequency types
 */
typedef NS_ENUM(uint8_t, MBLAccelerometerCutoffFreq) {
    MBLAccelerometerCutoffFreqHigheset = 0,
    MBLAccelerometerCutoffFreqHigh = 1,
    MBLAccelerometerCutoffFreqMedium = 2,
    MBLAccelerometerCutoffFreqLow = 3
};

/**
 Interface to an MMA8452Q accelerometer
 */
@interface MBLAccelerometerMMA8452Q : MBLAccelerometer
/**
 Maximum acceleration the accelerometer can report
 */
@property (nonatomic) MBLAccelerometerRange fullScaleRange;
/**
 High-pass filter enable; YES: Output data high-pass filtered, NO: No filter.
 With a high-pass filter, the frequencies below the cutoff (see highPassCutoffFreq),
 are removed. Only the high frequencies pass through.  This means that when
 enabled, you will only see changes in acceleration and not constant forces, like
 gravity.
 */
@property (nonatomic) BOOL highPassFilter;
/**
 High-pass filter cutoff frequency selection.  The higher the frequency the
 less you will see of slow acceleration changes.
 */
@property (nonatomic) MBLAccelerometerCutoffFreq highPassCutoffFreq;
/**
 Reduced noise reduced mode; NO: Normal Mode, YES: Reduced noise
 in low noise mode, the maximum signal that can be measured is ±4g. Note: Any
 thresholds set above 4g will not be reached.
 */
@property (nonatomic) BOOL lowNoise;
/**
 Fast Read mode; NO: Normal Mode, YES: Fast Read Mode F_READ bit selects between
 Normal and Fast Read mode. When selected, the auto-increment counter
 will skip over the LSB data bytes.
 */
@property (nonatomic) BOOL fastReadMode;

/**
 ACTIVE mode power scheme selection
 */
@property (nonatomic) MBLAccelerometerPowerScheme activePowerScheme;

/** Configures the Auto-WAKE sample frequency when the device is in
 SLEEP Mode
 */
@property (nonatomic) MBLAccelerometerSleepSampleFrequency sleepSampleFrequency;
/**
 SLEEP mode power scheme selection
 */
@property (nonatomic) MBLAccelerometerPowerScheme sleepPowerScheme;
/**
 Auto-SLEEP; NO: Disabled, YES: Enabled
 */
@property (nonatomic) BOOL autoSleep;


/**
 Select one or more axis used for tap detection
 */
@property (nonatomic) MBLAccelerometerAxis tapDetectionAxis;
/**
 Select the type of taps to be registered. When MBLAccelerometerTapModeBoth is used,
 you will get two events on a double tap, one for the single and one for the double.
 */
@property (nonatomic) MBLAccelerometerTapType tapType;
/**
 Event representing a tap (single, double, or both based on tapType) on the tapDetectionAxis.
 Event callbacks will be provided an empty MBLDataSample object
 */
@property (nonatomic, readonly, nonnull) MBLEvent<MBLDataSample *> *tapEvent;


/**
 Select threshold (in G's [0.0, 8.0]) for the shakeEvent.  This is used in conjuction
 with shakeWidth to determine when a shakeEvent will be generated.  Default value 0.5
 */
@property (nonatomic) double shakeThreshold;
/**
 Select time (in mSec) required for acceleration to be above shakeThreshold
 before a shakeEvent will be generated.  Default value 200.0
 */
@property (nonatomic) double shakeWidth;
/**
 Event representing a shake.  The sensitvity can be tuned using
 shakeThreshold and shakeWidth properties.
 Event callbacks will be provided an empty MBLDataSample object.
 */
@property (nonatomic, readonly) MBLEvent<MBLDataSample *> *shakeEvent;


/**
 Select threshold (in G's [0.0, 8.0]) for the freeFallEvent.  This is used in conjuction
 with freeFallWidth to determine when a freeFallEvent will be generated.  All accelerometer
 axis' must stay below freeFallThreshold for freeFallWidth mili-seconds.  Default value 0.2
 */
@property (nonatomic) double freeFallThreshold;
/**
 Select time (in mSec) required for all accelerometer axis' to be above freeFallThreshold
 before a freeFallEvent will be generated.  Default value 100.0
 */
@property (nonatomic) double freeFallWidth;
/**
 Event representing free fall, event occurs every freeFallWidth ms while the device
 is in free fall.
 Event callbacks will be provided an empty MBLDataSample object
 */
@property (nonatomic, readonly) MBLEvent<MBLDataSample *> *freeFallEvent;


/**
 Event representing an orientation change.
 Event callbacks will be provided an MBLOrientationData object
 */
@property (nonatomic, readonly) MBLEvent<MBLOrientationData *> *orientationEvent;

@end

NS_ASSUME_NONNULL_END
