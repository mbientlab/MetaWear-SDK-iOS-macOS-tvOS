/**
 * MBLLoggingV2.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 11/16/15.
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

#import "MBLLoggingV2.h"
#import "MBLRegister+Private.h"
#import "MBLNumericFormatter.h"
#import "MBLNumericData+Private.h"
#import "MBLConstants+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLLogger.h"

@implementation MBLLoggingV2

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        self.logLength = [[MBLRegister alloc] initWithModule:self registerId:0x5 format:[[MBLNumericFormatter alloc] initIntWithLength:4 isSigned:NO]];
        self.logReadout = [[MBLRegister alloc] initWithModule:self registerId:0x6 format:[[MBLFormat alloc] initEncodedDataWithLength:8]];
        self.logReadoutProgress = [[MBLRegister alloc] initWithModule:self registerId:0x8 format:[[MBLNumericFormatter alloc] initIntWithLength:4 isSigned:NO]];
        
        self.readoutPageComplete = [[MBLRegister alloc] initWithModule:self registerId:0xD format:[[MBLFormat alloc] initEncodedDataWithLength:0]];
        self.readoutPageConfirm = [[MBLRegister alloc] initWithModule:self registerId:0xE format:[[MBLFormat alloc] initEncodedDataWithLength:0]];
    }
    return self;
}

- (BFTask *)dropAllEntries
{
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    [[self.logLength readAsync] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        if (task.error) {
            [source trySetError:task.error];
            return nil;
        }
        MBLNumericData *data = task.result;
        uint32_t totalEntries = data.value.unsignedIntValue;
        // If nothing to read then we are done here!
        if (totalEntries == 0) {
            [source trySetResult:@YES];
            return nil;
        }
        // When droping entires, we get a readoutPageComplete notification
        // when it completes, no need to ack the message
        [[self.readoutPageComplete startNotificationsWithExecutorAsync:[BFExecutor metaWearExecutor] withHandler:^(id  _Nullable obj, NSError * _Nullable error) {
            if (error) {
                [source trySetError:error];
                return;
            }
            [[self.readoutPageComplete stopNotificationsAsync] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                if (task.error) {
                    [source trySetError:task.error];
                } else {
                    [source trySetResult:@YES];
                }
                return nil;
            }];
        }] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
            if (task.error) {
                [source trySetError:task.error];
            }
            return nil;
        }];
        uint32_t count = 0xFFFFFFFF;
        [[self.dropEntries writeDataAsync:[NSData dataWithBytes:&count length:4]] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
            if (task.error) {
                [source trySetError:task.error];
            }
            return nil;
        }];
        return nil;
    }];
    return source.task;
}

- (BFTask *)startReadout:(uint32_t)totalEntries
{
    NSMutableData *params = [NSMutableData dataWithBytes:&totalEntries length:4];
    uint32_t delta;
    if (totalEntries > 2000) {
        delta = totalEntries / 100;
    } else if (totalEntries > 1000) {
        delta = totalEntries / 10;
    } else if (totalEntries > 100) {
        delta = totalEntries / 4;
    } else {
        delta = UINT32_MAX;
    }
    [params appendBytes:&delta length:4];
    return [self.logReadout writeDataAsync:params];
}

- (void)processRawEntry:(const mw_log_entry_t *)rawEntry
{
    assert([MBLConstants isMetaWearQueue]);
    if (printOnlyMode) {
        MBLLog(MBLLogLevelInfo, @"[%d] %d:%d - %@", rawEntry->triggerId, rawEntry->resetId, rawEntry->timestamp, [NSData dataWithBytes:rawEntry->data length:4]);
    }
    
    // Check if this entry has been seen before, and ignore it if needed
    NSData *curEntry = [NSData dataWithBytes:rawEntry length:sizeof(mw_log_entry_t)];
    if (rawLogEntiresToReject) {
        MBLRejectEntry *entry = [rawLogEntiresToReject firstObject];
        if ([entry.data isEqualToData:curEntry]) {
            [rawLogEntiresToReject removeObjectAtIndex:0];
            return;
        } else {
            rawLogEntiresToReject = nil;
        }
    }
    
    // If we started a new page, than means we successfully cleaned up all pervious entries
    // so there is 0 chance we can ever encounter them again, so remove all the reject objects.
    if (newPageStarted) {
        newPageStarted = NO;
        [self deleteAllRejectObjects];
    }
    
    // No need to reject so process that entry!
    uint32_t entryTs = rawEntry->timestamp;
    uint8_t resetId = rawEntry->resetId;
    uint8_t triggerId = rawEntry->triggerId;
    NSData *data = [NSData dataWithBytes:rawEntry->data length:4];
    NSDate __block *date = nil;
    date = self.device.nonVolatileState.logStartingDates[resetId];
    if ([[NSNull null] isEqual:date]) {
        MBLLog(MBLLogLevelError, @"Timestamp error, please call setConfiguration:nil on the MBLMetaWear object to reset log");
        date = [NSDate dateWithTimeIntervalSince1970:0];
        self.device.nonVolatileState.logStartingDates[resetId] = date;
    }
    
    // If reset uid changes then reset lastTimestamp
    if (resetId != self.lastResetId) {
        self.lastTimestamp = 0;
    }
    // If we roll over, then advance the starting date
    if (entryTs < self.lastTimestamp) {
        MBLLog(MBLLogLevelInfo, @"***Timestamp Rolling Over***");
        date = [date dateByAddingTimeInterval:LOGGING_SEC_PER_TIMESTAMP * LOGGING_ROLLOVER_COUNT];
        self.device.nonVolatileState.logStartingDates[resetId] = date;
    }
    // Update our tracking variables
    self.lastTimestamp = entryTs;
    self.lastResetId = resetId;
    
    // Convert to real time
    NSDate *timestamp = [date dateByAddingTimeInterval:entryTs * LOGGING_SEC_PER_TIMESTAMP];
    
    // Now that it's processed, commit it to the database
    [managedObjectContext performBlock:^{
        // We may need to reject this entry as a duplicate later, so save it as an MBLRejectEntry
        MBLRejectEntry *rejectEntry = (MBLRejectEntry *)[NSEntityDescription insertNewObjectForEntityForName:@"MBLRejectEntry" inManagedObjectContext:managedObjectContext];
        rejectEntry.timestamp = timestamp;
        rejectEntry.data = curEntry;
        
        MBLRawLogEntry *entry = (MBLRawLogEntry *)[NSEntityDescription insertNewObjectForEntityForName:@"MBLRawLogEntry" inManagedObjectContext:managedObjectContext];
        entry.timestamp = timestamp;
        entry.resetId = resetId;
        entry.triggerId = triggerId;
        entry.data = data;
    }];
}


@end
