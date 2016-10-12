/**
 * MBLMagnetometerBMM150.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 1/6/16.
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

#import "MBLMagnetometerBMM150.h"
#import "MBLMagnetometer+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLRegister+Private.h"
#import "MBLData+Private.h"
#import "MBLNumericFormatter.h"
#import "MBLMagnetometerBMM150PeriodicMagneticFieldEvent.h"
#import "MBLMagnetometerBMM150Format.h"
#import "MBLLogger.h"

/**
 Magnetometer sample frequencies
 */
typedef NS_ENUM(uint8_t, MBLMagnetometerBMM150SampleFrequency) {
    MBLMagnetometerBMM150SampleFrequency2Hz = 1,
    MBLMagnetometerBMM150SampleFrequency6Hz = 2,
    MBLMagnetometerBMM150SampleFrequency8Hz = 3,
    MBLMagnetometerBMM150SampleFrequency10Hz = 0,
    MBLMagnetometerBMM150SampleFrequency15Hz = 4,
    MBLMagnetometerBMM150SampleFrequency20Hz = 5,
    MBLMagnetometerBMM150SampleFrequency25Hz = 6,
    MBLMagnetometerBMM150SampleFrequency30Hz = 7
};

@interface MBLMagnetometerBMM150 ()
@property (nonatomic) MBLRegister *magPowerMode;
@property (nonatomic) MBLRegister *dataRate;
@property (nonatomic) MBLRegister *dataRepetitions;
@property (nonatomic) MBLEvent *periodicMagneticField;
@end

@implementation MBLMagnetometerBMM150

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        self.magneticField = nil;
        
        self.magPowerMode = [[MBLRegister alloc] initWithModule:self registerId:0x1 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
        self.dataRate = [[MBLRegister alloc] initWithModule:self registerId:0x3 format:[[MBLNumericFormatter alloc] initEncodedDataWithLength:1]];
        self.dataRepetitions = [[MBLRegister alloc] initWithModule:self registerId:0x4 format:[[MBLNumericFormatter alloc] initEncodedDataWithLength:2]];
        self.periodicMagneticField = [[MBLMagnetometerBMM150PeriodicMagneticFieldEvent alloc] initWithMagnetometer:self];
        
        // From Matt: The "Low power preset" should be the MetaWear default in the apps.
        self.powerPreset = MBLMagnetometerBMM150PresetLowPower;
    }
    return self;
}

- (MBLData *)magneticField
{
    MBLLog(MBLLogLevelWarning, @"magneticField not yet implemented, please use periodicMagneticField instead");
    return nil;
}

- (BFTask *)performAsyncInitialization
{
    // Table 3: Recommended Presets
    // | Preset     | Rep X/Y   | Rep Z     | ODR       |
    // --------------------------------------------------
    // | Low Power  | 3         | 3         | 10        |
    // | Regular    | 9         | 15        | 10        |
    // | Enhanced   | 15        | 27        | 10        |
    // | High Accur | 47        | 83        | 20        |
    MBLMagnetometerBMM150SampleFrequency sampleFrequency;
    uint8_t repXY;
    uint8_t repZ;
    switch (self.powerPreset) {
        case MBLMagnetometerBMM150PresetLowPower:
            sampleFrequency = MBLMagnetometerBMM150SampleFrequency10Hz;
            repXY = 3;
            repZ = 3;
            break;
        case MBLMagnetometerBMM150PresetRegular:
            sampleFrequency = MBLMagnetometerBMM150SampleFrequency10Hz;
            repXY = 9;
            repZ = 15;
            break;
        case MBLMagnetometerBMM150PresetEnhancedRegular:
            sampleFrequency = MBLMagnetometerBMM150SampleFrequency10Hz;
            repXY = 15;
            repZ = 27;
            break;
        case MBLMagnetometerBMM150PresetHighAccuracy:
            sampleFrequency = MBLMagnetometerBMM150SampleFrequency20Hz;
            repXY = 47;
            repZ = 83;
            break;
    }
    
    uint8_t data[] = { (repXY - 1) / 2 , (repZ - 1) };
    int dataSize = sizeof(data) / sizeof(data[0]);
    uint8_t dataRate = sampleFrequency;
    
    return [[self.dataRepetitions writeDataAsync:[NSData dataWithBytes:&data length:dataSize]] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [self.dataRate writeByteAsync:dataRate];
    }];
}

- (BFTask *)performAsyncActivation
{
    return [self.magPowerMode writeByteAsync:1];
}

- (BFTask *)performAsyncDeactivation
{
    return [self.magPowerMode writeByteAsync:0];
}

@end
