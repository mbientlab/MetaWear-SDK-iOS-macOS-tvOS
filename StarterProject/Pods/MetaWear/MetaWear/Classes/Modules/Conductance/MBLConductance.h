/**
 * MBLConductance.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 4/16/15.
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

#import <MetaWear/MBLModule.h>
#import "Bolts/Bolts.h"
@class MBLNumericData;
@class MBLData<ResultType>;

NS_ASSUME_NONNULL_BEGIN

/**
 Gain applied in the Conductance circuit
 */
typedef NS_ENUM(uint8_t, MBLConductanceGain) {
    MBLConductanceGain499K = 0,
    MBLConductanceGain1M = 1
};

/**
 Constant voltage applied on the Conductance electrodes
 */
typedef NS_ENUM(uint8_t, MBLConductanceVoltage) {
    MBLConductanceVoltage500mV = 1,
    MBLConductanceVoltage250mV = 0
};

/**
 Valid measurment range voltage on the Conductance electrodes
 */
typedef NS_ENUM(uint8_t, MBLConductanceRange) {
    MBLConductanceRange50uS = 0,
    MBLConductanceRange100uS = 1,
    MBLConductanceRange150uS = 2,
    MBLConductanceRange200uS = 3
};

/**
 Interface to on-board Conductance sensor
 */
@interface MBLConductance : MBLModule

/**
 Gain applied in the Conductance circuit 
 @note Not avaliable in all implementations
 */
@property (nonatomic) MBLConductanceGain gain;
/**
 Constant voltage applied on the Conductance electrodes
 @note Not avaliable in all implementations
 */
@property (nonatomic) MBLConductanceVoltage voltage;
/**
 Valid measurment range voltage on the Conductance electrodes
 @note Not avaliable in all implementations
 */
@property (nonatomic) MBLConductanceRange range;


/**
 Array of MBLData objects. The index corresponds to the Conductance channel
 number, for example, channels[0] returns an MBLData corresponding
 to channel 0, which can be used for perfoming single channel reads.
 Callbacks will be provided an MBLNumericData object whose uint32_t value
 will be conductance in nS.
 */
@property (nonatomic, readonly) NSArray<MBLData<MBLNumericData *> *> *channels;

/**
 Perform automatic Conductance calibration.  This should be called when
 temperature changes, or it can just be called periodically as it's low overhead.
 */
- (BFTask *)calibrateAsync;

@end

NS_ASSUME_NONNULL_END
