/**
 * MBLLED.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 8/1/14.
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

#import "MBLLED+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLRegister+Private.h"
#import "MBLNumericFormatter.h"

@interface MBLLED()
@property (nonatomic) MBLRegister *play;
@property (nonatomic) MBLRegister *stop;
@property (nonatomic) MBLRegister *mode;
@property (nonatomic) MBLRegister *secondaryMode;
@end

typedef struct __attribute__((packed)) {
    uint8_t		channelCount;
    uint8_t     secondaryModeLength;
} mw_led_module_info;

@implementation MBLLED

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        self.play = [[MBLRegister alloc] initWithModule:self registerId:0x1 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
        self.stop = [[MBLRegister alloc] initWithModule:self registerId:0x2 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
        self.mode = [[MBLRegister alloc] initWithModule:self registerId:0x3 format:[[MBLFormat alloc] initEncodedDataWithLength:18]];
        if (moduleInfo.moduleRevision >= 1) {
            mw_led_module_info *info = (mw_led_module_info *)moduleInfo.moduleData.bytes;
            self.secondaryMode = [[MBLRegister alloc] initWithModule:self registerId:0x4 format:[[MBLFormat alloc] initEncodedDataWithLength:info->secondaryModeLength]];
        }
    }
    return self;
}

- (BFTask *)setLEDColorAsync:(MBLColor *)color withIntensity:(CGFloat)intensity
{
    if (intensity < 0.0 || intensity > 1.0) {
        [NSException raise:@"Invalid intensity value"
                    format:@"intensity of %f is invalid, valid range is [0, 1.0]", intensity];
    }
    int scaledIntensity = (intensity * 31.0);
    CGFloat red, blue, green;
    static const uint16_t rtime = 0;
    static const uint16_t ftime = 0;
    static const uint16_t otime = 0x0800;
    static const uint16_t period = 0x0800;
    static const uint16_t offset = 0;
    static const uint8_t repeat = 0xFF;
    
    MBLMetaWear *device = self.device;
    [device incrementCount];
    BFTask *head = [BFTask taskWithResult:nil];
#if TARGET_OS_IOS || TARGET_OS_TV
    [color getRed:&red green:&green blue:&blue alpha:nil];
#else
    NSColor *rgbColor = [color colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
    red = rgbColor.redComponent;
    green = rgbColor.greenComponent;
    blue = rgbColor.blueComponent;
#endif
    
    BOOL isOn = NO;
    int scaledRed = red * scaledIntensity;
    int scaledBlue = blue * scaledIntensity;
    int scaledGreen = green * scaledIntensity;
    
    head = [head continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [self setLEDOnAsync:NO withOptions:1];
    }];
    
    if (scaledRed) {
        isOn = YES;
        head = [head continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
            return [self setLEDModeWithColorChannelAsync:MBLLEDColorChannelRed
                                             onIntensity:scaledRed
                                            offIntensity:scaledRed - 1
                                                riseTime:rtime fallTime:ftime onTime:otime period:period offset:offset repeatCount:repeat];
        }];
    }
    if (scaledGreen) {
        isOn = YES;
        head = [head continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
            return [self setLEDModeWithColorChannelAsync:MBLLEDColorChannelGreen
                                             onIntensity:scaledGreen
                                            offIntensity:scaledGreen - 1
                                                riseTime:rtime fallTime:ftime onTime:otime period:period offset:offset repeatCount:repeat];
        }];
    }
    if (scaledBlue) {
        isOn = YES;
        head = [head continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
            return [self setLEDModeWithColorChannelAsync:MBLLEDColorChannelBlue
                                             onIntensity:scaledBlue
                                            offIntensity:scaledBlue - 1
                                                riseTime:rtime fallTime:ftime onTime:otime period:period offset:offset repeatCount:repeat];
        }];
    }
    head = [head continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [self setLEDOnAsync:isOn withOptions:1];
    }];
    
    head = [head continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        [device decrementCount];
        return task;
    }];
    return head;
}

- (BFTask *)flashLEDColorAsync:(MBLColor *)color withIntensity:(CGFloat)intensity
{
    return [self flashLEDColorAsync:color withIntensity:intensity onTime:200 andPeriod:800];
}

- (BFTask *)flashLEDColorAsync:(MBLColor *)color withIntensity:(CGFloat)intensity numberOfFlashes:(uint8_t)numberOfFlashes
{
    return [self flashLEDColorAsync:color withIntensity:intensity onTime:200 period:800 repeat:numberOfFlashes offIsZero:YES];
}

- (BFTask *)flashLEDColorAsync:(MBLColor *)color withIntensity:(CGFloat)intensity onTime:(uint16_t)otime andPeriod:(uint16_t)period
{
    return [self flashLEDColorAsync:color withIntensity:intensity onTime:otime period:period repeat:0xff offIsZero:NO];
}

- (BFTask *)flashLEDColorAsync:(MBLColor *)color withIntensity:(CGFloat)intensity onTime:(uint16_t)otime period:(uint16_t)period numberOfFlashes:(uint8_t)numberOfFlashes
{
    return [self flashLEDColorAsync:color withIntensity:intensity onTime:otime period:period repeat:numberOfFlashes offIsZero:NO];
}

- (BFTask *)flashLEDColorAsync:(MBLColor *)color withIntensity:(CGFloat)intensity onTime:(uint16_t)otime period:(uint16_t)period repeat:(uint8_t)repeat offIsZero:(BOOL)offIsZero
{
    if (intensity < 0.0 || intensity > 1.0) {
        [NSException raise:@"Invalid intensity value"
                    format:@"intensity of %f is invalid, valid range is [0, 1.0]", intensity];
    }
    
    int scaledIntensity = (intensity * 31.0);
    CGFloat red, blue, green;
    const uint16_t rtime = otime / 2;
    const uint16_t ftime = otime / 2;
    static const uint16_t offset = 0;
    
    MBLMetaWear *device = self.device;
    [device incrementCount];
    BFTask *head = [BFTask taskWithResult:nil];
#if TARGET_OS_IOS || TARGET_OS_TV
    [color getRed:&red green:&green blue:&blue alpha:nil];
#else
    NSColor *rgbColor = [color colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
    red = rgbColor.redComponent;
    green = rgbColor.greenComponent;
    blue = rgbColor.blueComponent;
#endif
    BOOL isOn = NO;
    int scaledRed = red * scaledIntensity;
    int scaledBlue = blue * scaledIntensity;
    int scaledGreen = green * scaledIntensity;
    
    head = [head continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [self setLEDOnAsync:NO withOptions:1];
    }];
    
    if (scaledRed) {
        isOn = YES;
        head = [head continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
            return [self setLEDModeWithColorChannelAsync:MBLLEDColorChannelRed
                                             onIntensity:scaledRed
                                            offIntensity:offIsZero ? 0 : scaledRed == 1 ? 0 : 1
                                                riseTime:rtime fallTime:ftime onTime:otime period:period offset:offset repeatCount:repeat];
        }];
    }
    if (scaledGreen) {
        isOn = YES;
        head = [head continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
            return [self setLEDModeWithColorChannelAsync:MBLLEDColorChannelGreen
                                             onIntensity:scaledGreen
                                            offIntensity:offIsZero ? 0 : scaledGreen == 1 ? 0 : 1
                                                riseTime:rtime fallTime:ftime onTime:otime period:period offset:offset repeatCount:repeat];
        }];
    }
    if (scaledBlue) {
        isOn = YES;
        head = [head continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
            return [self setLEDModeWithColorChannelAsync:MBLLEDColorChannelBlue
                                             onIntensity:scaledBlue
                                            offIntensity:offIsZero ? 0 : scaledBlue == 1 ? 0 : 1
                                                riseTime:rtime fallTime:ftime onTime:otime period:period offset:offset repeatCount:repeat];
        }];
    }
    head = [head continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [self setLEDOnAsync:isOn withOptions:1];
    }];
    
    head = [head continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        [device decrementCount];
        return task;
    }];
    return head;
}

- (BFTask *)setLEDModeWithColorChannelAsync:(MBLLEDColorChannel)channel
                                onIntensity:(uint8_t)onint
                               offIntensity:(uint8_t)ofint
                                   riseTime:(uint16_t)rtime
                                   fallTime:(uint16_t)ftime
                                     onTime:(uint16_t)otime
                                     period:(uint16_t)period
                                     offset:(uint16_t)offset
                                repeatCount:(uint8_t)repeat
{
    mw_led_flash_params_t params = { 0 };
    params.channel = channel;
    params.mode = 2;
    params.on_intensity = onint;
    params.off_intensity = ofint;
    params.time_rise = rtime;
    params.time_on = otime;
    params.time_fall = ftime;
    params.time_period = period;
    params.time_offset = offset;
    params.repeat_count = repeat;
    return [self.mode writeDataAsync:[NSData dataWithBytes:&params length:sizeof(mw_led_flash_params_t)]];
}

- (BFTask *)setLEDOnAsync:(BOOL)on withOptions:(uint8_t)mode
{
    MBLRegister *reg = on ? self.play : self.stop;
    return [reg writeByteAsync:mode];
}

- (BFTask *)writeSecondaryMode:(NSData *)data
{
    return self.secondaryMode ? [self.secondaryMode writeDataAsync:data] : [BFTask taskWithError:[NSError errorWithDomain:kMBLErrorDomain code:kMBLErrorOperationInvalid userInfo:@{NSLocalizedDescriptionKey : @"LED doesn't have secondaryMode."}]];
}

@end
