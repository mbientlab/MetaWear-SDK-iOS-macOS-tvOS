/**
 * MBLSerial.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 1/20/15.
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

#import "MBLSerial+Private.h"
#import "MBLModule+Private.h"
#import "MBLRegister+Private.h"
#import "MBLI2CData+Private.h"
#import "MBLSPIData+Private.h"
#import "MBLMetaWearManager+Private.h"
#import "BFTask+Private.h"


@interface MBLSerial ()
@property (nonatomic) MBLRegister *twiReadWrite;
@property (nonatomic) MBLRegister *spiReadWrite;

@property (nonatomic) NSMutableArray *regs;
@end

@implementation MBLSerial

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        self.twiReadWrite = [[MBLRegister alloc] initWithModule:self registerId:0x1 format:[[MBLFormat alloc] initEncodedDataWithLength:18]];
        if (moduleInfo.moduleRevision >= 1) {
            self.spiReadWrite = [[MBLRegister alloc] initWithModule:self registerId:0x2 format:[[MBLFormat alloc] initEncodedDataWithLength:18]];
        }
        self.regs = [NSMutableArray array];
    }
    return self;
}

- (BFTask *)performAsyncInitializationForRegister:(MBLRegister *)reg
{
    return [BFTask taskFromMetaWearWithBlock:^id _Nonnull{
        assert(reg.index == 0xFF);
        reg.index = self.regs.count;
        [self.regs addObject:reg];
        return nil;
    }];
}

- (BFTask *)performAsyncDeinitializationForRegister:(MBLRegister *)reg
{
    return [BFTask taskFromMetaWearWithBlock:^id _Nonnull{
        assert(reg.index != 0xFF);
        [self.regs removeObject:reg];
        reg.index = 0xFF;
        return nil;
    }];
}

- (MBLI2CData *)dataAtDeviceAddress:(uint8_t)deviceAddress
                    registerAddress:(uint8_t)registerAddress
                             length:(uint8_t)length
{
    return [[MBLI2CData alloc] initWithRegister:self.twiReadWrite
                                  deviceAddress:deviceAddress
                                registerAddress:registerAddress
                                         length:length];
}

- (MBLI2CData *)numberAtDeviceAddress:(uint8_t)deviceAddress
                      registerAddress:(uint8_t)registerAddress
                               length:(uint8_t)length
                             isSigned:(BOOL)isSigned
{
    return [[MBLI2CData alloc] initNumberWithRegister:self.twiReadWrite
                                        deviceAddress:deviceAddress
                                      registerAddress:registerAddress
                                               length:length
                                             isSigned:isSigned];
}


- (MBLSPIData *)dataWithSlaveSelectPin:(uint8_t)slaveSelectPin
                              clockPin:(uint8_t)clockPin
                               mosiPin:(uint8_t)mosiPin
                               misoPin:(uint8_t)misoPin
                              lsbFirst:(BOOL)lsbFirst
                               spiMode:(uint8_t)spiMode
                          spiFrequency:(uint8_t)spiFrequency
                     nativePinIndexing:(BOOL)nativePinIndexing
                                length:(uint8_t)length
{
    return [[MBLSPIData alloc] initWithRegister:self.spiReadWrite
                                 slaveSelectPin:slaveSelectPin
                                       clockPin:clockPin
                                        mosiPin:mosiPin
                                        misoPin:misoPin
                                       lsbFirst:lsbFirst
                                        spiMode:spiMode
                                   spiFrequency:spiFrequency
                              nativePinIndexing:nativePinIndexing
                                         length:(uint8_t)length];
}

- (MBLSPIData *)numberWithSlaveSelectPin:(uint8_t)slaveSelectPin
                                clockPin:(uint8_t)clockPin
                                 mosiPin:(uint8_t)mosiPin
                                 misoPin:(uint8_t)misoPin
                                lsbFirst:(BOOL)lsbFirst
                                 spiMode:(uint8_t)spiMode
                            spiFrequency:(uint8_t)spiFrequency
                       nativePinIndexing:(BOOL)nativePinIndexing
                                  length:(uint8_t)length
                                isSigned:(BOOL)isSigned
{
    return [[MBLSPIData alloc] initNumberWithRegister:self.spiReadWrite
                                       slaveSelectPin:slaveSelectPin
                                             clockPin:clockPin
                                              mosiPin:mosiPin
                                              misoPin:misoPin
                                             lsbFirst:lsbFirst
                                              spiMode:spiMode
                                         spiFrequency:spiFrequency
                                    nativePinIndexing:nativePinIndexing
                                               length:length
                                             isSigned:isSigned];
}

@end
