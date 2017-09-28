/**
 * MBLBitmaskEvent.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 11/8/16.
 * Copyright 2016 MbientLab Inc. All rights reserved.
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

#import "MBLBitmaskEvent.h"
#import "BFTask+MBLPrivate.h"
#import "MBLSensorFusion+Private.h"
#import "MBLLogger.h"

@implementation MBLBitmaskEvent

- (instancetype)initWithModule:(MBLModule *)module
                    registerId:(uint8_t)registerId
                 enableBitmask:(uint8_t)enableBitmask
                enableRegister:(MBLRegister *)enableRegister
                        format:(MBLFormat *)format
                    identifier:(NSString *)identifier
{
    self = [super initWithModule:module registerId:registerId format:format identifier:identifier];
    if (self) {
        self.enableBitmask = enableBitmask;
        self.enableRegister = enableRegister;
    }
    return self;
}

- (BFTask *)performAsyncActivation
{
    // Not all outputs are supported in all modes
    MBLSensorFusion *sensorFusion = (MBLSensorFusion *)self.module;
    if (self.registerId == 0x5 && (sensorFusion.mode == MBLSensorFusionModeM4G || sensorFusion.mode == MBLSensorFusionModeCompass)) {
        MBLLog(MBLLogLevelError, @"Corrected rotation can't run in M4G or Compass mode.");
        // TODO: Eventually return an error here once they can be recovered from more elegantly
        return [BFTask taskWithResult:nil];
    }
    if ((self.registerId == 0x6) && (sensorFusion.mode == MBLSensorFusionModeIMUPlus)) {
        MBLLog(MBLLogLevelError, @"Corrected magneticField can't run in IMUPlus mode.");
        // TODO: Eventually return an error here once they can be recovered from more elegantly
        return [BFTask taskWithResult:nil];
    }
    
    return [[super performAsyncActivation] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        // Write the enable bits for interrupts
        uint8_t data[] = { self.enableBitmask, 0 };
        int dataSize = sizeof(data) / sizeof(data[0]);
        return [self.enableRegister writeDataAsync:[NSData dataWithBytes:&data length:dataSize]];
    }];
}

- (BFTask *)performAsyncDeactivation
{
    // Write the enable bits for interrupts
    uint8_t data[] = { 0, self.enableBitmask };
    int dataSize = sizeof(data) / sizeof(data[0]);
    return [[self.enableRegister writeDataAsync:[NSData dataWithBytes:&data length:dataSize]] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        return [super performAsyncDeactivation];
    }];
}

@end
