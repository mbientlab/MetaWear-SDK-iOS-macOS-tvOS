/**
 * MBLLogging.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 9/17/14.
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

#import "MBLLogging.h"
#import "MBLLoggingV0.h"
#import "MBLLoggingV1.h"
#import "MBLLoggingV2.h"
#import "MBLEvent.h"
#import "MBLDataSample+Private.h"
#import "MBLRegister+Private.h"
#import "MBLEvent+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLNumericFormatter.h"
#import "MBLNumericData.h"
#import "MBLConstants+Private.h"
#import "MBLMetaWearManager+Private.h"
#import <libkern/OSAtomic.h>
#import <CoreData/CoreData.h>
#import "BFTask+MBLPrivate.h"
#import "MBLLogger.h"


typedef struct __attribute__((packed)) {
    uint8_t		logTriggers;
    uint16_t    logCap;
} mw_log_module_info_old;

typedef struct __attribute__((packed)) {
    uint32_t    persentTime;
    uint8_t     resetId;
} mw_log_current_time;


@implementation MBLRawLogEntry
@dynamic timestamp;
@dynamic resetId;
@dynamic triggerId;
@dynamic data;
@end

@implementation MBLRejectEntry
@dynamic timestamp;
@dynamic data;
@end


@implementation MBLLogging

+ (instancetype)objectWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    if (moduleInfo.moduleRevision == 2) {
        return [[MBLLoggingV2 alloc] initWithDevice:device moduleInfo:moduleInfo];
    } else if (moduleInfo.moduleRevision == 1) {
        return [[MBLLoggingV1 alloc] initWithDevice:device moduleInfo:moduleInfo];
    } else {
        return [[MBLLoggingV0 alloc] initWithDevice:device moduleInfo:moduleInfo];
    }
}

- (void)sharedInit
{
    handlerMutex = [[NSObject alloc] init];
    progressHandlers = [NSMutableArray array];
    downloadHandlers = [NSMutableArray array];
    logProcessingQueue = dispatch_queue_create("com.mbientlab.metawear.logProcessingQueue", DISPATCH_QUEUE_CONCURRENT);
    logProcessingGroup = dispatch_group_create();
    
    NSString *filename = [[MBLMetaWearManager sharedManager] logFilename:[self.device.identifier.UUIDString stringByAppendingString:@"RawEntries.sqlite3"]];
    NSURL *storeURL = [NSURL fileURLWithPath:filename isDirectory:NO];
    NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    // Allow inferred migration from the original version of the application.
    NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : @YES,
                               NSInferMappingModelAutomaticallyOption : @YES
#if TARGET_OS_IOS || TARGET_OS_TV
                               , NSPersistentStoreFileProtectionKey : NSFileProtectionCompleteUntilFirstUserAuthentication };
#else
                               };
#endif
    
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
}

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        [self sharedInit];
        
        uint8_t triggerCount = 8; // This was the old default
        if (moduleInfo.moduleData.length) {
            triggerCount = *(uint8_t *)moduleInfo.moduleData.bytes;
            if (moduleInfo.moduleRevision >= 1) {
                mw_log_module_info *info = (mw_log_module_info *)moduleInfo.moduleData.bytes;
                MBLLog(MBLLogLevelDebug, @"Log Capacity: %d", info->logCap);
            } else {
                mw_log_module_info_old *info = (mw_log_module_info_old *)moduleInfo.moduleData.bytes;
                MBLLog(MBLLogLevelDebug, @"Log Capacity: %d", info->logCap);
            }
        }
        
        self.triggers = [NSMutableArray arrayWithCapacity:triggerCount];
        for (int i = 0; i < triggerCount; i++) {
            [self.triggers addObject:[NSNull null]];
        }
        self.lastTimestamp = 0;
        self.lastResetId = 0xFF;
        self.remainingTriggers = triggerCount;
        
        self.globalEnable = [[MBLRegister alloc] initWithModule:self registerId:0x1 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
        self.addLogTrigger = [[MBLRegister alloc] initWithModule:self registerId:0x2 format:[[MBLFormat alloc] initEncodedDataWithLength:4]];
        self.removeLogTrigger = [[MBLRegister alloc] initWithModule:self registerId:0x3 format:[MBLFormat writeOnly]];
        self.currentTime = [[MBLRegister alloc] initWithModule:self registerId:0x4 format:[[MBLFormat alloc] initEncodedDataWithLength:5]];
        self.logReadoutNotify = [[MBLRegister alloc] initWithModule:self registerId:0x7 format:[[MBLFormat alloc] initEncodedDataWithLength:18]];
        self.dropEntries = [[MBLRegister alloc] initWithModule:self registerId:0x9 format:[MBLFormat writeOnly]];
        self.removeAllTriggers = [[MBLRegister alloc] initWithModule:self registerId:0xA format:[MBLFormat writeOnly]];
        self.circularBufferMode = [[MBLRegister alloc] initWithModule:self registerId:0xB format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
        self.recycledPageCount = [[MBLRegister alloc] initWithModule:self registerId:0xC format:[[MBLNumericFormatter alloc] initIntWithLength:2 isSigned:NO]];
        
        self.removeAllTriggers.needsResponse = YES; // Give some time for entries to be dropped before continuing
        self.addLogTrigger.writeResponds = YES;
    }
    return self;
}

- (id)awakeAfterFastCoding
{
    [self sharedInit];
    return self;
}

- (BFTask *)startLoggingAsyncEvent:(MBLEvent *)event
{
    return [[[self initializeAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        if (event.loggingIds.count) {
            NSError *error = [NSError errorWithDomain:kMBLErrorDomain
                                                 code:kMBLErrorOperationInvalid
                                             userInfo:@{NSLocalizedDescriptionKey : @"Can't log event that is already logging."}];
            return [BFTask taskWithError:error];
        }
        if (self.remainingTriggers < ceil((double)event.format.length / 4.0)) {
            NSError *error = [NSError errorWithDomain:kMBLErrorDomain
                                                 code:kMBLErrorInsufficientMemory
                                             userInfo:@{NSLocalizedDescriptionKey : [NSString stringWithFormat:@"MetaWear out of memory, can't perform action.  Reset the MetaWear and use no more than %lu log entries", (unsigned long)self.triggers.count]}];
            return [BFTask taskWithError:error];
        }
        BFTask *head = [BFTask taskWithResult:nil];
        for (int length = event.format.length, offset = event.format.offset; length > 0; length -= 4, offset += 4) {
            mw_log_trigger_t params = {0};
            params.source_modid = event.module.moduleInfo.moduleId;
            params.source_regid = event.registerId;
            params.source_index = event.index;
            params.source_offset = offset;
            if (length > 4) {
                params.source_datalen = 3;
            } else {
                params.source_datalen = length - 1;
            }
            
            NSData *paramData = [NSData dataWithBytes:&params length:sizeof(mw_log_trigger_t)];
            self.remainingTriggers--;
            head = [[head continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
                return [self.addLogTrigger writeDataAsync:paramData];
            }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
                MBLDataSample *obj = task.result;
                uint8_t logId = *(uint8_t *)obj.data.bytes;
                [event.loggingIds addObject:[NSNumber numberWithChar:logId]];
                self.triggers[logId] = paramData;
                return nil;
            }];
        }
        return head;
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [self activateAsync];
    }];
}

- (BFTask *)stopLoggingEvent:(MBLEvent *)event
{
    return [[[self deactivateAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        BFTask *head = [BFTask taskWithResult:nil];
        for (NSNumber *curId in event.loggingIds) {
            head = [head continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
                self.remainingTriggers++;
                self.triggers[curId.charValue] = [NSNull null];
                return [self.removeLogTrigger writeByteAsync:curId.charValue];
            }];
        }
        return head;
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [self deinitializeAsync];
    }];
}

- (BFTask *)downloadLogEvents:(MBLEvent *)event
              progressHandler:(MBLLogProgressHandler)progressHandler
{
    BFTaskCompletionSource *source = [BFTaskCompletionSource taskCompletionSource];
    [self performRawReadOutWithHandler:^(NSError *error) {
        if (error) {
            [source trySetError:error];
            dispatch_group_leave(logProcessingGroup);
            return;
        }
        
        dispatch_async([MBLConstants metaWearQueue], ^{
            // TODO: Figure out how to track this better
            if (!event.loggingIds.count) {
                [source trySetResult:@[]];
                dispatch_group_leave(logProcessingGroup);
                return;
            }
            
            NSArray *loggingIds = [event.loggingIds copy];
            // Grab the raw entries based on the logging id of this event
            [self entriesForTriggerId:[loggingIds[0] intValue] handler:^(NSArray * _Nullable rawEntries, NSError * _Nullable error) {
                if (error) {
                    [source trySetError:error];
                    dispatch_group_leave(logProcessingGroup);
                    return;
                }
                // Initialize the final log, this will contain all the properly formated data objects
                NSMutableArray *log = [NSMutableArray arrayWithCapacity:rawEntries.count];
                if (loggingIds.count == 1) {
                    // Fast path if we only need the one entry
                    for (MBLRawLogEntry *rawEntry in rawEntries) {
                        NSData *data = [rawEntry.data subdataWithRange:NSMakeRange(0, event.format.length)];
                        [log addObject:[event.format entryFromData:data date:rawEntry.timestamp]];
                    }
                    [self deleteObjects:@[rawEntries]];
                    
                    [source trySetResult:log];
                    dispatch_group_leave(logProcessingGroup);
                } else if (loggingIds.count > 1) {
                    // Longer path to merge different logging id's into a single object
                    
                    // The overal idea here is that we get array of all the raw entries
                    // then work backwards merging the data together.  We do backwards
                    // because the timestamps tend to line up better than we, althought
                    // we could do an even more advanced timestamp matching...
                    
                    // Get an array or array to hold all the reverse enumerators
                    NSMutableArray *allRawEntries = [NSMutableArray array];
                    NSMutableArray *rawEntriesToDelete = [NSMutableArray array];
                    [allRawEntries addObject:rawEntries.reverseObjectEnumerator];
                    
                    NSArray *additionalLoggingIds = [loggingIds subarrayWithRange:NSMakeRange(1, loggingIds.count - 1)];
                    for (NSNumber *uid in additionalLoggingIds) {
                        // Fetch the arrays for all the other id's
                        [self entriesForTriggerId:uid.intValue handler:^(NSArray * _Nullable rawEntries, NSError * _Nullable error) {
                            if (error) {
                                [source trySetError:error];
                                dispatch_group_leave(logProcessingGroup);
                                return;
                            }
                            [rawEntriesToDelete addObject:rawEntries];
                            [allRawEntries addObject:rawEntries.reverseObjectEnumerator];
                            if (uid == [additionalLoggingIds lastObject]) {
                                // Now we have all arrays so perform the merge
                                BOOL moreEntries = YES;
                                while (moreEntries) {
                                    // Loop through and pull out entries until the first array empties
                                    NSMutableData *completeData = [NSMutableData data];
                                    NSDate *timestamp = nil;
                                    for (NSEnumerator *enumerator in allRawEntries) {
                                        MBLRawLogEntry *cur = [enumerator nextObject];
                                        if (cur) {
                                            if (!timestamp) {
                                                timestamp = cur.timestamp;
                                            }
                                            NSData *additionalData = [cur.data subdataWithRange:NSMakeRange(0, MIN(event.format.length - completeData.length, 4))];
                                            [completeData appendData:additionalData];
                                        } else {
                                            moreEntries = NO;
                                            break;
                                        }
                                    }
                                    if (moreEntries) {
                                        assert(timestamp);
                                        [log insertObject:[event.format entryFromData:completeData date:timestamp] atIndex:0];
                                    }
                                }
                                
                                [self deleteObjects:rawEntriesToDelete];
                                [source trySetResult:log];
                                dispatch_group_leave(logProcessingGroup);
                            }
                        }];
                    }
                }
            }];
        });
    } progressHandler:progressHandler];
    return source.task;
}

- (BFTask *)stopAndClearLog
{
    return [[[self.removeAllTriggers writeDataAsync:nil] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [self dropAllEntries];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        [self deleteAllObjects];
        [self deleteAllRejectObjects];
        // Since all old log entires are gone and we are about to reset we should
        // purge out all the old log starting dates
        for (int i = 0; i < self.device.nonVolatileState.logStartingDates.count; i++) {
            self.device.nonVolatileState.logStartingDates[i] = [NSNull null];
        }
        // Remove all stale junk
        for (int i = 0; i < self.triggers.count; i++) {
            self.triggers[i] = [NSNull null];
        }
        self.remainingTriggers = self.triggers.count;
        return nil;
    }];
}

- (BFTask *)dropAllEntries
{
    [NSException raise:@"Error" format:@"Please instantiate derived class, this is implemented there"];
    return nil;
}

- (BFTask *)startReadout:(uint32_t)totalEntries
{
    [NSException raise:@"Error" format:@"Please instantiate derived class, this is implemented there"];
    return nil;
}

- (void)performRawReadOutWithHandler:(MBLErrorHandler)handler
                     progressHandler:(MBLLogProgressHandler)progressHandler
{
    @synchronized(handlerMutex) {
        if (handler) {
            [downloadHandlers addObject:handler];
        }
        if (progressHandler) {
            MBLLogProgressHandler handlerOnDispatch = ^(uint32_t totalEntries, uint32_t remainingEntries) {
                [[MBLMetaWearManager dispatchQueue] addOperationWithBlock:^{
                    progressHandler(totalEntries, remainingEntries);
                }];
            };
            [progressHandlers addObject:handlerOnDispatch];
        }
        if (!isDownloading) {
            isDownloading = YES;
            [self rawReadOut];
        }
    }
}

- (void)rawReadOut
{
    [[self.logLength readAsync] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        MBLNumericData *data = task.result;
        NSError *error = task.error;
        
        if (error) {
            [self rawReadOutFinishedWithError:error];
            return nil;
        }
        
        uint32_t totalEntries = data.value.unsignedIntValue;
        // If nothing to read then we are done here!
        if (totalEntries == 0) {
            [self rawReadOutFinishedWithError:nil];
            return nil;
        }
        [[[[[self.logReadoutProgress startNotificationsWithExecutorAsync:[BFExecutor metaWearExecutor] withHandler:^(MBLNumericData *data, NSError *error) {
            if (error) {
                [self rawReadOutFinishedWithError:error];
                return;
            }
            
            uint32_t remainingEntries = data.value.unsignedIntValue;
            @synchronized(handlerMutex) {
                for (MBLLogProgressHandler progressHandler in progressHandlers) {
                    progressHandler(totalEntries, remainingEntries);
                }
            }
            if (remainingEntries == 0) {
                [[[[self.logReadoutProgress stopNotificationsAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
                    return [self.logReadoutNotify stopNotificationsAsync];
                }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
                    return [self.readoutPageComplete stopNotificationsAsync];
                }] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                    [self deleteAllRejectObjects]; // TODO: BFTask this
                    [self rawReadOutFinishedWithError:task.error];
                    return task;
                }];
            }
        }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
            return [self.logReadoutNotify startNotificationsWithExecutorAsync:[BFExecutor metaWearExecutor] withHandler:^(MBLDataSample *obj, NSError *error) {
                if (error) {
                    return;
                }
                if (obj.data.length >= 9) {
                    const uint8_t *bytes = (const uint8_t *)obj.data.bytes;
                    [self processRawEntry:(const mw_log_entry_t *)bytes];
                    if (obj.data.length == 18) {
                        [self processRawEntry:(const mw_log_entry_t *)(bytes + 9)];
                    }
                }
            }];
        }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
            return [self.readoutPageComplete startNotificationsWithExecutorAsync:[BFExecutor metaWearExecutor] withHandler:^(id  _Nullable obj, NSError * _Nullable error) {
                if (error) {
                    return;
                }
                newPageStarted = YES;
                [self saveLogAsync:YES];
                if (noAckMode) {  // GNARLY TEST CODE!!!
                    [self.logReadoutProgress stopNotificationsAsync];
                    [self.logReadoutNotify stopNotificationsAsync];
                    [self.readoutPageComplete stopNotificationsAsync];
                    [self rawReadOutFinishedWithError:nil];
                    return;
                }
                [self.readoutPageConfirm writeDataAsync:nil];
            }];
        }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
            if (self.moduleInfo.moduleRevision >= 2) {
                rawLogEntiresToReject = [self getAllRejectEntries];
                newPageStarted = YES;
            } else {
                self.lastTimestamp = 0;
            }
            
            return [self startReadout:totalEntries];
        }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
            // Since log downloads take a while, let's save state here
            return [self.device synchronizeAsync];
        }];
        return nil;
    }];
}

- (void)rawReadOutFinishedWithError:(NSError *)error
{
    @synchronized(handlerMutex) {
        if (error) {
            [self dropEntriesSinceSave];
            self.lastTimestamp = 0;
        }
        [progressHandlers removeAllObjects];
        for (MBLErrorHandler handler in downloadHandlers) {
            dispatch_group_enter(logProcessingGroup);
            dispatch_async(logProcessingQueue, ^{
                handler(error);
            });
        }
        [downloadHandlers removeAllObjects];
        
        dispatch_group_notify(logProcessingGroup, logProcessingQueue, ^{
            @synchronized(handlerMutex) {
                [self saveLogAsync:NO];
                // Now that processing is finished, if someone else is waiting for
                // entries, kick off another download, otherwise put her to sleep.
                if (downloadHandlers.count || progressHandlers.count) {
                    [self rawReadOut];
                } else {
                    isDownloading = NO;
                }
            }
        });
    }
}

- (BFTask *)isStateValid
{
    return [BFTask taskFromMetaWearWithBlock:^id _Nonnull{
        NSMutableArray *tasks = [NSMutableArray array];
        [tasks addObject:[BFTask taskWithResult:@YES]]; // Base case
        for (int i = 0; i < self.triggers.count; i++) {
            if (self.triggers[i] != [NSNull null]) {
                [tasks addObject:[[self.addLogTrigger readForcedIndexAsync:i] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
                    MBLDataSample *result = task.result;
                    NSData *actualData = result.data;
                    NSData *expectedData = self.triggers[i];
                    if (actualData.length >= expectedData.length) {
                        if ([expectedData isEqualToData:[actualData subdataWithRange:NSMakeRange(0, expectedData.length)]]) {
                            return [BFTask taskWithResult:@YES];
                        }
                    }
                    MBLLog(MBLLogLevelInfo, @"Logging: Entity[%d] expected != actual (%@ != %@)", i, expectedData, actualData);
                    return [BFTask taskWithResult:@NO];
                }]];
            }
        }
        return [BFTask taskForCompletionOfAllTasksWithResults:tasks];
    }];
}

- (BFTask<NSNumber *> *)checkForResetAsync;
{
    return [[self.currentTime readAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        MBLDataSample *timeData = task.result;
        const mw_log_current_time *info = (const mw_log_current_time *)timeData.data.bytes;
        BOOL didReset = NO;
        BOOL firstLaunch = NO;
        if (self.currentResetId) {
            if (self.currentResetId.unsignedCharValue != info->resetId) {
                didReset = YES;
            }
        } else {
            firstLaunch = YES;
        }
        // If we did reset, then guess any missed id starting times
        if (didReset) {
            uint8_t prevUid = self.currentResetId.unsignedCharValue;
            // Extra fun check to make sure any missed ID's are guessed to our best effort
            for (uint8_t guessId = (prevUid + 1) & LOGGING_RESET_UIDS_MASK; guessId != info->resetId; guessId = (guessId + 1) & LOGGING_RESET_UIDS_MASK) {
                [self guessUidStartingDate:guessId];
            }
        }
        // Update the startingDates array if needed
        if (firstLaunch || didReset) {
            self.currentResetId = [NSNumber numberWithUnsignedChar:info->resetId];
            uint32_t currentTs = info->persentTime;
            uint8_t resetId = info->resetId;
            NSTimeInterval intervalSinceZero = currentTs * LOGGING_SEC_PER_TIMESTAMP * -1;
            // Safe because we are on the MetaWear Queue
            self.device.nonVolatileState.logStartingDates[resetId] = [[NSDate date] dateByAddingTimeInterval:intervalSinceZero];
        }
        MBLLog(MBLLogLevelInfo, @"%@Reset-Uid: %d", didReset ? @"[RESET OCCURED] " : @"", info->resetId);
        return [NSNumber numberWithBool:didReset];
    }];
}

#pragma mark - Log Recovery

- (void)processRawEntry:(const mw_log_entry_t *)rawEntry
{
    assert([MBLConstants isMetaWearQueue]);
    if (printOnlyMode) {
        MBLLog(MBLLogLevelInfo, @"[%d] %d:%d - %@", rawEntry->triggerId, rawEntry->resetId, rawEntry->timestamp, [NSData dataWithBytes:rawEntry->data length:4]);
        return;
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
        MBLRawLogEntry *entry = (MBLRawLogEntry *)[NSEntityDescription insertNewObjectForEntityForName:@"MBLRawLogEntry" inManagedObjectContext:managedObjectContext];
        entry.timestamp = timestamp;
        entry.resetId = resetId;
        entry.triggerId = triggerId;
        entry.data = data;
    }];
}

- (void)entriesForTriggerId:(uint8_t)triggerId handler:(MBLArrayErrorHandler)handler
{
    [managedObjectContext performBlock:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MBLRawLogEntry"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"triggerId == %d", triggerId];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]];
        
        NSError *error;
        NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (error) {
            MBLLog(MBLLogLevelError, @"Unable to execute fetch request.\n%@", error);
        }
        if (handler) {
            handler(results, error);
        }
    }];
}

- (void)dropEntriesSinceSave
{
    [managedObjectContext performBlock:^{
        [managedObjectContext rollback];
        MBLLog(MBLLogLevelInfo, @"Rollback");
    }];
}

- (void)deleteAllRejectObjects
{
    [managedObjectContext performBlock:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MBLRejectEntry"];
        
        NSError *error;
        NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (error) {
            MBLLog(MBLLogLevelError, @"Unable to execute fetch request.\n%@", error);
        } else {
            for (MBLRawLogEntry *entry in results) {
                [managedObjectContext deleteObject:entry];
            }
            MBLLog(MBLLogLevelInfo, @"Delete reject entires");
        }
    }];
    // Make sure the save happens right after all these deletes
    [self saveLogAsync:YES];
}

- (void)deleteAllObjects
{
    [managedObjectContext performBlock:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MBLRawLogEntry"];
        
        NSError *error;
        NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (error) {
            MBLLog(MBLLogLevelError, @"Unable to execute fetch request.\n%@", error);
        } else {
            for (MBLRawLogEntry *entry in results) {
                [managedObjectContext deleteObject:entry];
            }
            MBLLog(MBLLogLevelInfo, @"Delete all objects");
        }
    }];
    // Make sure the save happens right after all these deletes
    [self saveLogAsync:YES];
}

- (void)deleteObjects:(NSArray<NSArray *> *)rawEntriesToDelete
{
    [managedObjectContext performBlock:^{
        for (NSArray *array in rawEntriesToDelete) {
            for (MBLRawLogEntry *entry in array) {
                [managedObjectContext deleteObject:entry];
            }
        }
    }];
    // Make sure the save happens right after all these deletes
    [self saveLogAsync:YES];
}

- (void)saveLogAsync:(BOOL)async
{
    if (async) {
        [managedObjectContext performBlock:^{
            NSError *error;
            [managedObjectContext save:&error];
            if (error) {
                MBLLog(MBLLogLevelError, @"Unable to save.\n%@", error);
            }
            MBLLog(MBLLogLevelInfo, @"Save Log Async");
        }];
    } else {
        [managedObjectContext performBlockAndWait:^{
            NSError *error;
            [managedObjectContext save:&error];
            if (error) {
                MBLLog(MBLLogLevelError, @"Unable to save.\n%@", error);
            }
            MBLLog(MBLLogLevelInfo, @"Save Log Sync");
        }];
    }
}

- (NSDate *)guessUidStartingDate:(uint8_t)resetId
{
    MBLLog(MBLLogLevelWarning, @"Multiple unexpected resets, log timestamps are estimated");
    NSDate __block *date = nil;
    [managedObjectContext performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MBLRawLogEntry"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"resetId == %d", (resetId - 1) & LOGGING_RESET_UIDS_MASK];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO]];
        fetchRequest.fetchLimit = 1;
        fetchRequest.includesPropertyValues = NO;
        
        NSError *error;
        NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (error) {
            MBLLog(MBLLogLevelError, @"Unable to execute fetch request.\n%@", error);
        } else {
            MBLRawLogEntry *obj = [results firstObject];
            date = [obj.timestamp dateByAddingTimeInterval:LOGGING_SEC_PER_TIMESTAMP];
        }
    }];
    return date;
}

- (NSMutableArray *)getAllRejectEntries
{
    NSMutableArray __block *entries = nil;
    [managedObjectContext performBlockAndWait:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MBLRejectEntry"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]];
        
        NSError *error;
        NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (error) {
            MBLLog(MBLLogLevelError, @"Unable to execute fetch request.\n%@", error);
        } else {
            entries = [results mutableCopy];
        }
    }];
    return entries.count ? entries : nil;
}

#pragma mark - Core Data stack

- (NSManagedObjectModel *)managedObjectModel
{
    static NSManagedObjectModel *_managedObjectModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _managedObjectModel = [[NSManagedObjectModel alloc] init];
        
        // create the entity
        NSEntityDescription *rawLogEntity = [[NSEntityDescription alloc] init];
        rawLogEntity.name = @"MBLRawLogEntry";
        [rawLogEntity setManagedObjectClassName:@"MBLRawLogEntry"];
        
        // create the attributes
        NSAttributeDescription *timestampAttribute = [[NSAttributeDescription alloc] init];
        timestampAttribute.name = @"timestamp";
        timestampAttribute.attributeType = NSDateAttributeType;
        timestampAttribute.indexed = YES;
        
        NSAttributeDescription *resetIdAttribute = [[NSAttributeDescription alloc] init];
        resetIdAttribute.name = @"resetId";
        resetIdAttribute.attributeType = NSInteger16AttributeType;
        resetIdAttribute.indexed = YES;
        
        NSAttributeDescription *logIdAttribute = [[NSAttributeDescription alloc] init];
        logIdAttribute.name = @"triggerId";
        logIdAttribute.attributeType = NSInteger16AttributeType;
        logIdAttribute.indexed = YES;
        
        NSAttributeDescription *dataAttribute = [[NSAttributeDescription alloc] init];
        dataAttribute.name = @"data";
        dataAttribute.attributeType = NSBinaryDataAttributeType;
        dataAttribute.indexed = NO;
        
        // add attributes to entity
        rawLogEntity.properties = @[timestampAttribute, resetIdAttribute, logIdAttribute, dataAttribute];
        
        
        // create the entity
        NSEntityDescription *rejectBufferEntity = [[NSEntityDescription alloc] init];
        rejectBufferEntity.name = @"MBLRejectEntry";
        [rejectBufferEntity setManagedObjectClassName:@"MBLRejectEntry"];
        
        // create the attributes
        NSAttributeDescription *rejectTimestampAttribute = [[NSAttributeDescription alloc] init];
        rejectTimestampAttribute.name = @"timestamp";
        rejectTimestampAttribute.attributeType = NSDateAttributeType;
        rejectTimestampAttribute.indexed = YES;
        
        NSAttributeDescription *rejectDataAttribute = [[NSAttributeDescription alloc] init];
        rejectDataAttribute.name = @"data";
        rejectDataAttribute.attributeType = NSBinaryDataAttributeType;
        rejectDataAttribute.indexed = NO;
        
        // add attributes to entity
        rejectBufferEntity.properties = @[rejectTimestampAttribute, rejectDataAttribute];
        
        
        // add entity to model
        _managedObjectModel.entities = @[rawLogEntity, rejectBufferEntity];
    });
    return _managedObjectModel;
}

@end
