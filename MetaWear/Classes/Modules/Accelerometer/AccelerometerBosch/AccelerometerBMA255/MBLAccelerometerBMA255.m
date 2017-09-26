/**
 * MBLAccelerometerBMA255.m
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

#import "MBLAccelerometerBMA255+Private.h"
#import "MBLAccelerometerBosch+Private.h"
#import "MBLModule+Private.h"
#import "MBLAccelerometerBMA255MotionEvent+Private.h"
#import "MBLAccelerometerBoschLowOrHighGEvent+Private.h"
#import "MBLRegister+Private.h"
#import "BFTask+MBLPrivate.h"

@interface MBLAccelerometerBMA255 ()
@property (nonatomic) MBLAccelerometerBMA255MotionEvent *motionEvent;
@end

@implementation MBLAccelerometerBMA255

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        self.motionEvent = [[MBLAccelerometerBMA255MotionEvent alloc] initWithAccelerometer:self];
        
        self.lowOrHighGEvent.lowOrHighGDurationMultiplier = 2.0;
    }
    return self;
}

- (BFTask *)pullConfigAsync
{
    return [[self.accelDataConfig readAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        MBLDataSample *result = t.result;
        const uint8_t *data = result.data.bytes;
        self.fullScaleRange = data[1];
        return nil;
    }];
}

- (BFTask *)performAsyncInitialization
{
    // Write the disable bits for motion interrupts
    uint8_t data[] = { self.scaleSampleFrequency, self.fullScaleRange };
    int dataSize = sizeof(data) / sizeof(data[0]);
    
    return [self.accelDataConfig writeDataAsync:[NSData dataWithBytes:data length:dataSize]];
}

- (uint8_t)scaleSampleFrequency
{
    if (self.sampleFrequency > 1000.0) {
        return 0xF;
    } else if (self.sampleFrequency > 500.0) {
        return 0xE;
    } else if (self.sampleFrequency > 250.0) {
        return 0xD;
    } else if (self.sampleFrequency > 125.0) {
        return 0xC;
    } else if (self.sampleFrequency > 62.5) {
        return 0xB;
    } else if (self.sampleFrequency > 31.26) {
        return 0xA;
    } else if (self.sampleFrequency > 15.62) {
        return 0x9;
    } else {
        return 0x8;
    }
}

@end
