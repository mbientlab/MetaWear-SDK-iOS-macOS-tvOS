/**
 * MBLANCS.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 11/17/14.
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

#import "MBLANCS.h"
#import "MBLRegister+Private.h"
#import "MBLEvent+Private.h"
#import "MBLEntityEvent+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLANCSEventData+Private.h"
#import "MBLNumericFormatter.h"
#import "MBLDataSample.h"
#import "MBLMetaWearManager+Private.h"
#import "BFTask+Private.h"

static const uint8_t MW_ANCS_ATTRIBUTE_MATCH_SIZE = 14;

typedef struct __attribute__((packed)) {
    uint16_t	category_id_mask;
    uint8_t		event_id_mask:3;
    uint8_t		event_flags_mask:5;
    uint8_t		attribute_id;
    uint8_t		attribute_data[MW_ANCS_ATTRIBUTE_MATCH_SIZE];
} mw_ancs_param_t;

@interface MBLANCS ()
@property (nonatomic) MBLRegister *initialize;
@end

@implementation MBLANCS

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        MBLRegister *initialize = [[MBLRegister alloc] initWithModule:self registerId:0x1 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
        MBLRegister *globalEnable = [[MBLRegister alloc] initWithModule:self registerId:0x2 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
        MBLRegister *addFilter = [[MBLRegister alloc] initWithModule:self registerId:0x3 format:[[MBLFormat alloc] initEncodedDataWithLength:18]];
        MBLRegister *removeFilter = [[MBLRegister alloc] initWithModule:self registerId:0x4 format:[MBLFormat writeOnly]];
        MBLRegister *notification = [[MBLRegister alloc] initWithModule:self registerId:0x5 format:[[MBLFormat alloc] initEncodedDataWithLength:4]];
        MBLRegister *notificationEnable  = [[MBLRegister alloc] initWithModule:self registerId:0x6 format:[MBLFormat writeOnly]];

        int maxFilters = 4; // This was the old default
        if (moduleInfo.moduleData.length) {
            maxFilters = *(uint8_t *)moduleInfo.moduleData.bytes;
        }
        
        addFilter.writeResponds = YES;

        self.initialize = initialize;
        
        self.globalEnable = globalEnable;
        
        self.addEntity = addFilter;
        self.removeEntity = removeFilter;
        
        self.globalNotifications = notification;
        self.notificationEnable = notificationEnable;
        
        self.maxEntities = maxFilters;
    }
    return self;
}

- (BFTask *)performAsyncInitialization
{
    return [self.initialize writeDataAsync:nil];
}

- (MBLEvent *)eventWithCategoryIds:(MBLANCSCategoryID)categoryIds
{
    return [self createEventWithCategoryIds:categoryIds
                                   eventIds:MBLANCSEventIDAny
                                 eventFlags:MBLANCSEventFlagAny
                                attributeId:MBLANCSNotificationAttributeIDNone
                              attributeData:nil];
}

- (MBLEvent *)eventWithCategoryIds:(MBLANCSCategoryID)categoryIds
                          eventIds:(MBLANCSEventID)eventIds
                        eventFlags:(MBLANCSEventFlag)eventFlags
{
    return [self createEventWithCategoryIds:categoryIds
                                   eventIds:eventIds
                                 eventFlags:eventFlags
                                attributeId:MBLANCSNotificationAttributeIDNone
                              attributeData:nil];
}

- (MBLEvent *)eventWithCategoryIds:(MBLANCSCategoryID)categoryIds
                          eventIds:(MBLANCSEventID)eventIds
                        eventFlags:(MBLANCSEventFlag)eventFlags
                       attributeId:(MBLANCSNotificationAttributeID)attributeId
                     attributeData:(NSString *)attributeData
{
    return [self createEventWithCategoryIds:categoryIds
                                   eventIds:eventIds
                                 eventFlags:eventFlags
                                attributeId:attributeId
                              attributeData:attributeData];
}

- (MBLEvent *)createEventWithCategoryIds:(MBLANCSCategoryID)categoryIds
                          eventIds:(MBLANCSEventID)eventIds
                        eventFlags:(MBLANCSEventFlag)eventFlags
                       attributeId:(MBLANCSNotificationAttributeID)attributeId
                     attributeData:(NSString *)attributeData
{
    mw_ancs_param_t params = {0};
    params.category_id_mask = categoryIds;
    params.event_id_mask = eventIds;
    params.event_flags_mask = eventFlags;
    params.attribute_id = attributeId;
    if (attributeData) {
        NSData *src = [attributeData dataUsingEncoding:NSUTF8StringEncoding];
        memcpy(params.attribute_data, src.bytes, MIN(src.length, MW_ANCS_ATTRIBUTE_MATCH_SIZE));
    }    
    return [[MBLEntityEvent alloc] initWithModule:self
                                       registerId:self.globalNotifications.registerId
                              addEntityParameters:[NSData dataWithBytes:&params length:sizeof(mw_ancs_param_t)]
                                           format:[MBLANCSEventData formatter]];
}

@end
