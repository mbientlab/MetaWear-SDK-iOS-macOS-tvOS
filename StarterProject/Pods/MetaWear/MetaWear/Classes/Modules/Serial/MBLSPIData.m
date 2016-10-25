/**
 * MBLSPIData.m
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
#import "MBLSPIData+Private.h"
#import "MBLRegister+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLNumericFormatter.h"
#import "MBLMetaWearManager+Private.h"
#import "MBLDeviceInfo.h"

static const uint8_t MW_SPI_WRITE_DATA_SIZE = 13;
static const uint8_t MW_SPI_READ_DATA_SIZE = 12;

typedef struct __attribute__((packed)) {
    uint8_t        pin_ss;
    uint8_t        pin_sck;
    uint8_t        pin_mosi;
    uint8_t        pin_miso;
    union {
        struct __attribute__((packed)) {
            uint8_t    lsb_first:1;
            uint8_t    mode:2;
            uint8_t    freq:3;
            uint8_t    native_pin_indexing:1;
            uint8_t    :1;
        };
        uint8_t      mode_byte;
    };
    union {
        struct __attribute__((packed)) {
            uint8_t    readlen:4;
            uint8_t    index:4;
            uint8_t    readwritedata[MW_SPI_READ_DATA_SIZE];
        };
        uint8_t      writedata[MW_SPI_WRITE_DATA_SIZE];
    };
} mw_spi_passthru_cmd_t;


@interface MBLSPIData ()
@property (nonatomic) uint8_t slaveSelectPin;
@property (nonatomic) uint8_t clockPin;
@property (nonatomic) uint8_t mosiPin;
@property (nonatomic) uint8_t misoPin;
@property (nonatomic) uint8_t lsbFirst;
@property (nonatomic) uint8_t spiMode;
@property (nonatomic) uint8_t spiFrequency;
@property (nonatomic) uint8_t nativePinIndexing;
@property (nonatomic) NSData *pendingReadParams;
@end

@implementation MBLSPIData

- (instancetype)initWithRegister:(MBLRegister *)reg
                  slaveSelectPin:(uint8_t)slaveSelectPin
                        clockPin:(uint8_t)clockPin
                         mosiPin:(uint8_t)mosiPin
                         misoPin:(uint8_t)misoPin
                        lsbFirst:(BOOL)lsbFirst
                         spiMode:(uint8_t)spiMode
                    spiFrequency:(uint8_t)spiFrequency
               nativePinIndexing:(BOOL)nativePinIndexing
                          length:(uint8_t)length
{
    self = [super initWithModule:reg.module registerId:reg.registerId format:[[MBLFormat alloc] initEncodedDataWithLength:length]];
    if (self) {
        self.slaveSelectPin = slaveSelectPin;
        self.clockPin = clockPin;
        self.mosiPin = mosiPin;
        self.misoPin = misoPin;
        self.lsbFirst = lsbFirst;
        self.spiMode = spiMode;
        self.spiFrequency = spiFrequency;
        self.nativePinIndexing = nativePinIndexing;
    }
    return self;
}

- (instancetype)initNumberWithRegister:(MBLRegister *)reg
                        slaveSelectPin:(uint8_t)slaveSelectPin
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
    self = [super initWithModule:reg.module registerId:reg.registerId format:[[MBLNumericFormatter alloc] initIntWithLength:length isSigned:isSigned]];
    if (self) {
        self.slaveSelectPin = slaveSelectPin;
        self.clockPin = clockPin;
        self.mosiPin = mosiPin;
        self.misoPin = misoPin;
        self.lsbFirst = lsbFirst;
        self.spiMode = spiMode;
        self.spiFrequency = spiFrequency;
        self.nativePinIndexing = nativePinIndexing;
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

- (BFTask *)readAsync
{
    if (!self.module) {
        return [BFTask taskWithError:[NSError errorWithDomain:kMBLErrorDomain
                                                         code:kMBLErrorOperationInvalid
                                                     userInfo:@{NSLocalizedDescriptionKey : @"SPI reads not supported, please update firmware."}]];
    }
    return [super readAsync];
}

- (BFTask *)readWithParamtersAsync:(NSData *)data
{
    if (!self.module) {
        return [BFTask taskWithError:[NSError errorWithDomain:kMBLErrorDomain
                                                         code:kMBLErrorOperationInvalid
                                                     userInfo:@{NSLocalizedDescriptionKey : @"SPI reads not supported, please update firmware."}]];
    }
    self.pendingReadParams = data;
    return [self readAsync];
}

- (NSData *)readParameters
{
    mw_spi_passthru_cmd_t params = { 0 };
    params.pin_ss = self.slaveSelectPin;
    params.pin_sck = self.clockPin;
    params.pin_mosi = self.mosiPin;
    params.pin_miso = self.misoPin;
    params.lsb_first = self.lsbFirst;
    params.mode = self.spiMode;
    params.freq = self.spiFrequency;
    params.native_pin_indexing = self.nativePinIndexing;

    params.readlen = self.format.length - 1;
    assert(self.index != 0xFF);
    params.index = self.index;

    NSInteger size = MIN(self.pendingReadParams.length, MW_SPI_READ_DATA_SIZE);
    memcpy(params.readwritedata, self.pendingReadParams.bytes, size);
    
    return [NSData dataWithBytes:&params length:size + 6];
}

- (BFTask *)writeDataAsync:(nullable NSData *)data
{
    if (!self.module) {
        return [BFTask taskWithError:[NSError errorWithDomain:kMBLErrorDomain
                                                         code:kMBLErrorOperationInvalid
                                                     userInfo:@{NSLocalizedDescriptionKey : @"SPI reads not supported, please update firmware."}]];
    }
    
    mw_spi_passthru_cmd_t params = { 0 };
    params.pin_ss = self.slaveSelectPin;
    params.pin_sck = self.clockPin;
    params.pin_mosi = self.mosiPin;
    params.pin_miso = self.misoPin;
    params.lsb_first = self.lsbFirst;
    params.mode = self.spiMode;
    params.freq = self.spiFrequency;
    params.native_pin_indexing = self.nativePinIndexing;

    NSInteger size = MIN(data.length, MW_SPI_WRITE_DATA_SIZE);
    memcpy(params.writedata, data.bytes, size);
    
    return [super writeDataAsync:[NSData dataWithBytes:&params length:size + 5]];
}

- (BFTask *)writeByteAsync:(uint8_t)byte
{
    return [self writeDataAsync:[NSData dataWithBytes:&byte length:1]];
}

- (BFTask *)writeWordAsync:(uint16_t)word
{
    return [self writeDataAsync:[NSData dataWithBytes:&word length:2]];
}

- (BFTask *)writeDwordAsync:(uint32_t)dword
{
    return [self writeDataAsync:[NSData dataWithBytes:&dword length:4]];
}

@end
