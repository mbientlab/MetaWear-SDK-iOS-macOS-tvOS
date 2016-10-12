/**
 * MBLANCSEventData.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 10/15/14.
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

#import "MBLANCSEventData+Private.h"
#import "MBLDataSample+Private.h"

typedef struct __attribute__((packed)) {
    uint8_t					event_id:3;
    uint8_t					event_flags:5;
    uint8_t					category_id;
    uint8_t					category_count;
} mw_ancs_notification_t;


@interface MBLANCSEventFormatter : MBLFormat
@end

@implementation MBLANCSEventFormatter
- (id)entryFromData:(NSData *)data date:(NSDate *)date
{
    return [[MBLANCSEventData alloc] initWithData:data timestamp:date];
}

- (NSNumber *)numberFromDouble:(double)value
{
    [NSException raise:@"Cannout use ANCS events with filters" format:@""];
    return nil;
}
@end


@interface MBLANCSEventData ()
@property (nonatomic) MBLANCSEventID eventId;
@property (nonatomic) MBLANCSEventFlag eventFlags;
@property (nonatomic) MBLANCSCategoryID categoryId;
@property (nonatomic) uint8_t categoryCount;
@end

@implementation MBLANCSEventData

+ (MBLFormat *)formatter
{
    return [[MBLANCSEventFormatter alloc] initEncodedDataWithLength:4];
}

- (instancetype)initWithData:(NSData *)data timestamp:(NSDate *)timestamp
{
    self = [super initWithTimestamp:timestamp];
    if (self) {
        mw_ancs_notification_t status = *(mw_ancs_notification_t *)data.bytes;
        self.eventId = (1 << status.event_id);
        self.eventFlags = status.event_flags;
        self.categoryId = (1 << status.category_id);
        self.categoryCount = status.category_count;
    }
    return self;
}


- (NSString *)eventIdString
{
    NSString *eventId;
    switch (self.eventId) {
        case MBLANCSEventIDNotificationAdded:
            eventId = @"EventID: Notification Added";
            break;
        case MBLANCSEventIDNotificationModified:
            eventId = @"EventID: Notification Modified";
            break;
        case MBLANCSEventIDNotificationRemoved:
            eventId = @"EventID: Notification Removed";
            break;
        case MBLANCSEventIDAny:
            eventId = @"";
            break;
    }
    return eventId;
}

- (NSString *)eventFlagsString
{
    NSString *eventFlags = @"EventFlags:";
    if (self.eventFlags & MBLANCSEventFlagSilent) {
        eventFlags = [eventFlags stringByAppendingString:@" Silent"];
    }
    if (self.eventFlags & MBLANCSEventFlagImportant) {
        eventFlags = [eventFlags stringByAppendingString:@" Important"];
    }
    if (self.eventFlags & MBLANCSEventFlagPreExisting) {
        eventFlags = [eventFlags stringByAppendingString:@" PreExisting"];
    }
    if (self.eventFlags & MBLANCSEventFlagPositiveAction) {
        eventFlags = [eventFlags stringByAppendingString:@" PositiveAction"];
    }
    if (self.eventFlags & MBLANCSEventFlagNegativeAction) {
        eventFlags = [eventFlags stringByAppendingString:@" NegativeAction"];
    }
    return eventFlags;
}

- (NSString *)categoryString
{
    NSString *categoryId;
    switch (self.categoryId) {
        case MBLANCSCategoryIDOther:
            categoryId = @"CategoryID: Other";
            break;
        case MBLANCSCategoryIDIncomingCall:
            categoryId = @"CategoryID: Incoming Call";
            break;
        case MBLANCSCategoryIDMissedCall:
            categoryId = @"CategoryID: Missed Call";
            break;
        case MBLANCSCategoryIDVoicemail:
            categoryId = @"CategoryID: Voicemail";
            break;
        case MBLANCSCategoryIDSocial:
            categoryId = @"CategoryID: Social";
            break;
        case MBLANCSCategoryIDSchedule:
            categoryId = @"CategoryID: Schedule";
            break;
        case MBLANCSCategoryIDEmail:
            categoryId = @"CategoryID: Email";
            break;
        case MBLANCSCategoryIDNews:
            categoryId = @"CategoryID: News";
            break;
        case MBLANCSCategoryIDHealthAndFitness:
            categoryId = @"CategoryID: Health And Fitness";
            break;
        case MBLANCSCategoryIDBusinessAndFinance:
            categoryId = @"CategoryID: Business And Finance";
            break;
        case MBLANCSCategoryIDLocation:
            categoryId = @"CategoryID: Location";
            break;
        case MBLANCSCategoryIDEntertainment:
            categoryId = @"CategoryID: Entertainment";
            break;
        case MBLANCSCategoryIDAny:
            categoryId = @"";
            break;
    }
    return categoryId;
}

- (NSString *)description
{
    NSString *eventId = [self eventIdString];
    NSString *eventFlags = [self eventFlagsString];
    NSString *categoryId = [self categoryString];
    return [NSString stringWithFormat:@"%@\n%@\n%@\n%@\nCategoryCount: %d", [super description], eventId, eventFlags, categoryId, self.categoryCount];
}

- (NSString *)csvRepresentation
{
    NSString *eventId = [self eventIdString];
    NSString *eventFlags = [self eventFlagsString];
    NSString *categoryId = [self categoryString];
    return [NSString stringWithFormat:@"%f,\"%@ %@ %@ CategoryCount: %d\"\n", self.timestamp.timeIntervalSince1970, eventId, eventFlags, categoryId, self.categoryCount];
}

@end
