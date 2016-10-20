/**
 * MBLFilter.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 10/9/14.
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

#import "MBLFilter+Private.h"
#import "MBLEntityEvent+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLMetaWearManager+Private.h"
#import "MBLTriggeredRead.h"
#import "MBLDependentData.h"
#import "BFTask+Private.h"

typedef struct __attribute__((packed)) {
    uint8_t				module_id;
    uint8_t				register_id;
    uint8_t				index;
    uint8_t				offset:5;
    uint8_t				len:3;
} filter_param_t;

@interface MBLFilter ()
@property (nonatomic) MBLEvent *trigger;
@property (nonatomic, weak) MBLData *stateSetResetGet; // The data hold strong reference to us
@property (nonatomic) MBLRegister *parameterModify;
@property (nonatomic) NSData *parameters;
@end


@implementation MBLFilter

- (instancetype)initWithTrigger:(MBLEvent *)trigger
               filterParameters:(NSData *)parameters
                         format:(MBLFormat *)format
{
    // Since all filters get their data through the single processingNotify register in
    // the data processing module, we create a dummy register which is optionally notified
    // when we see a global notification which matches our filter id
    self = [super initWithModule:trigger.module.device.dataProcessor registerId:0x3 addEntityParameters:[NSData data] format:format];
    if (self) {
        self.trigger = trigger;
        MBLDependentData *stateSetResetGet = [[MBLDependentData alloc] initWithModule:trigger.module.device.dataProcessor registerId:0x4 format:format dependent:self];
        self.stateSetResetGet = stateSetResetGet;
        self.parameterModify = [[MBLRegister alloc] initWithModule:trigger.module.device.dataProcessor registerId:0x5 format:[[MBLFormat alloc] initEncodedDataWithLength:18]];
        self.parameters = parameters;
    }
    return self;
}

- (NSData *)generateAddFilterParameters
{
    filter_param_t data = {0};
    data.module_id = self.trigger.module.moduleInfo.moduleId;
    data.register_id = self.trigger.registerId;
    data.index = self.trigger.index;
    data.offset = self.trigger.format.offset;
    data.len = self.trigger.format.length - 1;
    
    NSMutableData *addFilterData = [NSMutableData dataWithBytes:&data length:sizeof(filter_param_t)];
    [addFilterData appendData:self.parameters];
    return addFilterData;
}

- (BFTask *)resetStateWithDataAsync:(NSData *)data
{
    if (self.index == 0xFF) {
        NSError *error = [NSError errorWithDomain:kMBLErrorDomain
                                             code:kMBLErrorOperationInvalid
                                         userInfo:@{NSLocalizedDescriptionKey : @"Filter must be initialized before being reset."}];
        return [BFTask taskWithError:error];
    }
    
    uint8_t uid = self.index;
    NSMutableData *params = [NSMutableData dataWithBytes:&uid length:1];
    if (data) {
        [params appendData:data];
    }
    return [self.stateSetResetGet writeDataAsync:params];
}

- (BFTask *)resetParametersWithData:(NSData *)data
{
    if (self.index == 0xFF) {
        NSError *error = [NSError errorWithDomain:kMBLErrorDomain
                                             code:kMBLErrorOperationInvalid
                                         userInfo:@{NSLocalizedDescriptionKey : @"Filter must be initialized before being reset."}];
        return [BFTask taskWithError:error];
    }
    
    uint8_t uid = self.index;
    NSMutableData *params = [NSMutableData dataWithBytes:&uid length:1];
    if (data) {
        [params appendData:data];
    }
    return [self.parameterModify writeDataAsync:params];
}

- (BFTask *)resetAsync
{
    return [self resetStateWithDataAsync:nil];
}

typedef struct __attribute__((packed)) {
    uint8_t         filter_id;
    uint8_t         datalen:5;
} df_buffer_param_t;

- (MBLEvent *)periodicReadWithPeriod:(uint32_t)period
{
    df_buffer_param_t params = {0};
    params.filter_id = 0xF;
    params.datalen = self.format.length - 1;
    
    MBLFilter *filter = [[MBLFilter alloc] initWithTrigger:self
                                          filterParameters:[NSData dataWithBytes:&params length:sizeof(df_buffer_param_t)]
                                                    format:self.format];

    return [[MBLTriggeredRead alloc] initWithData:filter.stateSetResetGet period:period eventCount:0xFFFF];
}

- (BFTask *)performAsyncInitialization
{
    // Setup trigger so that its index is filled in and its module is enabled
    return [[[self.trigger initializeAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        // Set the addEntityParams now that trigger is ready
        self.addEntityParameters = [self generateAddFilterParameters];
        return [super performAsyncInitialization];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        self.stateSetResetGet.index = self.index;
        return nil;
    }];
}

- (BFTask *)performAsyncDeinitialization
{
    return [[super performAsyncDeinitialization] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        self.stateSetResetGet.index = 0xFF;
        // Remove the addEntityParams
        self.addEntityParameters = [NSData data];
        // Un-setup trigger
        return [self.trigger deinitializeAsync];
    }];
}

- (BFTask *)performAsyncActivation
{
    return [self.trigger activateAsync];
}

- (BFTask *)performAsyncDeactivation
{
    return [self.trigger deactivateAsync];
}

@end
