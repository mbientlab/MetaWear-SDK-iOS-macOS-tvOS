/**
 * MBLAccelerometerBosch.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 2/29/16.
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

#import "MBLAccelerometerBosch+Private.h"
#import "MBLAccelerometer+Private.h"
#import "MBLAccelerometerBoschDataReadyEvent.h"
#import "MBLAccelerometerBoschAxisReadyEvent.h"
#import "MBLAccelerometerBoschLowOrHighGEvent+Private.h"
#import "MBLAccelerometerBoschOrientationEvent.h"
#import "MBLAccelerometerBoschTapEvent.h"
#import "MBLAccelerometerBoschFlatEvent.h"
#import "MBLAccelerometerBMI160StepEvent.h"
#import "MBLRMSAccelerometerDataFilter.h"
#import "MBLFormat.h"
#import "MBLNumericFormatter.h"
#import "MBLData+Private.h"
#import "bmi160.h"

@interface MBLAccelerometerBosch ()
@property (nonatomic) MBLRegister *accelDataConfig;

@property (nonatomic) MBLAccelerometerBoschLowOrHighGEvent *lowOrHighGEvent;
@property (nonatomic) MBLEvent *tapEvent;
@property (nonatomic) MBLEvent *orientationEvent;
@property (nonatomic) MBLEvent *flatEvent;
@property (nonatomic) MBLEvent *stepEvent;
@end

@implementation MBLAccelerometerBosch

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        // MBLAccelerometer properties
        self.dataReadyEvent = [[MBLAccelerometerBoschDataReadyEvent alloc] initWithAccelerometer:self];
        self.xAxisReadyEvent = [[MBLAccelerometerBoschAxisReadyEvent alloc] initWithAccelerometer:self axis:MBLAccelerometerAxisX];
        self.yAxisReadyEvent = [[MBLAccelerometerBoschAxisReadyEvent alloc] initWithAccelerometer:self axis:MBLAccelerometerAxisY];
        self.zAxisReadyEvent = [[MBLAccelerometerBoschAxisReadyEvent alloc] initWithAccelerometer:self axis:MBLAccelerometerAxisZ];
        self.rmsDataReadyEvent = [[MBLRMSAccelerometerDataFilter alloc] initWithAccelerometerBosch:self];
        
        // Default settings
        self.fullScaleRange = MBLAccelerometerBoschRange16G;
        self.tapType = MBLAccelerometerTapTypeSingle;
        // Registers
        MBLRegister *accelPowerMode = [[MBLRegister alloc] initWithModule:self registerId:0x1 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
        self.accelDataConfig = [[MBLRegister alloc] initWithModule:self registerId:0x3 format:[[MBLFormat alloc] initEncodedDataWithLength:2]];
        
        // Events
        self.lowOrHighGEvent = [[MBLAccelerometerBoschLowOrHighGEvent alloc] initWithAccelerometer:self];
        self.tapEvent = [[MBLAccelerometerBoschTapEvent alloc] initWithAccelerometer:self];
        self.orientationEvent = [[MBLAccelerometerBoschOrientationEvent alloc] initWithAccelerometer:self];
        self.flatEvent = [[MBLAccelerometerBoschFlatEvent alloc] initWithAccelerometer:self];
        
        self.globalEnable = accelPowerMode;
    }
    return self;
}

@end
