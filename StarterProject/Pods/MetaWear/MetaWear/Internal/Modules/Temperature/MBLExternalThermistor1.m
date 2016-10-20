/**
 * MBLExternalThermistor1.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 7/14/15.
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

#import "MBLExternalThermistor1.h"
#import "MBLTemperature+Private.h"
#import "MBLNumericFormatter.h"
#import "MBLData+Private.h"
#import "MBLFormat.h"

typedef struct __attribute__((packed)) {
    uint8_t         index;
    uint8_t			gpio_analog_pin;
    uint8_t			gpio_enable_pin;
    uint8_t         gpio_enable_active_high;
} mw_temp_therm1_mode_t;

static const double DEGREES_CELSIUS_PER_UNIT = 0.125;

@interface MBLExternalThermistor1 ()
@property (nonatomic) MBLRegister *mode;
@end

@implementation MBLExternalThermistor1

- (instancetype)initWithTemperature:(MBLTemperature *)temperature index:(uint8_t)index
{
    self = [super initWithModule:temperature registerId:0x1 index:index format:[[MBLNumericFormatter alloc] initDoubleWithLength:2 isSigned:YES scale:DEGREES_CELSIUS_PER_UNIT]];
    if (self) {
        self.mode = [[MBLRegister alloc] initWithModule:temperature registerId:0x2 index:index format:[[MBLFormat alloc] initEncodedDataWithLength:3]];
        self.readPin = 0xFF;
        self.enablePin = 0xFF;
        self.enablePinActiveLow = YES;
    }
    return self;
}

- (BFTask *)performAsyncInitialization
{
    if (self.readPin == 0xFF || self.enablePin == 0xFF ||
        (self.readPin == self.enablePin)) {
        [NSException raise:@"Invalid thermistor values"
                    format:@"Set readPin and enablePin to valid values"];
    }
    
    mw_temp_therm1_mode_t regs;
    regs.index = self.index;
    regs.gpio_analog_pin = self.readPin;
    regs.gpio_enable_pin = self.enablePin;
    regs.gpio_enable_active_high = self.enablePinActiveLow ? 0 : 1;
    return [self.mode writeDataAsync:[NSData dataWithBytes:&regs length:sizeof(mw_temp_therm1_mode_t)]];
}

@end
