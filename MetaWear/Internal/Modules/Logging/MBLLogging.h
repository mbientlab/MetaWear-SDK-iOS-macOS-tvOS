/**
 * MBLLogging.h
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

#import "MBLModule+Private.h"
#import "MBLConstants.h"
#import <CoreData/CoreData.h>
@class MBLAnonymousEvent;

NS_ASSUME_NONNULL_BEGIN

typedef struct __attribute__((packed)) {
    uint8_t		logTriggers;
    uint32_t    logCap;
} mw_log_module_info;

typedef struct __attribute__((packed)) {
    uint8_t		triggerId:5;
    uint8_t		resetId:3;
    uint32_t	timestamp;
    uint8_t		data[4];
} mw_log_entry_t;

typedef struct __attribute__((packed)) {
    uint8_t		source_modid;
    uint8_t		source_regid;
    uint8_t		source_index;
    uint8_t		source_offset:5;
    uint8_t		source_datalen:2;
    uint8_t		valid:1;
} mw_log_trigger_t;

static const double LOGGING_SEC_PER_TIMESTAMP = 0.00146484375;
static NSString * const kMBLStartingDatesKey = @"com.mbientlab.metawear.logStartingDates";
// The logger timestamp rolls over at 32bits
static const uint64_t LOGGING_ROLLOVER_COUNT = 0x100000000;

@class MBLEvent;
@interface MBLLogging : MBLModule {
@public
    // Special hook points for testing
    BOOL    noAckMode;
    BOOL    printOnlyMode;
    
    // Real ivars
    NSObject            *handlerMutex;
    BOOL                isDownloading;
    NSMutableArray      *progressHandlers;
    NSMutableArray      *downloadHandlers;
    dispatch_queue_t    logProcessingQueue;
    dispatch_group_t    logProcessingGroup;
    BOOL                newPageStarted;
    NSMutableArray      *rawLogEntiresToReject;
    NSManagedObjectContext *managedObjectContext;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
}
@property (nonatomic) NSMutableArray *triggers;
@property (nonatomic, nullable) NSNumber *currentResetId;
@property (nonatomic) uint32_t lastTimestamp;
@property (nonatomic) uint8_t lastResetId;
@property (nonatomic) uint8_t remainingTriggers;

@property (nonatomic) MBLRegister *addLogTrigger;
@property (nonatomic) MBLRegister *removeLogTrigger;
@property (nonatomic) MBLRegister *currentTime;
@property (nonatomic) MBLRegister *logLength;
@property (nonatomic) MBLRegister *logReadout;
@property (nonatomic) MBLRegister *logReadoutNotify;
@property (nonatomic) MBLRegister *logReadoutProgress;
@property (nonatomic) MBLRegister *dropEntries;
@property (nonatomic) MBLRegister *removeAllTriggers;
@property (nonatomic) MBLRegister *circularBufferMode;
@property (nonatomic) MBLRegister *recycledPageCount;
@property (nonatomic, nullable) MBLRegister *readoutPageComplete;
@property (nonatomic, nullable) MBLRegister *readoutPageConfirm;

- (BFTask *)startLoggingAsyncEvent:(MBLEvent *)event;
- (BFTask *)stopLoggingEvent:(MBLEvent *)event;
/**
 Fetch entire contents of log from MetaWear.  Executes the progressHandler
 periodically with the progress (0.0 - 1.0), progressHandler will get called
 with 1.0 before handler is called.
 @param progressHandler Periodically called while log download is in progress
 */
- (BFTask<NSArray *> *)downloadLogEvents:(MBLEvent *)event
                         progressHandler:(MBLLogProgressHandler)progressHandler;


- (BFTask *)stopAndClearLog;
- (BFTask *)dropAllEntries;

- (BFTask *)startReadout:(uint32_t)totalEntries;

- (BFTask<NSNumber *> *)checkForResetAsync;

- (BFTask<NSArray<MBLAnonymousEvent *> *> *)queryActiveLoggersAsync;

- (NSDate *)guessUidStartingDate:(uint8_t)resetId;
- (void)deleteAllRejectObjects;

- (void)processRawEntry:(const mw_log_entry_t *)rawEntry;

- (void)performRawReadOutWithHandler:(MBLErrorHandler)handler
                     progressHandler:(MBLLogProgressHandler)progressHandler;

@end

@interface MBLRawLogEntry : NSManagedObject
@property (nonatomic) NSDate *timestamp;
@property (nonatomic) int16_t resetId;
@property (nonatomic) int16_t triggerId;
@property (nonatomic) NSData *data;
@end

@interface MBLRejectEntry : NSManagedObject
@property (nonatomic) NSDate *timestamp;
@property (nonatomic) NSData *data;
@end

NS_ASSUME_NONNULL_END
