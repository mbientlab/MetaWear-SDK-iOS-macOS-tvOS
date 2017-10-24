/**
 * MBLAmbientLightLTR329.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 7/27/15.
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

#import "MBLAmbientLightLTR329.h"
#import "MBLAmbientLight+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLRegister+Private.h"
#import "MBLNumericFormatter.h"
#import "MBLLogger.h"

typedef struct __attribute__((packed)) {
    uint8_t     als_mode:1;
    uint8_t     sw_reset:1;
    uint8_t     als_gain:3;
    uint8_t     :3;
} ltr329_reg_als_contr_t;

typedef struct __attribute__((packed)) {
    uint8_t     als_measurement_rate:3;
    uint8_t     als_integration_time:3;
    uint8_t     :2;
} ltr329_reg_als_meas_rate_t;

typedef struct __attribute__((packed)) {
    ltr329_reg_als_contr_t        ltr329_als_contr;
    ltr329_reg_als_meas_rate_t    ltr329_als_meas_rate;
} mw_ambientlight_ctrl_regs_t;


@interface MBLAmbientLightLTR329 ()
@property (nonatomic) MBLRegister *mode;
@property (nonatomic) MBLEvent *periodicIlluminance;
@end

@implementation MBLAmbientLightLTR329

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        self.globalEnable = [[MBLRegister alloc] initWithModule:self registerId:0x1 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];

        self.illuminance = nil;
        
        self.gain = MBLAmbientLightLTR329Gain1X;
        self.measurementRate = MBLAmbientLightLTR329Rate500ms;
        self.integrationTime = MBLAmbientLightLTR329Integration100ms;
        
        self.mode = [[MBLRegister alloc] initWithModule:self registerId:0x2 format:[[MBLFormat alloc] initEncodedDataWithLength:2]];
        self.periodicIlluminance = [[MBLEvent alloc] initWithModule:self registerId:0x3 format:[[MBLNumericFormatter alloc] initDoubleWithLength:4 isSigned:NO scale:0.001] identifier:@"illuminance"];
    }
    return self;
}

- (MBLData *)illuminance
{
    MBLLog(MBLLogLevelWarning, @"[AmbientLight] illuminance not yet implemented, please use periodicIlluminance instead");
    return nil;
}

- (BFTask *)performAsyncInitialization
{
    mw_ambientlight_ctrl_regs_t params = { 0 };
    params.ltr329_als_contr.als_gain = self.gain;

    params.ltr329_als_meas_rate.als_integration_time = self.integrationTime;
    params.ltr329_als_meas_rate.als_measurement_rate = self.measurementRate;
    
    return [self.mode writeDataAsync:[NSData dataWithBytes:&params length:sizeof(mw_ambientlight_ctrl_regs_t)]];
}

@end
