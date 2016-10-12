/**
 * MBLGyroBMI160DataReadyEvent.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 5/26/15.
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


#import "MBLGyroBMI160DataReadyEvent.h"
#import "MBLGyro+Private.h"
#import "MBLGyroBMI160+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLRegister+Private.h"
#import "MBLNumericFormatter.h"
#import "MBLGyroBMI160Format.h"
#import "MBLGyroBMI160PackedDataReadyEvent.h"

typedef NS_ENUM(uint8_t, MBLGyroPackedDataMode) {
    MBLGyroPackedDataModeOff = 0,
    MBLGyroPackedDataModeNormal = 1,
    MBLGyroPackedDataModePacked = 2
};

@interface MBLGyroBMI160DataReadyEvent ()
@property (nonatomic) MBLGyroPackedDataMode packerMode;
@property (nonatomic) MBLGyroBMI160PackedDataReadyEvent *packedData;
@end

@implementation MBLGyroBMI160DataReadyEvent

- (instancetype)initWithGyro:(MBLGyroBMI160 *)gyro
{
    self = [super initWithModule:gyro registerId:0x5 format:[[MBLGyroBMI160Format alloc] initWithGyro:gyro packed:NO]];
    if (self) {
        self.dataInterruptEn = [[MBLRegister alloc] initWithModule:gyro registerId:0x2 format:[[MBLFormat alloc] initEncodedDataWithLength:1]];
        if (gyro.moduleInfo.moduleRevision >= 1) {
            self.packedData = [[MBLGyroBMI160PackedDataReadyEvent alloc] initWithGyro:gyro];
        }
    }
    return self;
}

- (BFTask *)performAsyncActivation
{
    // Now enable interrupts
    uint8_t data[] = { 0x1, 0x0 };
    return [self.dataInterruptEn writeDataAsync:[NSData dataWithBytes:&data length:2]];
}

- (BFTask *)performAsyncDeactivation
{
    // Disable interrupts
    uint8_t data[] = { 0x0, 0x1 };
    return [self.dataInterruptEn writeDataAsync:[NSData dataWithBytes:&data length:2]];
}

- (BFTask *)startNotificationsWithHandlerAsync:(MBLObjectHandler)handler
{
    if (!self.packedData) {
        return [super startNotificationsWithHandlerAsync:handler];
    }
    
    MBLGyroBMI160 *gyro = (MBLGyroBMI160 *)self.module;
    if (self.packerMode == MBLGyroPackedDataModeOff) {
        // Turn on the packer for frequencies over 100
        self.packerMode = gyro.sampleFrequency >= 100 ? MBLGyroPackedDataModePacked : MBLGyroPackedDataModeNormal;
    }
    return self.packerMode == MBLGyroPackedDataModePacked ? [self.packedData startNotificationsWithHandlerAsync:handler]
                                                          : [super startNotificationsWithHandlerAsync:handler];
}

- (BFTask *)stopNotificationsAsync
{
    if (!self.packedData) {
        return [super stopNotificationsAsync];
    }
    
    MBLGyroPackedDataMode prevMode = self.packerMode;
    self.packerMode = MBLGyroPackedDataModeOff;
    return prevMode == MBLGyroPackedDataModePacked ? [self.packedData stopNotificationsAsync]
                                                   : [super stopNotificationsAsync];
}

- (BOOL)isNotifying
{
    if (!self.packedData) {
        return [super isNotifying];
    }
    
    return self.packerMode == MBLGyroPackedDataModePacked ? [self.packedData isNotifying]
                                                          : [super isNotifying];
}


@end
