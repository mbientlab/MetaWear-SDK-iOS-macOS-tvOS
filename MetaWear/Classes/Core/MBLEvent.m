/**
 * MBLEvent.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 10/8/14.
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

#import "MBLEvent+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLNumericFormatter.h"
#import "MBLTriggeredRead.h"
#import "MBLFilter+Private.h"
#import "MBLDataSwitch.h"
#import "MBLConversion.h"
#import "MBLConstants+Private.h"
#import "BFTask+MBLPrivate.h"
#import "MBLDeviceInfo.h"


@interface MBLEvent ()
@property (nonatomic) NSMutableArray *loggingIds;
@property (nonatomic) NSMutableArray *commandIds;
@property (nonatomic) NSMutableArray *commandActivatedRegisters;
@end

@implementation MBLEvent

- (instancetype)initWithModule:(MBLModule *)module registerId:(uint8_t)registerId index:(uint8_t)index format:(MBLFormat *)format
{
    self = [super initWithModule:module registerId:registerId index:index format:format];
    if (self) {
        self.loggingIds = [NSMutableArray array];
        self.commandIds = [NSMutableArray array];
        self.commandActivatedRegisters = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithModule:(MBLModule *)module registerId:(uint8_t)registerId format:(MBLFormat *)format
{
    return [self initWithModule:module registerId:registerId index:0xFF format:format];
}

- (nonnull BFTask *)startNotificationsWithHandlerAsync:(nullable MBLObjectHandler)handler
{
    return [super startNotificationsWithHandlerAsync:handler];
}

- (nonnull BFTask *)stopNotificationsAsync
{
    return [super stopNotificationsAsync];
}

- (BOOL)isNotifying
{
    BOOL __block result;
    assert(![MBLConstants isMetaWearQueue]);
    dispatch_sync([MBLConstants metaWearQueue], ^{
        result = self.isNotifyingImpl;
    });
    return result;
}

- (nonnull BFTask *)programCommandsToRunOnEventAsync:(nonnull MBLVoidHandler)block
{
    MBLMetaWear *device = self.module.device;
    if (device.state != MBLConnectionStateConnected) {
        NSError *error = [NSError errorWithDomain:kMBLErrorDomain
                                             code:kMBLErrorNotConnected
                                         userInfo:@{NSLocalizedDescriptionKey : @"MetaWear not connected, can't perform operation.  Please connect to MetaWear before streaming data."}];
        return [BFTask taskWithError:error];
    }
    
    [device incrementCount];
    return [[[[[BFTask taskFromMetaWearWithBlock:^id{
        if (self.hasCommandsImpl) {
            NSError *error = [NSError errorWithDomain:kMBLErrorDomain
                                                 code:kMBLErrorOperationInvalid
                                             userInfo:@{NSLocalizedDescriptionKey : @"Cannot call programCommandsToRunOnEventAsync: if it's already programmed.  Please call eraseCommandsToRunOnEventAsync first."}];
            return [BFTask taskWithError:error];
        }
        self.hasCommandsImpl = YES;
        return nil;
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [self initializeAsync];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [device.command programCommandsToRunOnEventAsync:self commands:block];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [self activateAsync];
    }] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        [device decrementCount];
        return task;
    }];
}

- (nonnull BFTask *)eraseCommandsToRunOnEventAsync
{
    MBLMetaWear *device = self.module.device;
    if (device.state != MBLConnectionStateConnected) {
        NSError *error = [NSError errorWithDomain:kMBLErrorDomain
                                             code:kMBLErrorNotConnected
                                         userInfo:@{NSLocalizedDescriptionKey : @"MetaWear not connected, can't perform operation.  Please connect to MetaWear before erasing commands."}];
        return [BFTask taskWithError:error];
    }
    
    [device incrementCount];
    return [[[[[BFTask taskFromMetaWearWithBlock:^id{
        if (!self.hasCommandsImpl) {
            NSError *error = [NSError errorWithDomain:kMBLErrorDomain
                                                 code:kMBLErrorOperationInvalid
                                             userInfo:@{NSLocalizedDescriptionKey : @"Cannot call eraseCommandsToRunOnEventAsync since it's not already programmed.  Please call programCommandsToRunOnEventAsync: first."}];
            return [BFTask taskWithError:error];
        }
        self.hasCommandsImpl = NO;
        return nil;
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [self deactivateAsync];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [device.command eraseCommandsToRunOnEventAsync:self];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [self deinitializeAsync];
    }] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        [device decrementCount];
        return task;
    }];
}

- (BOOL)hasCommands
{
    BOOL __block result;
    assert(![MBLConstants isMetaWearQueue]);
    dispatch_sync([MBLConstants metaWearQueue], ^{
        result = self.hasCommandsImpl;
    });
    return result;
}

- (nonnull BFTask *)startLoggingAsync
{
    MBLMetaWear *device = self.module.device;
    if (device.state != MBLConnectionStateConnected) {
        NSError *error = [NSError errorWithDomain:kMBLErrorDomain
                                             code:kMBLErrorNotConnected
                                         userInfo:@{NSLocalizedDescriptionKey : @"MetaWear not connected, can't perform operation.  Please connect to MetaWear before starting log."}];
        return [BFTask taskWithError:error];
    }
    
    [device incrementCount];
    return [[[[[BFTask taskFromMetaWearWithBlock:^id{
        if (self.isLoggingImpl) {
            NSError *error = [NSError errorWithDomain:kMBLErrorDomain
                                                 code:kMBLErrorOperationInvalid
                                             userInfo:@{NSLocalizedDescriptionKey : @"Cannot call startLoggingAsync if it's already logging.  Please call downloadLogAndStopLogging:handler:progressHandler: first."}];
            return [BFTask taskWithError:error];
        }
        self.isLoggingImpl = YES;
        // Clear out the logging id's
        [self.loggingIds removeAllObjects];
        return nil;
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [self initializeAsync];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [self.module.device.logging startLoggingAsyncEvent:self];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [self activateAsync];
    }] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        [device decrementCount];
        return task;
    }];
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
    return [[[BFTask taskFromMetaWearWithBlock:^id{
        if (stopLogging) {
            return [self stopLoggingAsync];
        }
        return nil;
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [device.logging downloadLogEvents:self progressHandler:progressHandler];
    }] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        [device decrementCount];
        return task;
    }];
}

- (BFTask *)downloadLogAndStopLoggingAsync:(BOOL)stopLogging
                           progressHandler:(MBLFloatHandler)progressHandler
{
    MBLLogProgressHandler remainingHandler = nil;
    if (progressHandler) {
        remainingHandler = ^(uint32_t totalEntries, uint32_t remainingEntries) {
            float progress = (float)(totalEntries - remainingEntries) / (float)(totalEntries);
            // Make sure progress is always [0.0,1.0]
            progress = MIN(progress, 1.0);
            progress = MAX(progress, 0.0);
            progressHandler(progress);
        };
    }
    return [self downloadLogAndStopLoggingAsync:stopLogging remainingHandler:remainingHandler];
}

- (BFTask *)downloadLogAndStopLoggingAsync:(BOOL)stopLogging
{
    return [self downloadLogAndStopLoggingAsync:stopLogging progressHandler:nil];
}

- (BFTask<NSNumber *> *)stopLoggingAsync
{
    MBLMetaWear *device = self.module.device;
    if (device.state != MBLConnectionStateConnected) {
        NSError *error = [NSError errorWithDomain:kMBLErrorDomain
                                             code:kMBLErrorNotConnected
                                         userInfo:@{NSLocalizedDescriptionKey : @"MetaWear not connected, can't perform operation.  Please connect to MetaWear before using the API."}];
        return [BFTask taskWithError:error];
    }
    
    [device incrementCount];
    return [[[BFTask taskFromMetaWearWithBlock:^id{
        if (self.isLoggingImpl) {
            self.isLoggingImpl = NO;
            
            return [[[[self deactivateAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
                return [device.logging stopLoggingEvent:self];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
                return [self deinitializeAsync];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
                // Since log downloads take a while, let's save state here
                return [device synchronizeAsync];
            }];
        }
        return nil;
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [device.logging.logLength readAsync];
    }] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        [device decrementCount];
        return task;
    }];
}

- (BOOL)isLogging
{
    BOOL __block result;
    assert(![MBLConstants isMetaWearQueue]);
    dispatch_sync([MBLConstants metaWearQueue], ^{
        result = self.isLoggingImpl;
    });
    return result;
}


typedef struct __attribute__((packed)) {
    uint8_t     filter_id;
    uint8_t     mode:3;
    uint8_t     :5;
    uint16_t    initial_en_value;
} df_pass_param_t;

- (MBLDataSwitch *)conditionalDataSwitch:(BOOL)pass
{
    df_pass_param_t params = {0};
    params.filter_id = 1;
    params.mode = 1;
    params.initial_en_value = pass;
    
    // We make a copy of the formatter because we the filter will remove any offset
    MBLFormat *formatClone = [self.format copy];
    formatClone.offset = 0;
    
    MBLDataSwitch *filter = [[MBLDataSwitch alloc] initWithTrigger:self
                                                  filterParameters:[NSData dataWithBytes:&params length:sizeof(df_pass_param_t)]
                                                            format:formatClone];
    return filter;
}

- (MBLDataSwitch *)countingDataSwitch:(uint16_t)initialCount
{
    df_pass_param_t params = {0};
    params.filter_id = 1;
    params.mode = 2;
    params.initial_en_value = initialCount;
    
    // We make a copy of the formatter because we the filter will remove any offset
    MBLFormat *formatClone = [self.format copy];
    formatClone.offset = 0;
    
    MBLDataSwitch *filter = [[MBLDataSwitch alloc] initWithTrigger:self
                                                  filterParameters:[NSData dataWithBytes:&params length:sizeof(df_pass_param_t)]
                                                            format:formatClone];
    return filter;
}


typedef struct __attribute__((packed)) {
    uint8_t			filter_id;
    uint8_t			countlen:2;
    uint8_t			inputlen:2;
    uint8_t         mode:3;
} df_count_param_t;

- (MBLFilter *)summationOfEvent
{
    const int outputSize = 4;
    if (self.format.length > outputSize) {
        [NSException raise:@"Invalid Filter" format:@"Can't use summation filter with events of size > 4, %d invalid", self.format.length];
    }
    
    df_count_param_t params = {0};
    params.filter_id = 2;
    params.countlen = outputSize - 1;
    params.inputlen = self.format.length - 1;
    params.mode = 0;
    
    // We make a copy of the formatter because we want to force it to 4 byte length, and remove offset
    MBLFormat *formatClone = [self.format copy];
    formatClone.length = outputSize;
    formatClone.offset = 0;
    
    MBLFilter *filter = [[MBLFilter alloc] initWithTrigger:self
                                          filterParameters:[NSData dataWithBytes:&params length:sizeof(df_count_param_t)]
                                                    format:formatClone];
    return filter;
}

- (MBLFilter *)counterOfEvent
{
    df_count_param_t params = {0};
    params.filter_id = 2;
    params.countlen = 4 - 1;
    params.inputlen = 0;
    params.mode = 1;
    
    MBLFilter *filter = [[MBLFilter alloc] initWithTrigger:self
                                          filterParameters:[NSData dataWithBytes:&params length:sizeof(df_count_param_t)]
                                                    format:[[MBLNumericFormatter alloc] initIntWithLength:4 isSigned:NO]];
    return filter;
}


typedef struct __attribute__((packed)) {
    uint8_t     filter_id;
    uint8_t     output_length:2;
    uint8_t     input_length:2;
    uint8_t     average_depth;
} low_mem_average_param_t;

- (MBLFilter *)averageOfEventWithDepth:(uint8_t)depth
{
    // A new vector implemntation showed up in firmware 1.3.4
    NSString *curVersion = self.module.device.deviceInfo.firmwareRevision;
    if (![MBLConstants versionString:curVersion isLessThan:@"1.3.4"]) {
        return [self vectorAverageWithDepth:depth highPass:NO];
    }
    const int outputSize = 4;
    if (self.format.length > outputSize) {
        [NSException raise:@"Invalid Filter" format:@"Can't use event with size > 4, %d invalid", self.format.length];
    }
    
    low_mem_average_param_t params = {0};
    params.filter_id = 3;
    params.input_length = self.format.length - 1;
    params.output_length = outputSize - 1;
    params.average_depth = depth;
    
    // We make a copy of the formatter because we want to force it to 4 byte length and remove offset
    MBLFormat *formatClone = [self.format copy];
    formatClone.length = outputSize;
    formatClone.offset = 0;
    
    MBLFilter *filter = [[MBLFilter alloc] initWithTrigger:self
                                          filterParameters:[NSData dataWithBytes:&params length:sizeof(low_mem_average_param_t)]
                                                    format:formatClone];
    return filter;
}

- (MBLFilter *)highPassOfEventWithDepth:(uint8_t)depth
{
    // High pass filter showed up in firmware 1.3.4
    NSString *curVersion = self.module.device.deviceInfo.firmwareRevision;
    if ([MBLConstants versionString:curVersion isLessThan:@"1.3.4"]) {
        return nil;
    }
    return [self vectorAverageWithDepth:depth highPass:YES];
}

typedef struct __attribute__((packed)) {
    uint8_t      filter_id;
    uint8_t      outputlen:2;
    uint8_t      inputlen:2;
    uint8_t      issigned:1;
    uint8_t      mode:1;
    uint8_t      :2;
    uint8_t      depth;
    uint8_t      vectorlen;
} df_lowmem_avg_param_t;

- (MBLFilter *)vectorAverageWithDepth:(uint8_t)depth highPass:(BOOL)highPass
{
    uint8_t length = self.format.type == MBLFormatTypeArray
        ? self.format.length / self.format.elements
        : self.format.length;
    if (length > 4) {
        [NSException raise:@"Invalid Filter" format:@"Can't use event with size > 4, %d invalid", self.format.length];
    }
    df_lowmem_avg_param_t params = {0};
    params.filter_id = 3;
    params.outputlen = length - 1;
    params.inputlen = length - 1;
    params.issigned = self.format.isSigned;
    params.mode = highPass ? 1 : 0;
    params.depth = depth;
    params.vectorlen = self.format.elements - 1;
    
    // We make a copy of the formatter because we the filter will remove any offset
    MBLFormat *formatClone = [self.format copy];
    formatClone.offset = 0;
    
    MBLFilter *filter = [[MBLFilter alloc] initWithTrigger:self
                                          filterParameters:[NSData dataWithBytes:&params length:sizeof(df_lowmem_avg_param_t)]
                                                    format:formatClone];
    return filter;
}



typedef struct __attribute__((packed)) {
    uint8_t        filter_id;
    uint8_t        is_signed:1;
    uint8_t        datalen:2;
    uint8_t        operation:3;
    uint8_t        mode:2;
    union __attribute__((packed)) {
        uint32_t    u32value[3];
        int32_t     s32value[3];
        uint16_t    u16value[6];
        int16_t     s16value[6];
        uint8_t    u8value[12];
        int8_t     s8value[12];
    };
} mw_comparison_param_t;

- (MBLFilter *)compareEventUsingOperation:(MBLComparisonOperation)op data:(NSArray<NSNumber *> *)data output:(MBLComparisonOutput)output
{
    if (data < 0 && !self.format.isSigned) {
        [NSException raise:@"Invalid data" format:@"This event isn't signed, so we cannot compare to negative values"];
    }
    if ((self.format.length * data.count) > 12) {
        [NSException raise:@"Invalid data" format:@"Too many comparison data points, please reduce"];
    }
    
    mw_comparison_param_t params = {0};
    params.filter_id = 6;
    params.is_signed = self.format.isSigned;
    params.datalen = self.format.length - 1;
    params.operation = op;
    params.mode = output;
    
    if (self.format.isSigned) {
        switch (self.format.length) {
            case 4:
                for (int i = 0; i < data.count; i++) {
                    if (![MBLConversion number:[self.format numberFromDouble:data[i].doubleValue] toInt32:&params.s32value[i]]) {
                        [NSException raise:@"Invalid data" format:@"data %f cannot fit in int32", data[i].doubleValue];
                    }
                }
                break;
            case 2:
                for (int i = 0; i < data.count; i++) {
                    if (![MBLConversion number:[self.format numberFromDouble:data[i].doubleValue] toInt16:&params.s16value[i]]) {
                        [NSException raise:@"Invalid data" format:@"data %f cannot fit in int16", data[i].doubleValue];
                    }
                }
                break;
            case 1:
                for (int i = 0; i < data.count; i++) {
                    if (![MBLConversion number:[self.format numberFromDouble:data[i].doubleValue] toInt8:&params.s8value[i]]) {
                        [NSException raise:@"Invalid data" format:@"data %f cannot fit in int8", data[i].doubleValue];
                    }
                }
                break;
            default:
                [NSException raise:@"Invalid size" format:@"data size %d cannot be processed", self.format.length];
        }
    } else {
        switch (self.format.length) {
            case 4:
                for (int i = 0; i < data.count; i++) {
                    if (![MBLConversion number:[self.format numberFromDouble:data[i].doubleValue] toUint32:&params.u32value[i]]) {
                        [NSException raise:@"Invalid data" format:@"data %f cannot fit in uint32", data[i].doubleValue];
                    }
                }
                break;
            case 2:
                for (int i = 0; i < data.count; i++) {
                    if (![MBLConversion number:[self.format numberFromDouble:data[i].doubleValue] toUint16:&params.u16value[i]]) {
                        [NSException raise:@"Invalid data" format:@"data %f cannot fit in uint16", data[i].doubleValue];
                    }
                }
                break;
            case 1:
                for (int i = 0; i < data.count; i++) {
                    if (![MBLConversion number:[self.format numberFromDouble:data[i].doubleValue] toUint8:&params.u8value[i]]) {
                        [NSException raise:@"Invalid data" format:@"data %f cannot fit in uint8", data[i].doubleValue];
                    }
                }
                break;
            default:
                [NSException raise:@"Invalid size" format:@"data size %d cannot be processed", self.format.length];
        }
    }
    
    MBLFormat *format = nil;
    if (output == MBLComparisonOutputZone || output == MBLComparisonOutputBinary) {
        format = [[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO];
    } else {
        // We make a copy of the formatter because we the filter will remove any offset
        format = [self.format copy];
        format.offset = 0;
    }

    MBLFilter *filter = [[MBLFilter alloc] initWithTrigger:self
                                          filterParameters:[NSData dataWithBytes:&params length:2 + (self.format.length * data.count)]
                                                    format:format];
    return filter;
}

- (MBLFilter *)compareEventUsingOperation:(MBLComparisonOperation)op withData:(double)data
{
    return [self compareEventUsingOperation:op data:@[[NSNumber numberWithDouble:data]] output:MBLComparisonOutputValue];
}


typedef struct __attribute__((packed)) {
    uint8_t			filter_id;
    uint8_t			datalen:3;
    uint8_t         filter_mode:3;
    uint8_t			deltat_ms[4];
} deltat_param_t;

- (MBLFilter *)periodicSampleOfEvent:(uint32_t)periodInMsec
{
    deltat_param_t params = {0};
    params.filter_id = 8;
    if (self.module.device.dataProcessor.moduleInfo.moduleRevision == 0) {
        if (self.format.length > 8) {
            [NSException raise:@"Invalid Filter" format:@"Can't use periodic sample filter with events of size > 8, %d invalid", self.format.length];
        }
        params.datalen = self.format.length - 1;
        params.filter_mode = 0;
    } else {
        params.datalen = 7; // This is now ignored by passthrough output mode
        params.filter_mode = 2;
    }
    uint32_t *tmp = (uint32_t *)params.deltat_ms;
    *tmp = periodInMsec;
    
    // We make a copy of the formatter because we the filter will remove any offset
    MBLFormat *formatClone = [self.format copy];
    formatClone.offset = 0;
    
    MBLFilter *filter = [[MBLFilter alloc] initWithTrigger:self
                                          filterParameters:[NSData dataWithBytes:&params length:sizeof(deltat_param_t)]
                                                    format:formatClone];
    return filter;
}

- (MBLFilter *)differentialSampleOfEvent:(uint32_t)periodInMsec
{
    if (self.format.length > 8) {
        [NSException raise:@"Invalid Filter" format:@"Can't use differential sample filter with events of size > 8, %d invalid", self.format.length];
    }
    
    deltat_param_t params = {0};
    params.filter_id = 8;
    params.datalen = self.format.length - 1;
    params.filter_mode = 1;
    uint32_t *tmp = (uint32_t *)params.deltat_ms;
    *tmp = periodInMsec;
    
    // We make a copy of the formatter because we the filter will remove any offset
    MBLFormat *formatClone = [self.format copy];
    formatClone.offset = 0;

    MBLFilter *filter = [[MBLFilter alloc] initWithTrigger:self
                                          filterParameters:[NSData dataWithBytes:&params length:sizeof(deltat_param_t)]
                                                    format:formatClone];
    return filter;
}


typedef struct __attribute__((packed)) {
    uint8_t     filter_id;
    uint8_t		outputlen:2;
    uint8_t		inputlen:2;
    uint8_t		issigned:1;
    uint8_t		operation;
    uint8_t		paramvalue[4];
    uint8_t     channel_count;
} df_simplemath_param_t;

- (MBLFilter *)modifyEventUsingOperation:(MBLArithmeticOperation)op withData:(double)data
{
    return [self modifyEventUsingOperation:op withData:data outputLength:4];
}

- (MBLFilter *)modifyEventUsingOperation:(MBLArithmeticOperation)op withData:(double)data outputLength:(uint8_t)outputLength
{
    if (self.format.length > 4) {
        [NSException raise:@"Invalid Filter" format:@"Can't use a math filter on data greater than 4 bytes, %d invalid", self.format.length];
    }
    BOOL scaleUnits = NO;
    BOOL forceUnsigned = NO;
    // TODO: Enable these arithmetic modes
    switch (op) {
        case MBLArithmeticOperationNoOp:
            break;
        case MBLArithmeticOperationAdd:
            scaleUnits = YES;
            break;
        case MBLArithmeticOperationMultiply:
            break;
        case MBLArithmeticOperationDivide:
            break;
        case MBLArithmeticOperationModulus:
            scaleUnits = YES;
            break;
        case MBLArithmeticOperationExponent:
            break;
        case MBLArithmeticOperationSquareRoot:
            break;
        case MBLArithmeticOperationLeftShift:
            // TODO: Check if array
            break;
        case MBLArithmeticOperationRightShift:
            // TODO: Check if array
            break;
        case MBLArithmeticOperationSubtract:
            scaleUnits = YES;
            break;
        case MBLArithmeticOperationAbsoluteValue:
            forceUnsigned = YES;
            break;
        case MBLArithmeticOperationConstantOutput:
            scaleUnits = YES;
            break;
    }
    
    df_simplemath_param_t params = {0};
    params.filter_id = 9;
    params.outputlen = outputLength - 1;
    params.inputlen = self.format.length - 1;
    params.issigned = forceUnsigned ? NO : self.format.isSigned;
    params.operation = op;
    params.channel_count = 1 - 1; // TODO: Enable this for array types
    
    if (scaleUnits) {
        if (![MBLConversion number:[self.format numberFromDouble:data] toInt32:(int32_t *)&params.paramvalue]) {
            [NSException raise:@"Invalid data" format:@"data %f cannot fit in int32", data];
        }
    } else {
        *((int32_t *)&params.paramvalue) = (int32_t)round(data);
    }
    
    // We make a copy of the formatter because we want to force remove offset
    MBLFormat *formatClone = [self.format copy];
    formatClone.offset = 0;
    if (forceUnsigned) {
        formatClone.isSigned = NO;
    }
    formatClone.length = outputLength;
    MBLFilter *filter = [[MBLFilter alloc] initWithTrigger:self
                                          filterParameters:[NSData dataWithBytes:&params length:sizeof(df_simplemath_param_t)]
                                                    format:formatClone];
    return filter;
}


typedef struct __attribute__((packed)) {
    uint8_t			filter_id;
    uint8_t			datalen:2;
    uint8_t			delay_count;
} df_delay_param_t;

- (MBLFilter *)delayOfEventWithCount:(uint8_t)count
{
    if (self.format.length > 4) {
        [NSException raise:@"Invalid Filter" format:@"Can't use event with size > 4, %d invalid", self.format.length];
    }
    
    df_delay_param_t params = {0};
    params.filter_id = 0xA;
    params.datalen = self.format.length - 1;
    params.delay_count = count;
    
    // We make a copy of the formatter because we the filter will remove any offset
    MBLFormat *formatClone = [self.format copy];
    formatClone.offset = 0;
    
    MBLFilter *filter = [[MBLFilter alloc] initWithTrigger:self
                                          filterParameters:[NSData dataWithBytes:&params length:sizeof(df_delay_param_t)]
                                                    format:formatClone];
    return filter;
}


typedef struct __attribute__((packed)) {
    uint8_t			filter_id;
    uint8_t			datalen;
    uint8_t			triggermode;
    uint8_t			outputmode;
    int32_t			threshold;
    uint16_t        width;
} df_pulse_detector_param_t;

- (MBLFilter *)pulseDetectorOfEventWithThreshold:(double)threshold width:(uint16_t)width output:(MBLPulseOutput)output
{
    if (self.format.length > 4) {
        [NSException raise:@"Invalid Filter" format:@"Can't use event with size > 4, %d invalid", self.format.length];
    }
    
    df_pulse_detector_param_t params = {0};
    params.filter_id = 0xB;
    params.datalen = self.format.length - 1;
    params.triggermode = 0;
    params.outputmode = output;
    params.width = width;
    
    int32_t	thresholdTmp;
    if (![MBLConversion number:[self.format numberFromDouble:threshold] toInt32:&thresholdTmp]) {
        [NSException raise:@"Invalid data" format:@"threshold %f cannot fit in int32", threshold];
    }
    params.threshold = thresholdTmp;
    
    MBLFormat *format = nil;
    // We make a copy of the formatter because we want to force it to 4 byte length
    switch (output) {
        case MBLPulseOutputArea:
            format = [self.format copy];
            format.length = 4;
            format.isSigned = YES;
            break;
        case MBLPulseOutputPeak:
            format = [self.format copy];
            format.length = 4;
            format.isSigned = YES;
            break;
        case MBLPulseOutputWidth:
            format = [[MBLNumericFormatter alloc] initIntWithLength:4 isSigned:YES];
            break;
        case MBLPulseOutputOnDetection:
            format = [[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO];
            break;
    }
    format.offset = 0;
    
    MBLFilter *filter = [[MBLFilter alloc] initWithTrigger:self
                                          filterParameters:[NSData dataWithBytes:&params length:sizeof(df_pulse_detector_param_t)]
                                                    format:format];
    return filter;
}


typedef struct __attribute__((packed)) {
    uint8_t         filter_id;
    uint8_t         datalen:2;
    uint8_t         issigned:1;
    uint8_t         mode:3;
    uint8_t         delta[4];
} df_deltav_param_t;

- (MBLFilter *)changeOfEventByDelta:(double)delta output:(MBLDeltaValueOutput)output
{
    if (self.format.length > 4) {
        [NSException raise:@"Invalid Filter" format:@"Can't use event with size > 4, %d invalid", self.format.length];
    }
    if (delta < 0) {
        [NSException raise:@"Invalid delta value" format:@"delta cannot be negative"];
    }
    
    df_deltav_param_t params = {0};
    params.filter_id = 0xC;
    params.datalen = self.format.length - 1;
    params.issigned = self.format.isSigned;
    params.mode = output;

    // TODO: This shouldn't be needed...we only support scaling now
    // To get a firmware equivalent unit for delta, we add the requested
    // delta to the threshold and convert that to firmware units, then
    // subtract off the threshold firmware unit value, giving us a proper delta.
    int32_t base;
    int32_t basePlusDelta;
    if (![MBLConversion number:[self.format numberFromDouble:0] toInt32:&base]) {
        [NSException raise:@"Unexpected Error" format:@"Could not encode 0"];
    }
    if (![MBLConversion number:[self.format numberFromDouble:delta] toInt32:&basePlusDelta]) {
        [NSException raise:@"Invalid delta value" format:@"delta %f cannot fit in uint32", delta];
    }
    // Set the difference in the filter params
    if (![MBLConversion number:[NSNumber numberWithInt:basePlusDelta - base] toUint32:(uint32_t *)params.delta]) {
        [NSException raise:@"Invalid delta value" format:@"delta %f cannot fit in uint32", delta];
    }
    
    MBLFormat *format = nil;
    switch (output) {
        case MBLDeltaValueOutputAbsolute:
            format = [self.format copy];
            format.isSigned = YES;
            break;
        case MBLDeltaValueOutputDifferential:
            format = [self.format copy];
            format.isSigned = YES;
            break;
        case MBLDeltaValueOutputBinary:
            format = [[MBLNumericFormatter alloc] initIntWithLength:self.format.length isSigned:YES];
            break;
    }
    format.offset = 0;
    
    MBLFilter *filter = [[MBLFilter alloc] initWithTrigger:self
                                          filterParameters:[NSData dataWithBytes:&params length:sizeof(df_deltav_param_t)]
                                                    format:format];
    return filter;
}


typedef struct __attribute__((packed)) {
    uint8_t         filter_id;
    uint8_t         datalen:2;
    uint8_t         issigned:1;
    uint8_t         mode:3;
    uint8_t         threshold[4];
    uint8_t         hysteresis[2];
} df_thresh_param_t;

- (MBLFilter *)changeOfEventAcrossThreshold:(double)threshold hysteresis:(double)hysteresis output:(MBLThresholdValueOutput)output
{
    if (hysteresis < 0) {
        [NSException raise:@"Invalid hysteresis value" format:@"hysteresis cannot be negative"];
    }
    
    df_thresh_param_t params = {0};
    params.filter_id = 0xD;
    params.datalen = self.format.length - 1;
    params.issigned = self.format.isSigned;
    params.mode = output;
    if (![MBLConversion number:[self.format numberFromDouble:threshold] toInt32:(int32_t *)params.threshold]) {
        [NSException raise:@"Invalid threshold value" format:@"threshold %f cannot fit in int32", threshold];
    }
    if (![MBLConversion number:[self.format numberFromDouble:hysteresis] toUint16:(uint16_t *)params.hysteresis]) {
        [NSException raise:@"Invalid hysteresis value" format:@"hysteresis %f cannot fit in uint16", hysteresis];
    }
    
    // Binary mode forces the output to +-1, so change formatter to handle that
    MBLFormat *format;
    if (output == MBLThresholdValueOutputAbsolute) {
        format = [self.format copy];
    } else {
        format = [[MBLNumericFormatter alloc] initIntWithLength:self.format.length isSigned:YES];
    }
    format.offset = 0;
    
    MBLFilter *filter = [[MBLFilter alloc] initWithTrigger:self
                                          filterParameters:[NSData dataWithBytes:&params length:sizeof(df_thresh_param_t)]
                                                    format:format];
    return filter;
}


typedef struct __attribute__((packed)) {
    uint8_t      filter_id;
    uint8_t      outputlen:2;
    uint8_t      inputlen:2;
    uint8_t      inputcount:3;
    uint8_t      issigned:1;
    uint8_t      mode:3;
} df_rms_param_t;

static const int RMS_MODE_RMS = 0;
static const int RMS_MODE_RSS = 1;

- (MBLFilter *)rmsOfEventWithInputLength:(uint8_t)inputLength inputCount:(uint8_t)inputCount format:(MBLFormat *)format
{
    df_rms_param_t params = {0};
    params.filter_id = 7;
    params.outputlen = 4 - 1;
    params.inputlen = inputLength - 1;
    params.inputcount = inputCount - 1;
    params.issigned = YES;
    params.mode = RMS_MODE_RMS;
    
    MBLFilter *filter = [[MBLFilter alloc] initWithTrigger:self
                                          filterParameters:[NSData dataWithBytes:&params length:sizeof(df_rms_param_t)]
                                                    format:format];
    return filter;
}

- (MBLFilter *)rssOfEventWithInputLength:(uint8_t)inputLength inputCount:(uint8_t)inputCount format:(MBLFormat *)format
{
    df_rms_param_t params = {0};
    params.filter_id = 7;
    params.outputlen = 4 - 1;
    params.inputlen = inputLength - 1;
    params.inputcount = inputCount - 1;
    params.issigned = YES;
    params.mode = RMS_MODE_RSS;
    
    MBLFilter *filter = [[MBLFilter alloc] initWithTrigger:self
                                          filterParameters:[NSData dataWithBytes:&params length:sizeof(df_rms_param_t)]
                                                    format:format];
    return filter;
}


- (MBLEvent *)readDataOnEvent:(MBLData *)data
{
    return [[MBLTriggeredRead alloc] initWithData:data trigger:self];
}

@end
