/**
 * MBLTemperatureV1.m
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

#import "MBLTemperatureV1.h"
#import "MBLRegister+Private.h"
#import "MBLEvent+Private.h"
#import "MBLNumericData+Private.h"
#import "MBLDeviceInfo.h"
#import "MBLNumericFormatter.h"
#import "MBLData+Private.h"
#import "MBLExternalThermistor1.h"

static const double DEGREES_CELSIUS_PER_UNIT = 0.125;

@implementation MBLTemperatureV1

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        self.source = MBLTemperatureSourceInternal;
        self.thermistorReadPin = 0xFF;
        self.thermistorEnablePin = 0xFF;
        
        uint8_t *bytes = (uint8_t *)moduleInfo.moduleData.bytes;
        NSMutableArray *channels = [NSMutableArray array];
        for (int i = 0; i < moduleInfo.moduleData.length; i++) {
            uint8_t driverId = bytes[i];
            NSObject *current = nil;
            switch (driverId) {
                case 0:
                    self.onDieThermistor = [[MBLData alloc] initWithModule:self registerId:0x1 index:i format:[[MBLNumericFormatter alloc] initDoubleWithLength:2 isSigned:YES scale:DEGREES_CELSIUS_PER_UNIT]];
                    current = self.onDieThermistor;
                    self.onDieThermistor.needsResponse = YES; // TODO: Remove once fixed
                    break;
                case 1:
                    self.externalThermistor = [[MBLExternalThermistor1 alloc] initWithTemperature:self index:i];
                    current = self.externalThermistor;
                    self.externalThermistor.needsResponse = YES; // TODO: Remove once fixed
                    break;
                case 2:
                    // TODO: Enable the BMP280 Temperature
                    break;
                case 3:
                    self.onboardThermistor = [[MBLData alloc] initWithModule:self registerId:0x1 index:i format:[[MBLNumericFormatter alloc] initDoubleWithLength:2 isSigned:YES scale:DEGREES_CELSIUS_PER_UNIT]];
                    current = self.onboardThermistor;
                    self.onboardThermistor.needsResponse = YES; // TODO: Remove once fixed
                    break;
                default:
                    NSAssert(NO, @"Unexpected temperature driver");
                    break;
            }
            if (current) {
                [channels addObject:current];
            }
        }
        self.channels = channels;
    }
    return self;
}

@end
