/**
 * MBLProximityTSL2671.h
 * MetaWear
 *
 * Created by Stephen Schiffli on 2/22/16.
 * Copyright 2016 MbientLab Inc. All rights reserved.
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

#import <MetaWear/MBLProximity.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Drive current applied to transmitter
 */
typedef NS_ENUM(uint8_t, MBLProximityTSL2671TransmitterDrive) {
    MBLProximityTSL2671TransmitterDrive25mA = 2,    // Default
    MBLProximityTSL2671TransmitterDrive12_5mA = 3
};

/**
 Interface to a TCS3472 RGB light sensor.
 The following properties affect the range that the proximity sensor outputs.
 The defaults provided are good for detecting objects within several inches.  You
 will need more proximityPulses and integrationTime if you want to detect objects
 further away.
 */
@interface MBLProximityTSL2671 : MBLProximity

/**
 The measurement time in ms for each proximity sensor cycle. Valid range is [2.72-696.32], 2.72 default.
 */
@property (nonatomic) double integrationTime;
/**
 Number of light pulses to transmit during measurement. <32 recommended, 1 Default.
 */
@property (nonatomic) uint8_t proximityPulses;
/**
 Drive current applied to transmitter
 */
@property (nonatomic) MBLProximityTSL2671TransmitterDrive drive;

@end

NS_ASSUME_NONNULL_END
