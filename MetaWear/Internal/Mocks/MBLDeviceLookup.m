/**
 * MBLDeviceLookup.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 3/22/16.
 * Copyright 2016 MbientLab Inc. All rights reserved.
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

#import "MBLDeviceLookup.h"
#import "MBLLogger.h"

@implementation MBLDeviceLookup

+ (NSString *)metawearModelString
{
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    NSString *model = environment[@"METAWEAR_MODEL_UNDER_TEST"];
    assert(model && ![model isEqualToString:@""]);
    return model;
}

+ (MBLModel)metawearModel
{
    NSString *modelString = [MBLDeviceLookup metawearModelString];
    MBLModel model;
    if ([modelString isEqualToString:@"R"]) {
        model = MBLModelMetaWearR;
    } else if ([modelString isEqualToString:@"RG"]) {
        model = MBLModelMetaWearRG;
    } else if ([modelString isEqualToString:@"RPRO"]) {
        model = MBLModelMetaWearRPro;
    } else if ([modelString isEqualToString:@"C"]) {
        model = MBLModelMetaWearC;
    } else if ([modelString isEqualToString:@"CPRO"]) {
        model = MBLModelMetaWearCPro;
    } else if ([modelString isEqualToString:@"CDET"]) {
        model = MBLModelMetaWearCDet;
    } else if ([modelString isEqualToString:@"CENV"]) {
        model = MBLModelMetaWearCEnv;
    } else if ([modelString isEqualToString:@"HR"]) {
        model = MBLModelMetaWearHR;
    } else if ([modelString isEqualToString:@"PPG"]) {
        model = MBLModelMetaWearPPG;
    } else if ([modelString isEqualToString:@"TRAK"]) {
        model = MBLModelMetaTracker;
    } else if ([modelString isEqualToString:@"MOT_R"]) {
        model = MBLModelMetaMotionR;
    } else if ([modelString isEqualToString:@"MOT_C"]) {
        model = MBLModelMetaMotionC;
    } else {
        MBLLog(MBLLogLevelWarning, @"Uknown model %@", modelString);
        model = MBLModelUnknown;
    }
    return model;
}

+ (NSString *)metawearUid
{
    NSString *uuidKey = [[MBLDeviceLookup metawearModelString] stringByAppendingString:@"_UUID"];
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    NSString *metawearId = environment[uuidKey];
    assert(metawearId && ![metawearId isEqualToString:@""]);
    return metawearId;
}

+ (BFTask<MBLMetaWear *> *)deviceForTestWithTimeout:(NSTimeInterval)timeout
{
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    
    
    
    NSString *deviceUid = [MBLDeviceLookup metawearUid];
    // First check the device cache
    [[[[MBLMetaWearManager sharedManager] retrieveSavedMetaWearsAsync] success:^(NSArray<MBLMetaWear *> * _Nonnull array) {
        for (MBLMetaWear *cur in array) {
            if ([cur.identifier.UUIDString isEqualToString:deviceUid]) {
                [source trySetResult:cur];
            }
        }
        // Then move to scanning
        [[MBLMetaWearManager sharedManager] startScanForMetaWearsAllowDuplicates:NO handler:^(NSArray *array) {
            for (MBLMetaWear *cur in array) {
                if ([cur.identifier.UUIDString isEqualToString:deviceUid]) {
                    [[MBLMetaWearManager sharedManager] stopScan];
                    [cur rememberDevice];
                    [source trySetResult:cur];
                }
            }
        }];
    }] failure:^(NSError * _Nonnull error) {
        [source trySetError:error];
    }];
    
    // TODO: We do this on main thread because performSelector afterDelay isn't working on other threads
    dispatch_async(dispatch_get_main_queue(), ^{
        [[MBLDeviceLookup class] performSelector:@selector(searchTimeout:) withObject:source afterDelay:timeout];
    });
    return source.task;
}

+ (void)searchTimeout:(BFTaskCompletionSource *)source
{
    // Set a timeout error
    [source trySetError:[NSError errorWithDomain:kMBLErrorDomain
                                            code:kMBLErrorConnectionTimeout
                                        userInfo:@{NSLocalizedDescriptionKey : @"Couldn't find to MetaWear, double check UUID's and battery levels."}]];
}

+ (BFTask<MBLMetaWear *> *)connectDevice:(MBLMetaWear *)device timeout:(NSTimeInterval)timeout forceClear:(BOOL)forceClear
{
    return [[[device connectWithTimeoutAsync:timeout] continueOnDispatchWithSuccessBlock:^id _Nullable(BFTask<MBLMetaWear *> * _Nonnull t) {
        // Reboot if device is programmed elsewhere since we can't be sure of its current state
        if (device.programedByOtherApp || forceClear) {
            NSLog(@"Taking ownership of device");
            return [device setConfigurationAsync:nil];
        }
        return nil;
    }] continueOnDispatchWithSuccessBlock:^id _Nullable(BFTask<MBLMetaWear *> * _Nonnull t) {
        return [device connectWithTimeoutAsync:timeout];
    }];
}

@end
