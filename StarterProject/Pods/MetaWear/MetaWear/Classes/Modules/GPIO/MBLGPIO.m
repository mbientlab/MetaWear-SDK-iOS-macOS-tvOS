/**
 * MBLGPIO.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 8/2/14.
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

#import "MBLGPIO+Private.h"
#import "MBLRegister+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLEvent+Private.h"
#import "MBLNumericData+Private.h"
#import "MBLGPIOPin+Private.h"
#import "MBLGPIOData.h"
#import "MBLDeviceInfo.h"
#import "MBLGPIOPinChangeEvent.h"
#import "MBLNumericFormatter.h"
#import "MBLDataSample.h"
#import "BFTask+Private.h"

@interface MBLGPIO()
@property (nonatomic) MBLRegister *setDigitalOutput;
@property (nonatomic) MBLRegister *clearDigitalOutput;
@property (nonatomic) MBLRegister *setInputPullup;
@property (nonatomic) MBLRegister *setInputPulldown;
@property (nonatomic) MBLRegister *setInputNopull;
@property (nonatomic) MBLRegister *readAnalogAbsolute;
@property (nonatomic) MBLRegister *readAnalogRatio;
@property (nonatomic) MBLRegister *readDigital;
@property (nonatomic) MBLRegister *pinChangeSettings;
@property (nonatomic) MBLRegister *pinChangeNotification;
@property (nonatomic) MBLRegister *pinChangeNotificationEnable;

@property (nonatomic) NSArray *pins;
@property (nonatomic) int activeNotifications;
@property (nonatomic) NSMutableArray<NSNumber *> *indexes;
@end

@implementation MBLGPIO

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        self.setDigitalOutput = [[MBLRegister alloc] initWithModule:self registerId:0x1 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
        self.clearDigitalOutput = [[MBLRegister alloc] initWithModule:self registerId:0x2 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
        self.setInputPullup = [[MBLRegister alloc] initWithModule:self registerId:0x3 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
        self.setInputPulldown = [[MBLRegister alloc] initWithModule:self registerId:0x4 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
        self.setInputNopull = [[MBLRegister alloc] initWithModule:self registerId:0x5 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
        self.readAnalogAbsolute = [[MBLRegister alloc] initWithModule:self registerId:0x6 format:[[MBLFormat alloc] initEncodedDataWithLength:3]];
        self.readAnalogRatio = [[MBLRegister alloc] initWithModule:self registerId:0x7 format:[[MBLFormat alloc] initEncodedDataWithLength:3]];
        self.readDigital = [[MBLRegister alloc] initWithModule:self registerId:0x8 format:[[MBLFormat alloc] initEncodedDataWithLength:2]];
        self.pinChangeSettings = [[MBLRegister alloc] initWithModule:self registerId:0x9 format:[[MBLFormat alloc] initEncodedDataWithLength:2]];
        self.pinChangeNotification = [[MBLRegister alloc] initWithModule:self registerId:0xA format:[[MBLFormat alloc] initEncodedDataWithLength:2]];
        self.pinChangeNotificationEnable = [[MBLRegister alloc] initWithModule:self registerId:0xB format:[[MBLFormat alloc] initEncodedDataWithLength:2]];
        
        if (moduleInfo.moduleRevision >= 1) {
            NSMutableArray *pins = [[NSMutableArray alloc] initWithCapacity:moduleInfo.moduleData.length];
            if (moduleInfo.moduleData.length) {
                uint8_t *featureByte = (uint8_t *)moduleInfo.moduleData.bytes;
                for (uint8_t pin = 0; pin < moduleInfo.moduleData.length; pin++, featureByte++) {
                    [pins addObject:[[MBLGPIOPin alloc] initWithModule:self pin:pin featureByte:*featureByte]];
                }
            }
            self.pins = pins;
            self.indexes = [NSMutableArray array];
            for (int i = (int)pins.count; i < 32; i++) {
                [self.indexes addObject:[NSNumber numberWithInt:i]];
            }
        } else {
            // These are the old defaults
            self.pins = @[[[MBLGPIOPin alloc] initWithModule:self pin:0 featureByte:0x3],
                          [[MBLGPIOPin alloc] initWithModule:self pin:1 featureByte:0x3],
                          [[MBLGPIOPin alloc] initWithModule:self pin:2 featureByte:0x3],
                          [[MBLGPIOPin alloc] initWithModule:self pin:3 featureByte:0x3],
                          [[MBLGPIOPin alloc] initWithModule:self pin:4 featureByte:0x1],
                          [[MBLGPIOPin alloc] initWithModule:self pin:5 featureByte:0x1],
                          [[MBLGPIOPin alloc] initWithModule:self pin:6 featureByte:0x1],
                          [[MBLGPIOPin alloc] initWithModule:self pin:7 featureByte:0x1]];
            self.indexes = [NSMutableArray array];
            for (int i = 8; i < 32; i++) {
                [self.indexes addObject:[NSNumber numberWithInt:i]];
            }
        }
	}
    return self;
}

- (BFTask *)startNotificationsOnChangeEvent:(MBLGPIOPinChangeEvent *)event
{
    return [[BFTask taskFromMetaWearWithBlock:^id _Nonnull{
        // Turn on notifications for this pin
        uint8_t data[] = { event.index, 1 };
        return [self.pinChangeNotificationEnable writeDataAsync:[NSData dataWithBytes:data length:2]];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        self.activeNotifications++;
        if (self.activeNotifications == 1) {
            // Turn on global notifications
            return [self.pinChangeNotification startNotificationsWithHandlerAsync:nil];
        }
        return nil;
    }];
}

- (BFTask *)stopNotificationsAsyncOnChangeEvent:(MBLGPIOPinChangeEvent *)event
{
    return [[BFTask taskFromMetaWearWithBlock:^id _Nonnull{
        self.activeNotifications--;
        if (self.activeNotifications == 0) {
            // Turn off global notifications
            return [self.pinChangeNotification stopNotificationsAsync];
        }
        assert(self.activeNotifications >= 0);
        self.activeNotifications = MAX(self.activeNotifications, 0);
        return nil;
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        // Turn off notifications for this pin
        uint8_t data[] = { event.index, 0 };
        return [self.pinChangeNotificationEnable writeDataAsync:[NSData dataWithBytes:data length:2]];
    }];
}

- (BFTask *)setPin:(uint8_t)pinNumber toDigitalValue:(BOOL)on
{
    MBLRegister *reg = on ? self.setDigitalOutput : self.clearDigitalOutput;
    return [reg writeByteAsync:pinNumber];
}

- (BFTask *)configurePin:(uint8_t)pinNumber type:(MBLPinConfiguration)type
{
    MBLRegister *reg;
    switch (type) {
        case MBLPinConfigurationPullup:
            reg = self.setInputPullup;
            break;
        case MBLPinConfigurationPulldown:
            reg = self.setInputPulldown;
            break;
        case MBLPinConfigurationNopull:
            reg = self.setInputNopull;
            break;
    }
    return [reg writeByteAsync:pinNumber];
}

- (BFTask *)performAsyncInitializationForRegister:(MBLGPIOData *)reg
{
    return [BFTask taskFromMetaWearWithBlock:^id _Nonnull{
        assert(reg.index == 0xFF);
        NSNumber *index = [self.indexes lastObject];
        if (!index) {
            NSError *error = [NSError errorWithDomain:kMBLErrorDomain
                                                 code:kMBLErrorInsufficientMemory
                                             userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"MetaWear out of memory, can't perform action.  Reset the MetaWear."]}];
            return [BFTask taskWithError:error];
        }
        reg.index = index.unsignedCharValue;
        [self.indexes removeLastObject];
        return nil;
    }];
}

- (BFTask *)performAsyncDeinitializationForRegister:(MBLGPIOData *)reg
{
    return [BFTask taskFromMetaWearWithBlock:^id _Nonnull{
        assert(reg.index != 0xFF);
        [self.indexes addObject:[NSNumber numberWithInt:reg.index]];
        reg.index = 0xFF;
        return nil;
    }];
}

@end
