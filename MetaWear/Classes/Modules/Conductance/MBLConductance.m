/**
 * MBLConductance.m
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

#import "MBLConductance.h"
#import "MBLRegister+Private.h"
#import "MBLData+Private.h"
#import "MBLNumericFormatter.h"
#import "MBLConductanceData.h"
#import "MBLMetaWear+Private.h"

typedef struct __attribute__((packed)) {
    uint8_t count;
    uint8_t mode_length;
    int8_t  conductance_scale;
} conductance_module_info;

@interface MBLConductance()
@property (nonatomic) MBLRegister *conductance;
@property (nonatomic) MBLRegister *calibrateReg;
@property (nonatomic) MBLRegister *mode;

@property (nonatomic) NSArray *channels;
@end

@implementation MBLConductance

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        self.gain = MBLConductanceGain499K;
        self.voltage = MBLConductanceVoltage500mV;
        self.range = MBLConductanceRange100uS;
        
        self.conductance = [[MBLRegister alloc] initWithModule:self registerId:0x1 format:[[MBLFormat alloc] initEncodedDataWithLength:3]];
        self.calibrateReg = [[MBLRegister alloc] initWithModule:self registerId:0x2 format:[[MBLFormat alloc] initEncodedDataWithLength:0]];
        self.mode = [[MBLRegister alloc] initWithModule:self registerId:0x3 format:[[MBLFormat alloc] initEncodedDataWithLength:2]];
        
        if (moduleInfo.moduleImplementation >= 1) {
            assert(moduleInfo.moduleData.length == 3);
            conductance_module_info *info = (conductance_module_info *)moduleInfo.moduleData.bytes;
            
            NSMutableArray *channels = [[NSMutableArray alloc] initWithCapacity:info->count];
            for (uint8_t channel = 0; channel < info->count; channel++) {
                [channels addObject:[[MBLConductanceData alloc] initWithRegister:self.conductance channel:channel]];
            }
            self.channels = channels;
        } else {
            self.channels = @[[[MBLConductanceData alloc] initWithRegister:self.conductance channel:0],
                              [[MBLConductanceData alloc] initWithRegister:self.conductance channel:1],
                              [[MBLConductanceData alloc] initWithRegister:self.conductance channel:2],
                              [[MBLConductanceData alloc] initWithRegister:self.conductance channel:3]];
        }
    }
    return self;
}

- (BFTask *)performAsyncInitialization
{
    if (self.moduleInfo.moduleImplementation == 1) {
        uint8_t data[] = { self.voltage, self.gain };
        return [self.mode writeDataAsync:[NSData dataWithBytes:&data length:2]];
    } else if (self.moduleInfo.moduleImplementation == 2) {
        uint8_t data[] = { self.range };
        return [self.mode writeDataAsync:[NSData dataWithBytes:&data length:1]];
    } else if (self.moduleInfo.moduleImplementation == 3) {
        uint8_t data[] = { 1 }; // TODO: FIXME
        return [self.mode writeDataAsync:[NSData dataWithBytes:&data length:1]];
    }
    return [super performAsyncInitialization];
}

- (BFTask *)calibrateAsync
{
    return [self.calibrateReg writeDataAsync:nil];
}

@end
