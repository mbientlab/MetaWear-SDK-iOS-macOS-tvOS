/**
 * MBLBarometer.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 4/27/15.
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
@class MBLNumericData;

NS_ASSUME_NONNULL_BEGIN

/**
 Interface to an abstract barometer sensor. If you need more advanced
 features then upcast to the specific sensor on your board, MBLBarometerBMP280 or MBLBarometerBME280.
 @see MBLBarometerBMP280
 @see MBLBarometerBME280
 */
@interface MBLBarometer : MBLModule

/**
 Data representing the atmospheric pressure measured by barometer.
 Event callbacks will be provided an MBLNumericData object whose double
 value will be pressure in pascals.
 */
@property (nonatomic, readonly) MBLData<MBLNumericData *> *pressure;
/**
 Data representing the altidue calulated from atmospheric pressure.
 Event callbacks will be provided an MBLNumericData object whose double
 value will be altitude in meters.
 */
@property (nonatomic, readonly) MBLData<MBLNumericData *> *altitude;

@end

NS_ASSUME_NONNULL_END
