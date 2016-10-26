/**
 * MBLMacro.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 1/27/15.
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

#import "MBLMacro.h"
#import "MBLRegister+Private.h"
#import "MBLModule+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLLED.h"
#import "MBLNumericFormatter.h"
#import "MBLDataSample.h"
#import "MBLMetaWearManager+Private.h"
#import "BFTask+MBLPrivate.h"


@interface MBLMacro ()
@property (nonatomic) MBLRegister *addMacro;
@property (nonatomic) MBLRegister *addCommand;
@property (nonatomic) MBLRegister *endMacro;
@property (nonatomic) MBLRegister *executeMacro;
@property (nonatomic) MBLRegister *macroFinishNotificationEnable;
@property (nonatomic) MBLRegister *macroFinishNotification;
@property (nonatomic) MBLRegister *eraseAll;
@property (nonatomic) MBLRegister *addCommandPartial;
@end

@implementation MBLMacro

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        self.globalEnable = [[MBLRegister alloc] initWithModule:self registerId:0x1 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
        self.addMacro = [[MBLRegister alloc] initWithModule:self registerId:0x2 format:[[MBLFormat alloc] initEncodedDataWithLength:3]];
        self.addCommand = [[MBLRegister alloc] initWithModule:self registerId:0x3 format:[[MBLFormat alloc] initEncodedDataWithLength:18]];
        self.endMacro = [[MBLRegister alloc] initWithModule:self registerId:0x4 format:[MBLFormat writeOnly]];
        self.executeMacro = [[MBLRegister alloc] initWithModule:self registerId:0x5 format:[MBLFormat writeOnly]];
        self.macroFinishNotificationEnable = [[MBLRegister alloc] initWithModule:self registerId:0x6 format:[MBLFormat writeOnly]];
        
        self.macroFinishNotification = [[MBLRegister alloc] initWithModule:self registerId:0x7 format:[[MBLFormat alloc] initEncodedDataWithLength:1]];
        self.eraseAll = [[MBLRegister alloc] initWithModule:self registerId:0x8 format:[MBLFormat writeOnly]];
        self.addCommandPartial = [[MBLRegister alloc] initWithModule:self registerId:0x9 format:[MBLFormat writeOnly]];
        
        if (moduleInfo.moduleRevision == 0) {
            self.addMacro.needsResponse = YES;
            self.addCommand.needsResponse = YES;
            self.endMacro.needsResponse = YES;
        }
        
        self.addMacro.writeResponds = YES;
        //self.addCommand.needsResponse = YES;
    }
    return self;
}

- (void)programConfigurationWithHandler:(MBLVoidHandler)handler
{
    // Sniff the configuration fun
    NSMutableArray *commands = [NSMutableArray array];
    [self.device startSnifferWithHandler:^(NSData *data, NSError *error) {
        [commands addObject:data];
    }];
    
    // Do the actual setup
    [self.device.configuration runOnDeviceBoot:self.device];

    // Wait for all setup code to finish
    [[self.device waitForCommandCompletion] successOnMetaWear:^(id result) {
        // Stop sniffing
        [self.device stopSniffer];
        
        if (commands.count) {
            // Make sure the key register will persist a reset
            [commands insertObject:[self.device.testDebug writeKeyRegisterCommand] atIndex:0];
            
            [[[self.addMacro writeByteAsync:0x1] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
                //uint8_t uid = *(uint8_t *)obj.data.bytes;
                for (NSData *command in commands) {
                    if (command.length > 18) {
                        [self.addCommandPartial writeDataAsync:[command subdataWithRange:NSMakeRange(0, 2)]];
                        [self.addCommand writeDataAsync:[command subdataWithRange:NSMakeRange(2, command.length - 2)]];
                    } else {
                        [self.addCommand writeDataAsync:command];
                    }
                }
                [self.endMacro writeDataAsync:nil];
                // Wait for the macro to be added in all nice by doing a dummy read
                return [self.addMacro readForcedIndexAsync:0];
            }] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                if (handler) {
                    handler();
                }
                return nil;
            }];
        } else {
            if (handler) {
                handler();
            }
        }
    }];
}

- (BFTask *)programMacroWithCommands:(MBLVoidHandler)block
{
    NSMutableArray *commands = [NSMutableArray array];
    uint8_t __block macroId = 0xFF;
    
    return [[[[[[[[[self initializeAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [self.device waitForSimulatorTurn];
    }] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [self.addMacro writeByteAsync:0x0];
    }] continueWithExecutor:[BFExecutor simulatorExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
        MBLDataSample *result = task.result;
        macroId = *(uint8_t *)result.data.bytes;
        [self.device startSimulationWithHandler:^(uint8_t module, uint8_t opcode, NSData *parameters) {
            uint8_t data[] = { module, opcode };
            NSMutableData *command = [NSMutableData dataWithBytes:&data length:2];
            [command appendData:parameters];
            [commands addObject:command];
        }];
        block();
        return nil;
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [self.device waitForSimulatorCompletion];
    }] continueWithExecutor:[BFExecutor metaWearExecutor] withBlock:^id _Nullable(BFTask * _Nonnull task) {
        for (NSData *command in commands) {
            if (command.length > 18) {
                [self.addCommandPartial writeDataAsync:[command subdataWithRange:NSMakeRange(0, 2)]];
                [self.addCommand writeDataAsync:[command subdataWithRange:NSMakeRange(2, command.length - 2)]];
            } else {
                [self.addCommand writeDataAsync:command];
            }
        }
        [self.endMacro writeDataAsync:nil];
        // Wait for the macro to be added in all nice by doing a dummy read
        return [self.addMacro readForcedIndexAsync:0];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [self activateAsync];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return  [BFTask taskWithResult:[NSNumber numberWithUnsignedChar:macroId]];
    }] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        [self.device stopSimulation];
        return task;
    }];
}

- (BFTask *)executeMacro:(uint8_t)macroId
{
    return [self.executeMacro writeByteAsync:macroId];
}

- (void)clearAllMacros
{
    [self.eraseAll writeDataAsync:nil];
}

@end
