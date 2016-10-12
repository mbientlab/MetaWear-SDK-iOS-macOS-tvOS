/**
 * MBLI2CData.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 1/23/15.
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
#import "MBLI2CData+Private.h"
#import "MBLRegister+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLNumericFormatter.h"
#import "MBLMetaWearManager+Private.h"
#import "MBLDeviceInfo.h"
#import "MBLConstants+Private.h"

static const uint8_t MW_I2C_DATA_SIZE = 10;

typedef struct __attribute__((packed)) {
    uint8_t address;
    uint8_t	reg;
    uint8_t	index;
    uint8_t dataLength;
    uint8_t data[MW_I2C_DATA_SIZE];
} mw_i2c_passthru_cmd_t;


@interface MBLI2CData ()
@property (nonatomic) uint8_t deviceAddress;
@property (nonatomic) uint8_t registerAddress;
@end

@implementation MBLI2CData

- (instancetype)initWithRegister:(MBLRegister *)reg
                   deviceAddress:(uint8_t)deviceAddress
                 registerAddress:(uint8_t)registerAddress
                          length:(uint8_t)length
{
    self = [super initWithModule:reg.module registerId:reg.registerId format:[[MBLFormat alloc] initEncodedDataWithLength:length]];
    if (self) {
        self.deviceAddress = deviceAddress;
        self.registerAddress = registerAddress;
        
        NSString *curVersion = reg.module.device.deviceInfo.firmwareRevision;
        if ([MBLConstants versionString:curVersion isLessThan:@"1.1.0"]) {
            self.needsResponse = YES;
        }
    }
    return self;
}

- (instancetype)initNumberWithRegister:(MBLRegister *)reg
                         deviceAddress:(uint8_t)deviceAddress
                       registerAddress:(uint8_t)registerAddress
                                length:(uint8_t)length
                              isSigned:(BOOL)isSigned
{
    self = [super initWithModule:reg.module registerId:reg.registerId format:[[MBLNumericFormatter alloc] initIntWithLength:length isSigned:isSigned]];
    if (self) {
        self.deviceAddress = deviceAddress;
        self.registerAddress = registerAddress;
        
        NSString *curVersion = reg.module.device.deviceInfo.firmwareRevision;
        if ([MBLConstants versionString:curVersion isLessThan:@"1.1.0"]) {
            self.needsResponse = YES;
        }
    }
    return self;
}

- (BFTask *)performAsyncInitialization
{
    return [self.module.device.serial performAsyncInitializationForRegister:self];
}

- (BFTask *)performAsyncDeinitialization
{
    return [self.module.device.serial performAsyncDeinitializationForRegister:self];
}

- (NSData *)readParameters
{
    mw_i2c_passthru_cmd_t params = { 0 };
    params.address = self.deviceAddress;
    params.reg = self.registerAddress;
    assert(self.index != 0xFF);
    params.index = self.index;
    params.dataLength = self.format.length;
    
    return [NSData dataWithBytes:&params length:4];
}

- (nonnull BFTask *)writeDataAsync:(nullable NSData *)data
{
    mw_i2c_passthru_cmd_t params = { 0 };
    params.address = self.deviceAddress;
    params.reg = self.registerAddress;
    params.index = 0;
    params.dataLength = self.format.length;
    
    NSInteger size = MIN(data.length, MW_I2C_DATA_SIZE);
    memcpy(params.data, data.bytes, size);
    
    return [super writeDataAsync:[NSData dataWithBytes:&params length:size + 4]];
}

- (nonnull BFTask *)writeByteAsync:(uint8_t)byte
{
    return [self writeDataAsync:[NSData dataWithBytes:&byte length:1]];
}

- (nonnull BFTask *)writeWordAsync:(uint16_t)word
{
    return [self writeDataAsync:[NSData dataWithBytes:&word length:2]];
}

- (nonnull BFTask *)writeDwordAsync:(uint32_t)dword
{
    return [self writeDataAsync:[NSData dataWithBytes:&dword length:4]];
}

@end
