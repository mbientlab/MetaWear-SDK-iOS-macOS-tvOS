/**
 * MBLBarometerBosch.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 2/25/16.
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

#import "MBLBarometerBosch+Private.h"
#import "MBLBarometer+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLRegister+Private.h"
#import "MBLData+Private.h"
#import "MBLNumericFormatter.h"
#import "MBLBarometerBoschPeriodicPressureEvent.h"
#import "MBLBarometerBoschPeriodicAltitudeEvent.h"

@interface MBLBarometerBosch ()
@property (nonatomic) MBLEvent *periodicPressure;
@property (nonatomic) MBLEvent *periodicAltitude;
@property (nonatomic) MBLRegister *mode;
@end

@implementation MBLBarometerBosch

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        self.pressure = [[MBLData alloc] initWithModule:self registerId:0x1 format:[[MBLNumericFormatter alloc] initDoubleWithLength:4 isSigned:NO scale:1.0 / 256.0]];
        self.altitude = [[MBLData alloc] initWithModule:self registerId:0x2 format:[[MBLNumericFormatter alloc] initDoubleWithLength:4 isSigned:YES scale:1.0 / 256.0]];
        self.periodicPressure = [[MBLBarometerBoschPeriodicPressureEvent alloc] initWithBarometer:self];
        self.periodicAltitude = [[MBLBarometerBoschPeriodicAltitudeEvent alloc] initWithBarometer:self];
        self.mode = [[MBLRegister alloc] initWithModule:self registerId:0x3 format:[[MBLFormat alloc] initEncodedDataWithLength:2]];
        
        self.pressureOversampling = MBLBarometerBoschOversampleStandard;
        self.hardwareAverageFilter = MBLBarometerBoschFilterOff;
    }
    return self;
}

@end
