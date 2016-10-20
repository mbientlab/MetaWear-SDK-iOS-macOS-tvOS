/**
 * MBLNeopixelStrand.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 3/2/15.
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

#import "MBLNeopixelStrand+Private.h"
#import "MBLNeopixel+Private.h"
#import "MBLModule+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLLogger.h"

@interface MBLNeopixelStrand ()
@property (nonatomic, weak) MBLNeopixel *neopixel;
@property (nonatomic) MBLColorOrdering color;
@property (nonatomic) MBLStrandSpeed speed;
@property (nonatomic) uint8_t pin;
@property (nonatomic) uint8_t length;
@property (nonatomic) uint8_t index;
@end

@implementation MBLNeopixelStrand

- (instancetype)initWithNeopixel:(MBLNeopixel *)neopixel color:(MBLColorOrdering)color speed:(MBLStrandSpeed)speed pin:(uint8_t)pin length:(uint8_t)length
{
    self = [super init];
    if (self) {
        self.neopixel = neopixel;
        self.color = color;
        self.speed = speed;
        self.pin = pin;
        self.length = length;
        self.index = 0xFF;
    }
    return self;
}

- (void)dealloc
{
    if (self.index != 0xFF) {
        if (self.neopixel.device.state == MBLConnectionStateConnected) {
            MBLLog(MBLLogLevelWarning, @"please call deinitialize before releasing MBLNeopixelStrand objets");
        } else {
            MBLLog(MBLLogLevelWarning, @"please call deinitialize before releasing MBLNeopixelStrand objets, please reset MetaWear to properly recover");
        }
        [self.neopixel deallocDeinitializeStrand:self];
    }
}

- (BFTask *)initializeAsync
{
    return [self.neopixel initializeStrand:self];
}

- (BFTask *)deinitializeAsync
{
    return [self.neopixel deinitializeStrand:self];
}

- (BFTask *)setPixelAsync:(uint8_t)pixel color:(MBLColor *)color
{
    if (self.index == 0xFF) {
        [NSException raise:NSGenericException format:@"Please call initialize before using MBLNeopixelStrand objets"];
    }
    if (pixel >= self.length) {
        [NSException raise:NSRangeException format:@"Pixel index out of range. %d exceeds max %d", pixel, self.length - 1];
    }
    
    return [self.neopixel setPixelAtIndex:self.index pixel:pixel color:color];
}

- (BFTask *)setRainbowWithHoldAsync:(BOOL)hold
{
    if (self.index == 0xFF) {
        [NSException raise:NSGenericException format:@"Please call initialize before using MBLNeopixelStrand objets"];
    }
    
    float delta = 2.0 * M_PI / (float)self.length;
    BFTask *head = [BFTask taskWithResult:nil];
    if (hold) {
        head = [head continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
            return [self holdStrandWithEnableAsync:YES];
        }];
    }
    for (int i = 0; i < self.length; i++) {
        float step = i * delta;
        float red = cosf(step);
        float green = cosf(step + ((2.0 * M_PI) / 3.0));
        float blue = cosf(step + ((4.0 * M_PI) / 3.0));
        head = [head continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
            return [self setPixelAsync:i color:[MBLColor colorWithRed:red green:green blue:blue alpha:1.0]];
        }];
    }
    if (hold) {
        head = [head continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
            return [self holdStrandWithEnableAsync:NO];
        }];
    }
    return head;
}

- (BFTask *)clearFromStartPixelAsync:(uint8_t)startPixel endPixel:(uint8_t)endPixel
{
    if (self.index == 0xFF) {
        [NSException raise:NSGenericException format:@"Please call initialize before using MBLNeopixelStrand objets"];
    }
    if (startPixel > endPixel) {
        [NSException raise:NSRangeException format:@"startPixel (%d) can't be greater than endPixel (%d)", startPixel, endPixel];
    }
    if (endPixel >= self.length) {
        [NSException raise:NSRangeException format:@"endPixel (%d) index out of range (%d)", endPixel, self.length - 1];
    }
    
    return [self.neopixel clearStrandAtIndex:self.index startPixel:startPixel endPixel:endPixel];
}

- (BFTask *)clearAllPixelsAsync
{
    return [self clearFromStartPixelAsync:0 endPixel:self.length - 1];
}

- (BFTask *)holdStrandWithEnableAsync:(BOOL)enable
{
    if (self.index == 0xFF) {
        [NSException raise:NSGenericException format:@"Please call initialize before using MBLNeopixelStrand objets"];
    }
    
    return [self.neopixel holdStrandAtIndex:self.index withEnable:enable];
}

- (BFTask *)rotateStrandWithDirectionAsync:(MBLRotationDirection)direction repetitions:(uint8_t)repetitions period:(uint16_t)period
{
    if (self.index == 0xFF) {
        [NSException raise:NSGenericException format:@"Please call initialize before using MBLNeopixelStrand objets"];
    }
    
    return [self.neopixel rotateStrandAtIndex:self.index direction:direction repetitions:repetitions period:period];
}

@end
