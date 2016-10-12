/**
 * MBLAnalytics.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 11/27/14.
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

#import "MBLAnalytics.h"
#import "MBLLogger.h"

static const NSString *const VERSION = @"1";
static const NSString *const GOOGLE_ANALYTICS_ID = @"UA-57166859-3";
static NSString *const GOOGLE_ANALYTICS_URL = @"https://ssl.google-analytics.com/collect";

@interface MBLAnalyticMessage : NSObject
@property (nonatomic) NSString *postPayload;

- (instancetype)initWithDevice:(NSUUID *)uuid eventCategory:(NSString *)category eventAction:(NSString *)action eventLabel:(NSString *)label;
- (void)post;
@end


@interface MBLAnalytics ()
@end

@implementation MBLAnalytics

+ (instancetype)sharedManager
{
    static MBLAnalytics *singleton = nil;
    if (!singleton) {
        singleton = [[MBLAnalytics alloc] init];
    }
    return singleton;
}

- (void)postEventForDevice:(NSUUID *)uuid eventCategory:(NSString *)category eventAction:(NSString *)action eventLabel:(NSString *)label
{
    [[[MBLAnalyticMessage alloc] initWithDevice:uuid eventCategory:category eventAction:action eventLabel:label] post];
}

@end

@implementation MBLAnalyticMessage

- (instancetype)initWithDevice:(NSUUID *)uuid eventCategory:(NSString *)category eventAction:(NSString *)action eventLabel:(NSString *)label
{
    self = [super init];
    if (self) {
        self.postPayload = [NSString stringWithFormat:@"%@&t=event&ec=%@&ea=%@&el=%@",
                            [self basePost:uuid],
                            [category stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet],
                            [action stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet],
                            [label stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet],
                            nil];
    }
    return self;
}

- (NSString *)basePost:(NSUUID *)uuid
{
    return [NSString stringWithFormat:@"v=%@&tid=%@&cid=%@&an=%@&av=%@&aid=%@&ds=ios",
            [VERSION stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet],
            [GOOGLE_ANALYTICS_ID stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet],
            [uuid.UUIDString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet],
            [[[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleNameKey] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet],
            [[[NSBundle mainBundle] objectForInfoDictionaryKey:(__bridge NSString *)kCFBundleVersionKey] stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet],
            [[NSBundle mainBundle].bundleIdentifier stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet],
            nil];
}

- (void)post
{
    NSData *postData = [self.postPayload dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)postData.length];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
    [request setURL:[NSURL URLWithString:GOOGLE_ANALYTICS_URL]];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    NSString *tmp = self.postPayload;
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *connectionError) {
        if (connectionError) {
            MBLLog(MBLLogLevelDebug, @"[Analytics] issue posting \n%@\%@", tmp, connectionError);
        }
    }] resume];
}

@end
