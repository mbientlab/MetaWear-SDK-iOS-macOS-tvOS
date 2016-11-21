/**
 * MBLAccelerometer.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 7/29/14.
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

#import "MBLAccelerometer+Private.h"
#import "MBLAccelerometerMMA8452Q+Private.h"
#import "MBLAccelerometerBMI160+Private.h"
#import "MBLAccelerometerBMA255+Private.h"
#import "MBLMetaWear+Private.h"
#import "mma8452q.h"
#import "MBLRegister+Private.h"
#import "MBLNumericFormatter.h"
#import "MBLAccelerometerDataReadyEvent.h"
#import "MBLAccelerometerFreeFallEvent.h"
#import "MBLAccelerometerOrientationEvent.h"
#import "MBLAccelerometerTapEvent.h"
#import "MBLAccelerometerShakeEvent.h"
#import "MBLAccelerometerData+Private.h"
#import "MBLAccelerometerAxisReadyEvent.h"

@interface MBLAccelerometer()
@property (nonatomic) MBLEvent *dataReadyEvent;
@property (nonatomic) MBLEvent *xAxisReadyEvent;
@property (nonatomic) MBLEvent *yAxisReadyEvent;
@property (nonatomic) MBLEvent *zAxisReadyEvent;
@property (nonatomic) MBLEvent *rmsDataReadyEvent;
@end

@implementation MBLAccelerometer

+ (instancetype)objectWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    if (moduleInfo.moduleImplementation == 1) {
        return [[MBLAccelerometerBMI160 alloc] initWithDevice:device moduleInfo:moduleInfo];
    } else if (moduleInfo.moduleImplementation == 3) {
        return [[MBLAccelerometerBMA255 alloc] initWithDevice:device moduleInfo:moduleInfo];
    } else {
        return [[MBLAccelerometerMMA8452Q alloc] initWithDevice:device moduleInfo:moduleInfo];
    }
}

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        self.sampleFrequency = 100;
    }
    return self;
}

@end
