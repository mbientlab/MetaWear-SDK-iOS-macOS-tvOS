/**
 * MBLTestDebug.m
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

#import "MBLTestDebug.h"
#import "MBLMetaWear.h"
#import "MBLRegister+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLTimer+Private.h"
#import "MBLNumericFormatter.h"
#import "MBLNumericData+Private.h"
#import "BFTask+MBLExtensions.h"
#import "MBLMetaWearManager+Private.h"
#import "MBLLogger.h"

@interface MBLTestDebug ()
@property (nonatomic) MBLRegister *reset;
@property (nonatomic) MBLRegister *bootloader;
@property (nonatomic) MBLRegister *notificationSpoofer;
@property (nonatomic) MBLRegister *keyRegister;
@property (nonatomic) MBLRegister *delayedReset;
@property (nonatomic) MBLRegister *gapDisconnect;
@property (nonatomic) MBLRegister *powersaveOnReset;
@property (nonatomic) MBLRegister *appInvalidate;
@end

@implementation MBLTestDebug

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        self.reset = [[MBLRegister alloc] initWithModule:self registerId:0x1 format:[[MBLFormat alloc] initEncodedDataWithLength:0]];
        self.bootloader = [[MBLRegister alloc] initWithModule:self registerId:0x2 format:[[MBLFormat alloc] initEncodedDataWithLength:0]];
        self.notificationSpoofer = [[MBLRegister alloc] initWithModule:self registerId:0x3 format:[[MBLFormat alloc] initEncodedDataWithLength:18]];
        self.keyRegister = [[MBLRegister alloc] initWithModule:self registerId:0x4 format:[[MBLNumericFormatter alloc] initIntWithLength:4 isSigned:NO]];
        self.delayedReset = [[MBLRegister alloc] initWithModule:self registerId:0x5 format:[[MBLFormat alloc] initEncodedDataWithLength:0]];
        self.gapDisconnect = [[MBLRegister alloc] initWithModule:self registerId:0x6 format:[[MBLFormat alloc] initEncodedDataWithLength:0]];
        if (moduleInfo.moduleRevision >= 1) {
            self.powersaveOnReset = [[MBLRegister alloc] initWithModule:self registerId:0x7 format:[MBLFormat writeOnly]];
            self.appInvalidate = [[MBLRegister alloc] initWithModule:self registerId:0x8 format:[MBLFormat writeOnly]];
        }
    }
    return self;
}

- (void)setMagicKey:(uint32_t)magicKey
{
    while (magicKey == 0) {
        magicKey = arc4random();
    }
    _magicKey = magicKey;
}

- (BFTask *)resetDevice
{
    self.triggerDisconnectInProgress = YES;
    return [self.reset writeDataAsync:nil];
}

- (BFTask *)resetDeviceAfterGarbageCollect
{
    self.triggerDisconnectInProgress = YES;
    return [[self.delayedReset writeDataAsync:nil] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {;
        return [self.gapDisconnect writeDataAsync:nil];
    }];
}

- (BFTask *)jumpToBootloader
{
    self.triggerDisconnectInProgress = YES;
    return [self.bootloader writeDataAsync:nil];
}

- (BFTask *)triggerDisconnect
{
    self.triggerDisconnectInProgress = YES;
    return [self.gapDisconnect writeDataAsync:nil];
}

- (BFTask<NSNumber *> *)isGuestApplicationAsync
{
    return [[self.keyRegister readAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        // If another app tries to connect to this MetaWear it will issue this same
        // command, so lets track any unexpected reads of the key register and use that
        // as an indicator someone is trying to use 2 apps simultaneously wihch is very
        // dangerous and unsupported.  Our only option is to disconnect this app
        MBLMetaWear *device = self.device;
        [self.keyRegister addNotificationWithExecutor:[BFExecutor metaWearExecutor] handler:^(id _Nullable obj, NSError * _Nullable error) {
            if (obj) {
                MBLLog(MBLLogLevelWarning, @"Simultaneous Connection - Disconnecting %@ because another App has initiated a connection", device);
                [[MBLMetaWearManager sharedManager] disconnectMetaWear:device fromPeripheralSide:NO];
            }
        }];
        
        MBLNumericData *obj = t.result;
        if (obj.value.unsignedIntValue) {
            // Write magic value exisits, see if it matches!
            if (obj.value.unsignedIntValue != self.magicKey) {
                MBLLog(MBLLogLevelWarning, @"Guest Connection - Use caution to avoid causing data loss for other applications");
                return @YES;
            }
        } else {
            // Write magic value since none was present
            uint32_t key = self.magicKey;
            [self.keyRegister writeDataAsync:[NSData dataWithBytes:&key length:sizeof(key)]];
        }
        return @NO;
    }];
}

- (NSData *)writeKeyRegisterCommand
{
    uint8_t header[] = { self.moduleInfo.moduleId, self.keyRegister.registerId };
    int headerSize = sizeof(header) / sizeof(header[0]);
    NSMutableData *data = [NSMutableData dataWithBytes:header length:headerSize];
    uint32_t key = self.magicKey;
    [data appendData:[NSData dataWithBytes:&key length:sizeof(key)]];
    return data;
}

- (MBLEvent *)spoofEvent:(MBLFormat *)format
{
    return [[MBLEvent alloc] initWithModule:self.device.timer registerId:0xFF format:format];
}

- (BFTask *)spoofData:(NSArray *)data notification:(BOOL)notification
{
    NSMutableArray *tasks = [NSMutableArray array];
    uint8_t header[] = { 0x0C, 0xFF, notification };
    for (NSString *byteArray in data) {
        NSArray *bytes = [byteArray componentsSeparatedByString:@"-"];
        NSMutableData *mutableData = [NSMutableData dataWithBytes:header length:3];
        for (NSString *byte in bytes) {
            unsigned tmp;
            [[NSScanner scannerWithString:byte] scanHexInt:&tmp];
            [mutableData appendBytes:&tmp length:1];
        }
        [tasks addObject:[self.notificationSpoofer writeDataAsync:mutableData]];
    }
    return [BFTask taskForCompletionOfAllTasks:tasks];
}

- (BFTask *)spoofRawData:(NSArray *)data
{
    NSMutableArray *tasks = [NSMutableArray array];
    for (NSString *byteArray in data) {
        NSArray *bytes = [byteArray componentsSeparatedByString:@"-"];
        NSMutableData *mutableData = [NSMutableData data];
        for (NSString *byte in bytes) {
            unsigned tmp;
            [[NSScanner scannerWithString:byte] scanHexInt:&tmp];
            [mutableData appendBytes:&tmp length:1];
        }
        [tasks addObject:[self.notificationSpoofer writeDataAsync:mutableData]];
    }
    return [BFTask taskForCompletionOfAllTasks:tasks];
}

- (BFTask *)enterPowersaveOnReset
{
    return [self.powersaveOnReset writeDataAsync:nil];
}

- (BFTask *)invalidateAppImage
{
    return [self.appInvalidate writeDataAsync:nil];
}

@end
