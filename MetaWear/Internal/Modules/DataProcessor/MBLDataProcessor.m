/**
 * MBLDataProcessor.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 9/15/14.
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

#import "MBLDataProcessor.h"
#import "MBLRegister+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLEvent+Private.h"
#import "MBLFilter+Private.h"
#import "MBLNumericFormatter.h"
#import "MBLDataSample.h"
#import "MBLMetaWearManager+Private.h"
#import "BFTask+MBLPrivate.h"

@interface MBLDataProcessor ()
@end

@implementation MBLDataProcessor

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        MBLRegister *globalEnable = [[MBLRegister alloc] initWithModule:self registerId:0x1 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
        MBLRegister *addFilter = [[MBLRegister alloc] initWithModule:self registerId:0x2 format:[[MBLFormat alloc] initEncodedDataWithLength:18]];
        MBLRegister *filterNotify = [[MBLRegister alloc] initWithModule:self registerId:0x3 format:[[MBLFormat alloc] initEncodedDataWithLength:18]];
        MBLRegister *removeFilter = [[MBLRegister alloc] initWithModule:self registerId:0x6 format:[[MBLFormat alloc] initEncodedDataWithLength:1]];
        MBLRegister *notificationEnable = [[MBLRegister alloc] initWithModule:self registerId:0x7 format:[[MBLFormat alloc] initEncodedDataWithLength:1]];
        
        int maxFilters = 8; // This was the old default
        if (moduleInfo.moduleData.length) {
            maxFilters = *(uint8_t *)moduleInfo.moduleData.bytes;
        }
        
        addFilter.writeResponds = YES;
                
        self.globalEnable = globalEnable;
        
        self.addEntity = addFilter;
        self.removeEntity = removeFilter;
        
        self.globalNotifications = filterNotify;
        self.notificationEnable = notificationEnable;
        
        self.maxEntities = maxFilters;
	}
    return self;
}

- (BFTask *)getRegister:(NSData *)data
{
    const uint8_t *bytes = data.bytes;
    uint8_t registerId = bytes[1] & 0x3F; // Strip off the "[local] read bit"
    // The data processer abstracts the true data source, so traverse down the linked list
    if (registerId == 0x3) {
        return [[self.addEntity readForcedIndexAsync:bytes[2]] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask<MBLDataSample *> *t) {
            const uint8_t *bytes = t.result.data.bytes;
            return [self.device.modules[bytes[0]] getRegister:t.result.data];
        }];
    }
    return [super getRegister:data];
}

@end
