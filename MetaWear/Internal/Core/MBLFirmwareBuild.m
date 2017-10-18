/**
 * MBLFirmwareBuild.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 7/22/15.
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

#import "MBLFirmwareBuild.h"
#import "MBLLogger.h"
#import "BFTask+MBLPrivate.h"

@interface MBLFirmwareBuild ()
@property (nonatomic) NSString *hardwareRev;
@property (nonatomic) NSString *modelNumber;
@property (nonatomic) NSString *buildFlavor;
@property (nonatomic) NSString *firmwareRev;
@property (nonatomic) NSString *filename;

@property (nonatomic) NSURL *firmwareURL;
@property (nonatomic) NSURL *firmwareLocalFile;
@end

@implementation MBLFirmwareBuild

- (instancetype)initWithHardwareRev:(NSString *)hardwareRev
                        modelNumber:(NSString *)modelNumber
                        buildFlavor:(NSString *)buildFlavor
                        firmwareRev:(NSString *)firmwareRev
                           filename:(NSString *)filename
{
    self = [super init];
    if (self) {
        self.hardwareRev = hardwareRev;
        self.modelNumber = modelNumber;
        self.buildFlavor = buildFlavor;
        self.firmwareRev = firmwareRev;
        self.filename = filename;
        
        self.firmwareURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://mbientlab.com/releases/metawear/%@/%@/%@/%@/%@",
                                                 hardwareRev ? hardwareRev : @"0.1",
                                                 modelNumber ? modelNumber : @"0",
                                                 buildFlavor ? buildFlavor : @"vanilla",
                                                 firmwareRev ? firmwareRev : @"1.1.3",
                                                 filename ? filename : @"firmware.bin"]];
    }
    return self;
}

- (instancetype)initWithHardwareRev:(NSString *)hardwareRev
                        modelNumber:(NSString *)modelNumber
                                url:(NSURL *)customUrl
{
    self = [super init];
    if (self) {
        self.hardwareRev = hardwareRev;
        self.modelNumber = modelNumber;
        self.filename = customUrl.lastPathComponent;
        self.firmwareURL = customUrl;
        if (customUrl.isFileURL) {
            self.firmwareLocalFile = customUrl;
        }
    }
    return self;
}


- (BFTask *)downloadFirmwareAsync
{
    if (self.firmwareLocalFile) {
        return [BFTask taskWithResult:nil];
    }
    // Go grab the file at the URL
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    MBLLog(MBLLogLevelInfo, @"Downloading... %@", self.firmwareURL);
    [[[NSURLSession sharedSession] downloadTaskWithURL:self.firmwareURL completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (error) {
            [source trySetError:error];
            return;
        } else if (httpResponse.statusCode != 200) {
            [source trySetError:[NSError errorWithDomain:kMBLErrorDomain
                                                    code:kMBLErrorNoAvailableFirmware
                                                userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Firmware URL %@ returned code %ld", self.firmwareURL, (long)httpResponse.statusCode]}]];
            return;
        }
        // If no download error, then copy the file to a permanent place.  Note the location
        // variable suppiled is invalid once this block returns.
        NSString *filepath = [NSTemporaryDirectory() stringByAppendingPathComponent:self.filename];
        if (!filepath) {
            [source trySetError:[NSError errorWithDomain:kMBLErrorDomain
                                                    code:kMBLErrorUnexpectedServices
                                                userInfo:@{NSLocalizedDescriptionKey : @"Couldn't find temp directory to store firmware file.  Please report issue to developers@mbientlab.com"}]];
            return;
        }
        NSURL *fileURL = [NSURL fileURLWithPath:filepath];
        NSError *err;
        [[NSFileManager defaultManager] removeItemAtPath:filepath error:nil];
        if (![[NSFileManager defaultManager] copyItemAtURL:location toURL:fileURL error:&err]) {
            [source trySetError:err];
            return;
        }
        MBLLog(MBLLogLevelInfo, @"Download Complete");
        self.firmwareLocalFile = fileURL;
        [source trySetResult:fileURL];
    }] resume];
    return source.task;
}

+ (BFTask<MBLFirmwareBuild *> *)fromReleaseServerWithHardwareRev:(NSString *)hardwareRev
                                                     modelNumber:(NSString *)modelNumber
                                                     firmwareRev:(NSString *)firmwareRev
{
    // First try to fetch a zip file
    MBLFirmwareBuild __block *firmware = [[MBLFirmwareBuild alloc] initWithHardwareRev:hardwareRev
                                                                   modelNumber:modelNumber
                                                                   buildFlavor:@"vanilla"
                                                                   firmwareRev:firmwareRev
                                                                      filename:@"firmware.zip"];
    return [[[firmware downloadFirmwareAsync] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        if (t.error == nil) {
            return t;
        }
        // No zip file, try a bin instead
        firmware = [[MBLFirmwareBuild alloc] initWithHardwareRev:hardwareRev
                                                     modelNumber:modelNumber
                                                     buildFlavor:@"vanilla"
                                                     firmwareRev:firmwareRev
                                                        filename:@"firmware.bin"];
        return [firmware downloadFirmwareAsync];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        return firmware;
    }];
}

@end
