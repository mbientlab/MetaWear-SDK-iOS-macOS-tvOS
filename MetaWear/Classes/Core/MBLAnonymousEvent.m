/**
 * MBLAnonymousEvent.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 9/22/17.
 * Copyright 2017 MbientLab Inc. All rights reserved.
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

#import "MBLAnonymousEvent+Private.h"
#import "MBLEvent+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLRegister+Private.h"

@implementation MBLAnonymousEvent

@dynamic identifier;

- (instancetype)initWithRegister:(MBLRegister *)reg
{
    self = [super initWithModule:reg.module registerId:reg.registerId index:reg.index format:reg.format identifier:reg.identifier];
    return self;
}

- (BFTask *)downloadLogAndStopLoggingAsync:(BOOL)stopLogging remainingHandler:(MBLLogProgressHandler)progressHandler
{
    MBLMetaWear *device = self.module.device;
    if (device.state != MBLConnectionStateConnected) {
        NSError *error = [NSError errorWithDomain:kMBLErrorDomain
                                             code:kMBLErrorNotConnected
                                         userInfo:@{NSLocalizedDescriptionKey : @"MetaWear not connected, can't perform operation.  Please connect to MetaWear before downloading log."}];
        return [BFTask taskWithError:error];
    }
    [device incrementCount];
    return [[device.logging downloadLogEvents:self progressHandler:progressHandler] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        [device decrementCount];
        return task;
    }];
}

+ (BFTask *)mustLogError
{
    return [BFTask taskWithError:[NSError errorWithDomain:kMBLErrorDomain
                                                     code:kMBLErrorOperationInvalid
                                                 userInfo:@{NSLocalizedDescriptionKey : @"You can only download log data from anonymous events, please call downloadLogAndStopLoggingAsync:"}]];
}

- (BFTask *)startNotificationsWithHandlerAsync:(MBLNotificationHandler)handler
{
    return [MBLAnonymousEvent mustLogError];
}

- (BFTask *)stopNotificationsAsync
{
    return [MBLAnonymousEvent mustLogError];
}

- (BFTask *)programCommandsToRunOnEventAsync:(MBLVoidHandler)block
{
    return [MBLAnonymousEvent mustLogError];
}

- (BFTask *)eraseCommandsToRunOnEventAsync
{
    return [MBLAnonymousEvent mustLogError];
}

- (BFTask *)startLoggingAsync
{
    return [MBLAnonymousEvent mustLogError];
}

@end
