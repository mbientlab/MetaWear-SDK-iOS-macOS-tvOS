/**
 * MBLGPIOPin.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 10/29/14.
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

#import <MetaWear/MBLConstants.h>
#import <Bolts/Bolts.h>
@class MBLEvent<ResultType>;
@class MBLData<ResultType>;
@class MBLNumericData;

NS_ASSUME_NONNULL_BEGIN

/**
 Input pin configuration types
 */
typedef NS_ENUM(uint8_t, MBLPinConfiguration) {
    MBLPinConfigurationPullup = 0,
    MBLPinConfigurationPulldown = 1,
    MBLPinConfigurationNopull = 2
};

/**
 Analog read modes
 */
typedef NS_ENUM(uint8_t, MBLAnalogReadMode) {
    MBLAnalogReadModeFixed = 0,
    MBLAnalogReadModeSupplyRatio = 1
};

/**
 Pin change types
 */
typedef NS_ENUM(uint8_t, MBLPinChangeType) {
    MBLPinChangeTypeRising = 1,
    MBLPinChangeTypeFalling = 2,
    MBLPinChangeTypeAny = 3
};

/**
 Encapsulation of a single input/output pin
 */
@interface MBLGPIOPin : NSObject

/**
 Set what pin state transitions trigger a changeEvent.
 */
@property (nonatomic) MBLPinChangeType changeType;
/**
 Set pull configuration for the pin
 */
- (MBLPinConfiguration)configuration;
- (BFTask *)setConfiguration:(MBLPinConfiguration)configuration;


///----------------------------------
/// @name Reading Values
///----------------------------------
/**
 Event representing a change in the pin's digital value, you can choose
 what state transitions trigger this event using the changeType property.
 Event callbacks will be provided an MBLNumericData object whose bool
 value indicates what state the pin changed to, YES means set, NO means
 clear.
 */
@property (nonatomic, readonly, nullable) MBLEvent<MBLNumericData *> *changeEvent;
/**
 Data representing the digital value of the pin.
 Event callbacks will be provided an MBLNumericData object whose bool
 value indicates what state the pin is in, YES means set, NO means clear.
 */
@property (nonatomic, readonly, nullable) MBLData<MBLNumericData *> *digitalValue;
/**
 Data representing the analog value of the pin.
 Event callbacks will be provided an MBLNumericData object whose double
 value will be volts.
 @warning Not all pins support analog reads
 */
@property (nonatomic, readonly, nullable) MBLData<MBLNumericData *> *analogAbsolute;
/**
 Data representing the analog value of the pin as a ratio of the supply voltage.
 Event callbacks will be provided an MBLNumericData object whose double value
 will range from 0.0 to 1.0, where 0.0 indicates pin is equal to
 ground, and 1.0 indicates pin is equal to supply voltage.
 @warning Not all pins support analog reads
 */
@property (nonatomic, readonly, nullable) MBLData<MBLNumericData *> *analogRatio;

///----------------------------------
/// @name Automatic Analog Sensor Enabling
///----------------------------------

// To save power, sensors connected to a GPIO pin may optionally have an
// "enable" switch connected to another pin.  Pulling up or down these
// enable pins can programmatically turn off the sensor to save power.
// Use the follow functions to create a special MBLData object that will
// automatically set the pullUp/pullDown pins, wait a certain amount of time,
// perform the read, then set the pullUp/pullDown pins back to MBLPinConfigurationNopull.

/**
 Create a new analogRatio data object that automatically sets and clears
 pull up/down pins.
 @param pullUp Pin to set high just before analog read is started, nil if none
 @param pullDown  Pin to set low just before analog read is started, nil if none
 @param readDelay Time, in uSec, to delay the analog read after the pullUpPin and
 pullDownPin have been set.  Note there is some delay by default
 due to firmware code execution time, so this is in addtion to that.
 @returns New analogRatio data
 */
- (MBLData<MBLNumericData *> *)analogRatioWithPullUp:(nullable NSNumber *)pullUp
                                            pullDown:(nullable NSNumber *)pullDown
                                           readDelay:(uint16_t)readDelay;

/**
 Create a new analogAbsolute data object that automatically sets and clears
 pull up/down pins.
 @param pullUp Pin to set high just before analog read is started, nil if none
 @param pullDown  Pin to set low just before analog read is started, nil if none
 @param readDelay Time, in uSec, to delay the analog read after the pullUpPin and
 pullDownPin have been set.  Note there is some delay by default
 due to firmware code execution time, so this is in addtion to that.
 @returns New analogAbsolute data
 */
- (MBLData<MBLNumericData *> *)analogAbsoluteWithPullUp:(nullable NSNumber *)pullUp
                                               pullDown:(nullable NSNumber *)pullDown
                                              readDelay:(uint16_t)readDelay;

///----------------------------------
/// @name Setting Values
///----------------------------------
/**
 Set a digital output GPIO Pin to a 1 or 0.
 @param on YES sets pin to 1 (high), NO clears pin to 0 (low)
 */
- (BFTask *)setToDigitalValueAsync:(BOOL)on;


///----------------------------------
/// @name Deprecated
///----------------------------------
// @deprecated
@property (nonatomic, nullable) NSNumber *enablePin DEPRECATED_MSG_ATTRIBUTE("Use analogRatioWithPullUp:pullDown:readDelay or analogAbsoluteWithPullUp:pullDown:readDelay instead");
// @deprecated
@property (nonatomic) BOOL enablePinActiveLow DEPRECATED_MSG_ATTRIBUTE("Use analogRatioWithPullUp:pullDown:readDelay or analogAbsoluteWithPullUp:pullDown:readDelay instead");

@end

NS_ASSUME_NONNULL_END
