/**
 * MBLiBeacon.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 8/3/14.
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

#import "MBLiBeacon.h"
#import "MBLMetaWear+Private.h"
#import "MBLRegister+Private.h"
#import "MBLFormat.h"
#import "MBLNumericFormatter.h"
#import "MBLConstants+Private.h"

@interface MBLiBeacon()
@property (nonatomic) MBLRegister *iBeaconEnable;
@property (nonatomic) MBLRegister *uuidRegister;
@property (nonatomic) MBLRegister *majorRegister;
@property (nonatomic) MBLRegister *minorRegister;
@property (nonatomic) MBLRegister *powerRxRegister;
@property (nonatomic) MBLRegister *powerTxRegister;
@property (nonatomic) MBLRegister *frequencyRegister;


// Setting the following properties causes side effects, so we
// create an internal property for storing the actual value, allowing
// us to safely get/set during serialization of this class
@property (nonatomic) CBUUID *uuidImpl;
@property (nonatomic) uint16_t majorImpl;
@property (nonatomic) uint16_t minorImpl;
@property (nonatomic) int8_t calibratedReceiverPowerImpl;
@property (nonatomic) MBLiBeaconTransmitPower transmitPowerImpl;
@property (nonatomic) uint16_t frequencyImpl;
@end

@implementation MBLiBeacon

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        self.uuidImpl = [MBLConstants serviceUUID];
        self.majorImpl = 0x0;
        self.minorImpl = 0x0;
        self.calibratedReceiverPowerImpl = -55;
        self.transmitPowerImpl = MBLiBeaconTransmitPower0dBm;
        self.frequencyImpl = 100;
        
        self.iBeaconEnable = [[MBLRegister alloc] initWithModule:self registerId:0x1 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
        self.uuidRegister = [[MBLRegister alloc] initWithModule:self registerId:0x2 format:[[MBLFormat alloc] initEncodedDataWithLength:16]];
        self.majorRegister = [[MBLRegister alloc] initWithModule:self registerId:0x3 format:[[MBLFormat alloc] initEncodedDataWithLength:2]];
        self.minorRegister = [[MBLRegister alloc] initWithModule:self registerId:0x4 format:[[MBLFormat alloc] initEncodedDataWithLength:2]];
        self.powerRxRegister = [[MBLRegister alloc] initWithModule:self registerId:0x5 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:YES]];
        self.powerTxRegister = [[MBLRegister alloc] initWithModule:self registerId:0x6 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:YES]];
        self.frequencyRegister = [[MBLRegister alloc] initWithModule:self registerId:0x7 format:[[MBLNumericFormatter alloc] initIntWithLength:2 isSigned:NO]];
	}
    return self;
}

- (CBUUID *)uuid
{
    return self.uuidImpl;
}

- (BFTask *)setUuid:(CBUUID *)uuid
{
    self.uuidImpl = uuid;
    
    NSData *bigEndianUUID = self.uuid.data;
    NSMutableData *littleEndianUUID = [NSMutableData dataWithCapacity:bigEndianUUID.length];
    const uint8_t *ptr = bigEndianUUID.bytes + bigEndianUUID.length - 1;
    for (int i = 0; i < bigEndianUUID.length; i++, ptr--) {
        [littleEndianUUID appendBytes:ptr length:1];
    }
    return [self.uuidRegister writeDataAsync:littleEndianUUID];
}

- (uint16_t)major
{
    return self.majorImpl;
}

- (BFTask *)setMajor:(uint16_t)major
{
    self.majorImpl = major;
    return [self.majorRegister writeDataAsync:[NSData dataWithBytes:&major length:2]];
}

- (uint16_t)minor
{
    return self.minorImpl;
}

- (BFTask *)setMinor:(uint16_t)minor
{
    self.minorImpl = minor;
    return [self.minorRegister writeDataAsync:[NSData dataWithBytes:&minor length:2]];
}

- (int8_t)calibratedReceiverPower
{
    return self.calibratedReceiverPowerImpl;
}

- (BFTask *)setCalibratedReceiverPower:(int8_t)calibratedReceiverPower
{
    if (calibratedReceiverPower > -10) {
        [NSException raise:@"Invalid calibratedReceiverPower value"
                    format:@"power of %d is invalid, valid range is [-10, -128]", calibratedReceiverPower];
    }
    self.calibratedReceiverPowerImpl = calibratedReceiverPower;
    return [self.powerRxRegister writeByteAsync:calibratedReceiverPower];
}

- (MBLiBeaconTransmitPower)transmitPower
{
    return self.transmitPowerImpl;
}

- (BFTask *)setTransmitPower:(MBLiBeaconTransmitPower)transmitPower
{
    self.transmitPowerImpl = transmitPower;
    return [self.powerTxRegister writeByteAsync:[self integerTransmitPower]];
}

- (int8_t)integerTransmitPower
{
    switch (self.transmitPowerImpl) {
        case MBLiBeaconTransmitPower4dBm:
            return 4;
        case MBLiBeaconTransmitPower0dBm:
            return 0;
        case MBLiBeaconTransmitPowerMinus4dBm:
            return -4;
        case MBLiBeaconTransmitPowerMinus8dBm:
            return -8;
        case MBLiBeaconTransmitPowerMinus12dBm:
            return -12;
        case MBLiBeaconTransmitPowerMinus16dBm:
            return -16;
        case MBLiBeaconTransmitPowerMinus20dBm:
            return -20;
        case MBLiBeaconTransmitPowerMinus30dBm:
            return -30;
        case MBLiBeaconTransmitPowerMinus40dBm:
            return -40;
    }
}

- (uint16_t)frequency
{
    return self.frequencyImpl;
}

- (BFTask *)setFrequency:(uint16_t)frequency
{
    if (frequency > 10240 || frequency < 20) {
        [NSException raise:@"Invalid frequency value"
                    format:@"frequency of %d is invalid, valid range is [20, 10,240]", frequency];
    }
    self.frequencyImpl = frequency;
    return [self.frequencyRegister writeDataAsync:[NSData dataWithBytes:&frequency length:2]];
}

- (BFTask *)setBeaconOnAsync:(BOOL)on
{
    return [self.iBeaconEnable writeByteAsync:on ? 0x1 : 0x0];
}

@end
