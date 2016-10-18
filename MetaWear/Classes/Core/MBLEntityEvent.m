/**
 * MBLEntityEvent.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 12/3/15.
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


#import "MBLEntityEvent+Private.h"
#import "MBLEntityModule+Private.h"
#import "MBLDataSample+Private.h"
#import "MBLLogger.h"

@interface MBLEntityEvent ()
@property (nonatomic) NSData *addEntityParameters;
@end

@implementation MBLEntityEvent

- (instancetype)initWithModule:(MBLEntityModule *)module
                    registerId:(uint8_t)registerId
           addEntityParameters:(NSData *)addEntityParameters
                        format:(MBLFormat *)format
{
    // Since all filters get their data through the single timerNotification register in
    // the timer module, we create a dummy register which is optionally notified
    // when we see a global notification which matches our filter id
    self = [super initWithModule:module registerId:registerId format:format];
    if (self) {
        self.addEntityParameters = addEntityParameters;
    }
    return self;
}

- (BFTask *)isStateValid
{
    MBLEntityModule *module = (MBLEntityModule *)self.module;
    return [[module.addEntity readForcedIndexAsync:self.index] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        MBLDataSample *result = task.result;
        NSData *actualData = result.data;
        NSData *expectedData = self.addEntityParameters;
        if (actualData.length >= expectedData.length) {
            if ([expectedData isEqualToData:[actualData subdataWithRange:NSMakeRange(0, expectedData.length)]]) {
                return [BFTask taskWithResult:@YES];
            }
        }
        MBLLog(MBLLogLevelInfo, @"%@: Entity[%d] expected != actual (%@ != %@)", self.module, self.index, expectedData, actualData);
        return [BFTask taskWithResult:@NO];
    }];
}

- (BFTask *)performAsyncInitialization
{
    MBLEntityModule *module = (MBLEntityModule *)self.module;
    return [module performAsyncInitializationForEntity:self];
}

- (BFTask *)performAsyncDeinitialization
{
    MBLEntityModule *module = (MBLEntityModule *)self.module;
    return [module performAsyncDeinitializationForEntity:self];
}

- (BFTask *)performAsyncActivation
{
    MBLEntityModule *module = (MBLEntityModule *)self.module;
    return [module performAsyncActivationForEntity:self];
}

- (BFTask *)performAsyncDeactivation
{
    MBLEntityModule *module = (MBLEntityModule *)self.module;
    return [module performAsyncDeactivationForEntity:self];
}

- (BFTask *)performAsyncStartNotifications
{
    MBLEntityModule *module = (MBLEntityModule *)self.module;
    return [[module startNotificationsForEntity:self] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [super performAsyncStartNotifications];
    }];
}

- (BFTask *)performAsyncStopNotificationsAsync
{
    MBLEntityModule *module = (MBLEntityModule *)self.module;
    return [[super performAsyncStopNotificationsAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [module stopNotificationsAsyncForEntity:self];
    }];
}

@end
