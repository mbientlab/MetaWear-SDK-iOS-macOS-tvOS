/**
 * MBLNeopixel.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 8/12/14.
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

#import "MBLNeopixel+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLRegister+Private.h"
#import "MBLNeopixelStrand+Private.h"
#import "MBLMetaWearManager+Private.h"

static const uint8_t MW_NEOPIXEL_MAXSTRANDS = 3;

@interface MBLNeopixel()
@property (nonatomic) MBLRegister *initialize;
@property (nonatomic) MBLRegister *hold;
@property (nonatomic) MBLRegister *clear;
@property (nonatomic) MBLRegister *pixel;
@property (nonatomic) MBLRegister *rotate;
@property (nonatomic) MBLRegister *deinitialize;

@property (nonatomic) NSMutableArray *strands;
@end

@implementation MBLNeopixel

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        self.initialize = [[MBLRegister alloc] initWithModule:self registerId:0x1 format:[[MBLFormat alloc] initEncodedDataWithLength:4]];
        self.hold = [[MBLRegister alloc] initWithModule:self registerId:0x2 format:[[MBLFormat alloc] initEncodedDataWithLength:2]];
        self.clear = [[MBLRegister alloc] initWithModule:self registerId:0x3 format:[[MBLFormat alloc] initEncodedDataWithLength:0]];
        self.pixel = [[MBLRegister alloc] initWithModule:self registerId:0x4 format:[[MBLFormat alloc] initEncodedDataWithLength:5]];
        self.rotate = [[MBLRegister alloc] initWithModule:self registerId:0x5 format:[[MBLFormat alloc] initEncodedDataWithLength:5]];
        self.deinitialize = [[MBLRegister alloc] initWithModule:self registerId:0x6 format:[[MBLFormat alloc] initEncodedDataWithLength:0]];
        
        self.strands = [NSMutableArray array];
        for (int i = 0; i < MW_NEOPIXEL_MAXSTRANDS; i++) {
            [self.strands addObject:[NSNumber numberWithBool:NO]];
        }
    }
    return self;
}

- (MBLNeopixelStrand *)strandWithColor:(MBLColorOrdering)color
                                 speed:(MBLStrandSpeed)speed
                                   pin:(uint8_t)pin
                                length:(uint8_t)length
{
    return [[MBLNeopixelStrand alloc] initWithNeopixel:self color:color speed:speed pin:pin length:length];
}

- (BFTask *)initializeStrand:(MBLNeopixelStrand *)strand
{
    return [BFTask taskFromMetaWearWithBlock:^id{
        if (strand.index == 0xFF) {
            for (int i = 0; i < MW_NEOPIXEL_MAXSTRANDS; i++) {
                if (![self.strands[i] boolValue]) {
                    strand.index = i;
                    self.strands[i] = [NSNumber numberWithBool:YES];
                    
                    uint8_t data[] = { strand.index, ((uint8_t)strand.speed << 2) | strand.color, strand.pin, strand.length };
                    int dataSize = sizeof(data) / sizeof(data[0]);
                    return [self.initialize writeDataAsync:[NSData dataWithBytes:data length:dataSize]];
                }
            }
            NSError *error = [NSError errorWithDomain:kMBLErrorDomain
                                                 code:kMBLErrorInsufficientMemory
                                             userInfo:@{NSLocalizedDescriptionKey : @"MetaWear out of memory, can't perform action.  Reset the MetaWear and use no more than 255 neopixel stands"}];
            return [BFTask taskWithError:error];
        }
        return nil;
    }];
}

- (BFTask *)deinitializeStrand:(MBLNeopixelStrand *)strand
{
    return [BFTask taskFromMetaWearWithBlock:^id{
        if (strand.index != 0xFF) {
            uint8_t data[] = { strand.index };
            int dataSize = sizeof(data) / sizeof(data[0]);
            
            self.strands[strand.index] = [NSNumber numberWithBool:NO];
            strand.index = 0xFF;
            return [self.deinitialize writeDataAsync:[NSData dataWithBytes:data length:dataSize]];
        }
        return nil;
    }];
}

- (BFTask *)deallocDeinitializeStrand:(MBLNeopixelStrand *)strand
{
    // This is special because we know strand is currently being deallocated
    // so we must cache it's index value now!  Can't wait until we are on the
    // MetaWear queue (the only place were you really should access or set state)
    uint8_t index = strand.index;
    if (index != 0xFF) {
        uint8_t data[] = { index };
        int dataSize = sizeof(data) / sizeof(data[0]);
        return [[self.deinitialize writeDataAsync:[NSData dataWithBytes:data length:dataSize]] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
            // This must go on metawear queue since we are modifying collection
            self.strands[index] = [NSNumber numberWithBool:NO];
            return nil;
        }];
    }
    return [BFTask taskWithResult:nil];
}

- (BFTask *)holdStrandAtIndex:(uint8_t)index withEnable:(BOOL)enable
{
    uint8_t data[] = { index, enable };
    int dataSize = sizeof(data) / sizeof(data[0]);
    return [self.hold writeDataAsync:[NSData dataWithBytes:data length:dataSize]];
}

- (BFTask *)clearStrandAtIndex:(uint8_t)index startPixel:(uint8_t)start endPixel:(uint8_t)end
{
    uint8_t data[] = { index, start, end };
    int dataSize = sizeof(data) / sizeof(data[0]);
    return [self.clear writeDataAsync:[NSData dataWithBytes:data length:dataSize]];
}

- (BFTask *)setPixelAtIndex:(uint8_t)index pixel:(uint8_t)pixel color:(MBLColor *)color;
{
    CGFloat red, blue, green;
#if TARGET_OS_IOS || TARGET_OS_TV
    [color getRed:&red green:&green blue:&blue alpha:nil];
#else
    NSColor *rgbColor = [color colorUsingColorSpace:[NSColorSpace sRGBColorSpace]];
    red = rgbColor.redComponent;
    green = rgbColor.greenComponent;
    blue = rgbColor.blueComponent;
#endif
    uint8_t data[] = { index, pixel, red * 0xFF, green * 0xFF, blue * 0xFF };
    int dataSize = sizeof(data) / sizeof(data[0]);
    return [self.pixel writeDataAsync:[NSData dataWithBytes:data length:dataSize]];
}

- (BFTask *)rotateStrandAtIndex:(uint8_t)index direction:(MBLRotationDirection)direction repetitions:(uint8_t)repetitions period:(uint16_t)period
{
    uint8_t data[] = { index, direction, repetitions, (period & 0xff), (period >> 8) };
    int dataSize = sizeof(data) / sizeof(data[0]);
    return [self.rotate writeDataAsync:[NSData dataWithBytes:data length:dataSize]];
}

@end
