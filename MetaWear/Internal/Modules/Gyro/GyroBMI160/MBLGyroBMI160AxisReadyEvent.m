/**
 * MBLGyroBMI160AxisReadyEvent.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 5/28/15.
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

#import "MBLGyroBMI160AxisReadyEvent.h"
#import "MBLGyroBMI160Format.h"
#import "MBLGyroBMI160+Private.h"
#import "MBLLogger.h"

@implementation MBLGyroBMI160AxisReadyEvent

- (instancetype)initWithGyro:(MBLGyroBMI160 *)gyro axis:(uint8_t)axis
{
    NSString *identifier = nil;
    MBLGyroAxis typedAxis = axis;
    switch (typedAxis) {
        case MBLGyroAxisX:
            identifier = @"angular-velocity[0]";
            break;
        case MBLGyroAxisY:
            identifier = @"angular-velocity[1]";
            break;
        case MBLGyroAxisZ:
            identifier = @"angular-velocity[2]";
            break;
    }
    self = [super initWithModule:gyro registerId:0x5 format:[[MBLGyroBMI160Format alloc] initWithGyro:gyro axis:axis] identifier:identifier];
    return self;
}

- (BFTask *)performAsyncInitialization
{
    MBLGyroBMI160 *gyro = (MBLGyroBMI160 *)self.module;
    return [gyro.dataReadyEvent initializeAsync];
}

- (BFTask *)performAsyncDeinitialization
{
    MBLGyroBMI160 *gyro = (MBLGyroBMI160 *)self.module;
    return [gyro.dataReadyEvent deinitializeAsync];
}

- (BFTask *)performAsyncActivation
{
    MBLGyroBMI160 *gyro = (MBLGyroBMI160 *)self.module;
    return [gyro.dataReadyEvent activateAsync];
}

- (BFTask *)performAsyncDeactivation
{
    MBLGyroBMI160 *gyro = (MBLGyroBMI160 *)self.module;
    return [gyro.dataReadyEvent deactivateAsync];
}

- (BFTask *)startNotificationsWithHandlerAsync:(MBLObjectHandler)handler
{
    MBLGyroBMI160 *gyro = (MBLGyroBMI160 *)self.module;
    if (gyro.sampleFrequency > 200) {
        MBLLog(MBLLogLevelWarning, @"[Gyro] due to Bluetooth LE bandwidth limitations, notications faster than 200Hz will result in packet loss");
    }
    return [super startNotificationsWithHandlerAsync:handler];
}

@end
