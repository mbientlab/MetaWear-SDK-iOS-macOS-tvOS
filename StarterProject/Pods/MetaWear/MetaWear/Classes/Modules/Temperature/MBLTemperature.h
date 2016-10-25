/**
 * MBLTemperature.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 8/1/14.
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
#import <MetaWear/MBLEvent.h>
#import <MetaWear/MBLModule.h>
#import <MetaWear/MBLExternalThermistor.h>
@class MBLNumericData;
@class MBLMetaWear;

NS_ASSUME_NONNULL_BEGIN

/**
 Interface to the on-chip and external thermistor temperature sensors
 */
@interface MBLTemperature : MBLModule

/**
 Array of MBLData (or derived class) objects corresponding to the different
 temperature sensors available on this particular MetaWear. Event callbacks
 will be provided an MBLNumericData object whose double value will be
 degrees Celsius.
 */
@property (nonatomic, readonly) NSArray<MBLData<MBLNumericData *> *> *channels;

///----------------------------------
/// @name Convenient Assessors - also available via channels[N]
///----------------------------------

/**
 Data representing the current temperate of the internal (on-die) sensor.
 This is guaranteed to always be available (equal to channels[0]).
 Event callbacks will be provided an MBLNumericData object whose double 
 value will be degrees Celsius.
 */
@property (nonatomic, readonly) MBLData<MBLNumericData *> *onDieThermistor;
@property (nonatomic, readonly) MBLData<MBLNumericData *> *internal DEPRECATED_MSG_ATTRIBUTE("Use onDieThermistor instead");

/**
 Data representing the current temperate of the external thermistor, if
 equiped. This is a thermistor that you connect manually, so you need
 to setup readPin and enablePin on the MBLExternalThermistor object.
 Event callbacks will be provided an MBLNumericData object whose double
 value will be degrees Celsius.
 */
@property (nonatomic, readonly, nullable) MBLExternalThermistor<MBLNumericData *> *externalThermistor;

/**
 Data representing the current temperate of the on-board thermistor, if
 equiped. Event callbacks will be provided an MBLNumericData object whose
 double value will be degrees Celsius.
 */
@property (nonatomic, readonly, nullable) MBLData<MBLNumericData *> *onboardThermistor;

@end

NS_ASSUME_NONNULL_END
