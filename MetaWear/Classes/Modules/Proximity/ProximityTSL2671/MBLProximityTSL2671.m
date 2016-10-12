/**
 * MBLProximityTSL2671.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 2/22/16.
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

#import "MBLProximityTSL2671.h"
#import "MBLProximity+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLRegister+Private.h"
#import "MBLData+Private.h"
#import "MBLNumericFormatter.h"
#import "MBLConstants+Private.h"

typedef struct __attribute__((packed)) {
    uint8_t     ptime;
} tsl2671_reg_ptime_t;

typedef struct __attribute__((packed)) {
    uint8_t     ppulse;
} tsl2671_reg_ppulse_t;

typedef struct __attribute__((packed)) {
    uint8_t     :4;
    uint8_t     pdiode:2;
    uint8_t     pdrive:2;
} tsl2671_reg_control_t;

typedef struct __attribute__((packed)) {
    tsl2671_reg_ptime_t     ptime;
    tsl2671_reg_ppulse_t    ppulse;
    tsl2671_reg_control_t   control;
} mw_proximity_mode_t;


@interface MBLProximityTSL2671()
@property (nonatomic) MBLRegister *mode;
@end

@implementation MBLProximityTSL2671

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        self.proximity = [[MBLData alloc] initWithModule:self registerId:0x1 format:[[MBLNumericFormatter alloc] initIntWithLength:2 isSigned:NO]];
        
        self.mode = [[MBLRegister alloc] initWithModule:self registerId:0x2 format:[[MBLFormat alloc] initEncodedDataWithLength:3]];
        // Mode defaults
        self.integrationTime = 2.72;
        self.proximityPulses = 1;
        self.drive = MBLProximityTSL2671TransmitterDrive25mA;
    }
    return self;
}

- (void)setIntegrationTime:(double)integrationTime
{
    _integrationTime = [MBLConstants clampDouble:integrationTime low:2.72 high:696.32];
}

- (void)setProximityPulses:(uint8_t)proximityPulses
{
    _proximityPulses = MIN(proximityPulses, 32);
}

- (BFTask *)performAsyncInitialization
{
    mw_proximity_mode_t regs = { 0 };
    
    regs.ptime.ptime = 256 - round(self.integrationTime / 2.72);
    regs.ppulse.ppulse = self.proximityPulses;
    regs.control.pdiode = 2; // Receiver Diode Select: (0: None, 1: Chan 0, 2: Chan 1, 3: Both) Chan 1 recommended, wavelength matches transmitter.
    regs.control.pdrive = self.drive;
    
    return [self.mode writeDataAsync:[NSData dataWithBytes:&regs length:sizeof(mw_proximity_mode_t)]];
}

@end
