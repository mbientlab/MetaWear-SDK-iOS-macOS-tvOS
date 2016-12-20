/**
 * MBLLED.h
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
#import <MetaWear/MBLModule.h>
#import <Bolts/Bolts.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Specific color channel for the LED
 */
typedef NS_ENUM(uint8_t, MBLLEDColorChannel) {
    MBLLEDColorChannelGreen = 0,
    MBLLEDColorChannelRed = 1,
    MBLLEDColorChannelBlue = 2
};

/**
 Interface to on-board LED
 */
@interface MBLLED : MBLModule

/**
 Display a specific color on the LED
 @param color Which color the LED should be
 @param intensity Scale from 0-1.0 on how bright the LED should be
 */
- (BFTask *)setLEDColorAsync:(MBLColor *)color withIntensity:(CGFloat)intensity;

/**
 Flash a specific color on the LED
 @param color Which color the LED should flash
 @param intensity Scale from 0-1.0 on how bright the LED should be
 */
- (BFTask *)flashLEDColorAsync:(MBLColor *)color withIntensity:(CGFloat)intensity;

/**
 Flash a specific color on the LED
 @param color Which color the LED should flash
 @param intensity Scale from 0-1.0 on how bright the LED should be
 @param numberOfFlashes Number of times LED will flash before turning off
 */
- (BFTask *)flashLEDColorAsync:(MBLColor *)color withIntensity:(CGFloat)intensity numberOfFlashes:(uint8_t)numberOfFlashes;

/**
 Flash a specific color on the LED
 @param color Which color the LED should flash
 @param intensity Scale from 0-1.0 on how bright the LED should be
 @param otime Time in mSec LED spends on
 @param period Flash period lenght in mSec
 */
- (BFTask *)flashLEDColorAsync:(MBLColor *)color withIntensity:(CGFloat)intensity onTime:(uint16_t)otime andPeriod:(uint16_t)period;

/**
 Flash a specific color on the LED
 @param color Which color the LED should flash
 @param intensity Scale from 0-1.0 on how bright the LED should be
 @param otime Time in mSec LED spends on
 @param period Flash period lenght in mSec
 @param numberOfFlashes Number of times LED will flash before turning off
 */
- (BFTask *)flashLEDColorAsync:(MBLColor *)color withIntensity:(CGFloat)intensity onTime:(uint16_t)otime period:(uint16_t)period numberOfFlashes:(uint8_t)numberOfFlashes;
    

#pragma mark - Advanced Settings
// These are typically not needed, see the simpler APIs above

/**
 Program one color channel of the LED, there are 3 total (red, blue, green).
 Each one is programmed individually and then the whole LED is enabled by a
 called to setLEDOn:withOptions:
 @param channel Color channel being configured
 @param onint ON Intensity (0-31)
 @param ofint OFF Intensity (0-31)
 @param rtime Time Rise (used for Flash mode only)
 @param ftime Time Fall (used for Flash mode only)
 @param otime Time On
 @param period Time Period
 @param offset Time Offset
 @param repeat Repeat Count (0-254, 255: Forever)
 */
- (BFTask *)setLEDModeWithColorChannelAsync:(MBLLEDColorChannel)channel
                                onIntensity:(uint8_t)onint
                               offIntensity:(uint8_t)ofint
                                   riseTime:(uint16_t)rtime
                                   fallTime:(uint16_t)ftime
                                     onTime:(uint16_t)otime
                                     period:(uint16_t)period
                                     offset:(uint16_t)offset
                                repeatCount:(uint8_t)repeat;

/**
 Change global LED state.
 @param on YES turns LED on, NO, turns LED off
 @param mode If on == YES then (0: pause, 1: play),
 if on == NO then (0: Stop, 1: Stop and reset channels)
 */
- (BFTask *)setLEDOnAsync:(BOOL)on withOptions:(uint8_t)mode;

/**
 Certain hardware has additional modes for advanced features
 @param data Bytes to write to the secondary mode register
 */
- (BFTask *)writeSecondaryMode:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
