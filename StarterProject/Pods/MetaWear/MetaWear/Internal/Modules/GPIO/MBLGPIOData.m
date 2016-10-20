/**
 * MBLGPIOData.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 2/2/15.
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

#import "MBLGPIOData.h"
#import "MBLRegister+Private.h"
#import "MBLNumericData+Private.h"
#import "MBLGPIOPin+Private.h"
#import "MBLGPIO+Private.h"
#import "MBLMetaWearManager+Private.h"
#import "MBLMetaWear+Private.h"
#import "BFTask+Private.h"

@interface MBLGPIOData ()
@property (nonatomic, weak) MBLGPIOPin *pin;
@property (nonatomic) NSNumber *pullUp;
@property (nonatomic) NSNumber *pullDown;
@property (nonatomic) uint16_t readDelay;
@end

@implementation MBLGPIOData

- (instancetype)initWithRegister:(MBLRegister *)reg pin:(MBLGPIOPin *)pin format:(MBLFormat *)format
{
    self = [super initWithModule:reg.module registerId:reg.registerId index:pin.pin format:format];
    if (self) {
        self.pin = pin;
    }
    return self;
}
- (instancetype)initWithRegister:(MBLRegister *)reg
                             pin:(MBLGPIOPin *)pin
                          format:(MBLFormat *)format
                          pullUp:(NSNumber *)pullUp
                        pullDown:(NSNumber *)pullDown
                       readDelay:(uint16_t)readDelay
{
    self = [super initWithModule:reg.module registerId:reg.registerId index:0xFF format:format];
    if (self) {
        self.pin = pin;
        self.pullUp = pullUp;
        self.pullDown = pullDown;
        self.readDelay = readDelay;
    }
    return self;
}

- (BFTask *)performAsyncInitialization
{
    // Use the legacy code if not using pullUp or pullDown
    if (!self.pullUp && !self.pullDown) {
        return [super performAsyncInitialization];
    }
    return [self.module.device.gpio performAsyncInitializationForRegister:self];
}

- (BFTask *)performAsyncDeinitialization
{
    // Use the legacy code if not using pullUp or pullDown
    if (!self.pullUp && !self.pullDown) {
        return [super performAsyncInitialization];
    }
    return [self.module.device.gpio performAsyncDeinitializationForRegister:self];
}

- (NSData *)readParameters
{
    // Shortcut for older modules
    if (self.module.moduleInfo.moduleRevision < 2) {
        return [super readParameters];
    }
    // Assert we have a valid index if using pullUp or pullDown
    assert((!self.pullUp && !self.pullDown) || self.index != 0xFF);
    
    uint8_t readIndex = self.pin.pin;
    uint8_t pullUp = self.pullUp ? self.pullUp.unsignedCharValue : 0xFF;
    uint8_t pullDown = self.pullDown ? self.pullDown.unsignedCharValue : 0xFF;
    uint8_t startupDelay = MIN(self.readDelay / 4, 0xFF);
    uint8_t spoofedIndex = self.index;
    
    uint8_t data[] = { readIndex, pullUp, pullDown, startupDelay, spoofedIndex };
    int dataSize = sizeof(data) / sizeof(data[0]);
    return [NSData dataWithBytes:&data length:dataSize];
}

- (BFTask *)performAsyncActivation
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (self.pin.enablePin) {
#pragma clang diagnostic pop
        [NSException raise:@"Use of deprecated function" format:@"enablePin is deprecated, please use analogRatioWithPullUp:pullDown:readDelay or analogAbsoluteWithPullUp:pullDown:readDelay instead"];
    }
    return [super performAsyncActivation];
}

- (BFTask *)performAsyncDeactivation
{
    return [super performAsyncDeactivation];
}

@end
