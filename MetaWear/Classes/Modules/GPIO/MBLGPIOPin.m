/**
 * MBLGPIOPin.m
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

#import "MBLGPIOPin+Private.h"
#import "MBLEvent+Private.h"
#import "MBLGPIO+Private.h"
#import "MBLGPIOPinChangeEvent.h"
#import "MBLGPIOData.h"
#import "MBLMetaWear+Private.h"
#import "MBLDeviceInfo.h"
#import "MBLNumericFormatter.h"


@interface MBLGPIOPin ()
@property (nonatomic) MBLEvent *changeEvent;
@property (nonatomic) MBLData *digitalValue;
@property (nonatomic) MBLData *analogAbsolute;
@property (nonatomic) MBLData *analogRatio;

@property (nonatomic, weak) MBLGPIO *gpio;
@property (nonatomic) uint8_t pin;

// Setting the configuration property causes side effects, so we
// create an internal property for storing the actual value, allowing
// us to safely get/set during serialization of this class
@property (nonatomic) MBLPinConfiguration configurationImpl;
@end

@implementation MBLGPIOPin

- (instancetype)initWithModule:(MBLGPIO *)gpio pin:(uint8_t)pin featureByte:(uint8_t)featureByte
{
    self = [super init];
    if (self) {
        self.gpio = gpio;
        self.pin = pin;
        
        if (featureByte & 0x1) {
            self.changeEvent = [[MBLGPIOPinChangeEvent alloc] initWithModule:gpio pin:pin];
            self.digitalValue = [[MBLGPIOData alloc] initWithRegister:gpio.readDigital pin:self format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO] identifier:[NSString stringWithFormat:@"digital[%d]", pin]];
        }
        if (featureByte & 0x2) {
            self.analogAbsolute = [[MBLGPIOData alloc] initWithRegister:gpio.readAnalogAbsolute pin:self format:[[MBLNumericFormatter alloc] initDoubleWithLength:2 isSigned:NO scale:1.0 / 1000.0] identifier:[NSString stringWithFormat:@"abs-ref[%d]", pin]];
            self.analogRatio = [[MBLGPIOData alloc] initWithRegister:gpio.readAnalogRatio pin:self format:[[MBLNumericFormatter alloc] initDoubleWithLength:2 isSigned:NO scale:1.0 / 1023.0] identifier:[NSString stringWithFormat:@"adc[%d]", pin]];
        }
        
        self.changeType = MBLPinChangeTypeRising;
        self.configurationImpl = MBLPinConfigurationNopull;
    }
    return self;
}

- (MBLPinConfiguration)configuration
{
    return self.configurationImpl;
}

- (BFTask *)setConfiguration:(MBLPinConfiguration)configuration
{
    self.configurationImpl = configuration;
    return [self.gpio configurePin:self.pin type:configuration];
}

- (void)setChangeType:(MBLPinChangeType)changeType
{
    [(MBLGPIOPinChangeEvent *)self.changeEvent setChangeType:changeType];
    _changeType = changeType;
}

- (nonnull BFTask *)setToDigitalValueAsync:(BOOL)on
{
    return [self.gpio setPin:self.pin toDigitalValue:on];
}

- (MBLData *)analogRatioWithPullUp:(NSNumber *)pullUp
                          pullDown:(NSNumber *)pullDown
                         readDelay:(uint16_t)readDelay
{
    if (self.gpio.moduleInfo.moduleRevision < 2) {
        [NSException raise:kMBLErrorDomain format:@"GPIO[WARNING] - Please update to latest firmware in order to use analogRatioWithPullUp."];
    }
    return [[MBLGPIOData alloc] initWithRegister:self.gpio.readAnalogRatio
                                             pin:self
                                          format:[[MBLNumericFormatter alloc] initDoubleWithLength:2 isSigned:NO scale:1.0 / 1023.0]
                                          pullUp:pullUp
                                        pullDown:pullDown
                                       readDelay:readDelay
                                      identifier:[NSString stringWithFormat:@"adc[%d]", self.pin]];
}

- (MBLData *)analogAbsoluteWithPullUp:(NSNumber *)pullUp
                             pullDown:(NSNumber *)pullDown
                            readDelay:(uint16_t)readDelay
{
    if (self.gpio.moduleInfo.moduleRevision < 2) {
        [NSException raise:kMBLErrorDomain format:@"GPIO[WARNING] - Please update to latest firmware in order to use analogAbsoluteWithPullUp."];
    }
    return [[MBLGPIOData alloc] initWithRegister:self.gpio.readAnalogAbsolute
                                             pin:self
                                          format:[[MBLNumericFormatter alloc] initDoubleWithLength:2 isSigned:NO scale:1.0 / 1000.0]
                                          pullUp:pullUp
                                        pullDown:pullDown
                                       readDelay:readDelay
                                      identifier:[NSString stringWithFormat:@"abs-ref[%d]", self.pin]];
}

@end
