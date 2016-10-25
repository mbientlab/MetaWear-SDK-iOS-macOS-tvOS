/**
 * MBLTemperatureV0.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 8/24/15.
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

#import "MBLTemperatureV0.h"
#import "MBLRegister+Private.h"
#import "MBLEvent+Private.h"
#import "MBLNumericData+Private.h"
#import "MBLDeviceInfo.h"
#import "MBLNumericFormatter.h"
#import "MBLData+Private.h"
#import "MBLOnDieTemperature0.h"
#import "MBLExternalThermistor0.h"


typedef struct __attribute__((packed)) {
    uint8_t			enable;
    uint8_t			gpio_analog_pin;
    uint8_t			gpio_pulldown_pin;
} mw_temp_therm_mode_t;


@implementation MBLTemperatureV0

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        self.source = MBLTemperatureSourceInternal;
        self.thermistorReadPin = 0xFF;
        self.thermistorEnablePin = 0xFF;
        
        self.thermistorSettings = [[MBLRegister alloc] initWithModule:self registerId:0x5 format:[[MBLFormat alloc] initEncodedDataWithLength:3]];
        
        self.onDieThermistor = [[MBLOnDieTemperature0 alloc] initWithTemperature:self];
        self.externalThermistor = [[MBLExternalThermistor0 alloc] initWithTemperature:self];
        self.onboardThermistor = nil;
        self.channels = @[self.onDieThermistor, self.externalThermistor];
    }
    return self;
}

- (BFTask *)performAsyncActivation
{
    if (self.source == MBLTemperatureSourceThermistor) {
        if (self.thermistorReadPin == 0xFF || self.thermistorEnablePin == 0xFF ||
            (self.thermistorReadPin == self.thermistorEnablePin)) {
            [NSException raise:@"Invalid thermistor values"
                        format:@"Set thermistorReadPin and thermistorEnablePin to valid values"];
        }
    }
    
    mw_temp_therm_mode_t thermRegs;
    thermRegs.enable = self.source == MBLTemperatureSourceThermistor;
    thermRegs.gpio_analog_pin = self.thermistorReadPin;
    thermRegs.gpio_pulldown_pin = self.thermistorEnablePin;
    return [self.thermistorSettings writeDataAsync:[NSData dataWithBytes:&thermRegs length:sizeof(mw_temp_therm_mode_t)]];
}

- (BFTask *)performAsyncDeactivation
{
    mw_temp_therm_mode_t thermRegs = { 0 };
    return [self.thermistorSettings writeDataAsync:[NSData dataWithBytes:&thermRegs length:sizeof(mw_temp_therm_mode_t)]];
}

@end
