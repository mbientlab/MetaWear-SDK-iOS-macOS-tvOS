/**
 * MBLAccelerometerDataReadyEvent.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 10/23/14.
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

#import "MBLAccelerometerDataReadyEvent.h"
#import "MBLAccelerometerData+Private.h"
#import "MBLAccelerometerMMA8452Q+Private.h"
#import "MBLAccelerometerMMA8452QFormat.h"
#import "MBLAccelerometerPackedDataReadyEvent.h"
#import "MBLNumericFormatter.h"
#import "mma8452q.h"
#import "BFTask+Private.h"


typedef NS_ENUM(uint8_t, MBLAccelerometerPackedDataMode) {
    MBLAccelerometerPackedDataModeOff = 0,
    MBLAccelerometerPackedDataModeNormal = 1,
    MBLAccelerometerPackedDataModePacked = 2
};

@interface MBLAccelerometerDataReadyEvent ()
@property (nonatomic) MBLRegister *dataEnable;
@property (nonatomic) MBLAccelerometerPackedDataReadyEvent *packedData;
@property (nonatomic) MBLAccelerometerPackedDataMode packerMode;
@end

@implementation MBLAccelerometerDataReadyEvent

- (instancetype)initWithAccelerometer:(MBLAccelerometerMMA8452Q *)accelerometer
{
    self = [super initWithModule:accelerometer registerId:0x4 format:[[MBLAccelerometerMMA8452QFormat alloc] initWithPacked:NO]];
    if (self) {
        self.dataEnable = [[MBLRegister alloc] initWithModule:accelerometer registerId:0x2 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
        if (accelerometer.moduleInfo.moduleRevision >= 1) {
            self.packedData = [[MBLAccelerometerPackedDataReadyEvent alloc] initWithAccelerometer:accelerometer];
        }
    }
    return self;
}

- (BFTask *)performAsyncActivation
{
    NSMutableArray *tasks = [NSMutableArray array];
    BOOL strobeGlobalEnable = self.module.activateCount;
    MBLAccelerometerMMA8452Q *accelerometer = (MBLAccelerometerMMA8452Q *)self.module;

    if (strobeGlobalEnable) {
        [tasks addObject:[accelerometer.globalEnable writeByteAsync:0x0]];
    }
    [tasks addObject:[self.dataEnable writeByteAsync:0x1]];
    if (strobeGlobalEnable) {
        [tasks addObject:[accelerometer.globalEnable writeByteAsync:0x1]];
    }
    return [BFTask taskForCompletionOfAllTasks:tasks];
}

- (BFTask *)performAsyncDeactivation
{
    return [self.dataEnable writeByteAsync:0x0];
}

- (BFTask *)startNotificationsWithHandlerAsync:(MBLObjectHandler)handler
{
    if (!self.packedData) {
        return [super startNotificationsWithHandlerAsync:handler];
    }
    
    MBLAccelerometerMMA8452Q *accelerometer = (MBLAccelerometerMMA8452Q *)self.module;
    if (self.packerMode == MBLAccelerometerPackedDataModeOff) {
        // Turn on the packer for frequencies over 100
        self.packerMode = accelerometer.sampleFrequency >= 100 ? MBLAccelerometerPackedDataModePacked : MBLAccelerometerPackedDataModeNormal;
    }
    return self.packerMode == MBLAccelerometerPackedDataModePacked ? [self.packedData startNotificationsWithHandlerAsync:handler]
                                                                   : [super startNotificationsWithHandlerAsync:handler];
}

- (BFTask *)stopNotificationsAsync
{
    if (!self.packedData) {
        return [super stopNotificationsAsync];
    }
    
    MBLAccelerometerPackedDataMode prevMode = self.packerMode;
    self.packerMode = MBLAccelerometerPackedDataModeOff;
    return prevMode == MBLAccelerometerPackedDataModePacked ? [self.packedData stopNotificationsAsync]
                                                            : [super stopNotificationsAsync];
}

- (BOOL)isNotifying
{
    if (!self.packedData) {
        return [super isNotifying];
    }
    
    return self.packerMode == MBLAccelerometerPackedDataModePacked ? [self.packedData isNotifying]
                                                                   : [super isNotifying];
}

@end
