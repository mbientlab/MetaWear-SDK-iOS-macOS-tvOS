/**
 * MBLLogDatabase.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 12/3/15.
 * Copyright 2015 MbientLab Inc. All rights reserved.
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

#import "MBLMockMetaWearUnitTest.h"

@interface MBLLogDatabase : MBLMockMetaWearUnitTest

@end

@implementation MBLLogDatabase

///
/// TODO: These all need to be enabled and automated
///
- (void)testCreateDB
{
    NSString *filename = [[MBLMetaWearManager sharedManager] logFilename:[self.device.identifier.UUIDString stringByAppendingString:@"RawEntries.sqlite3"]];
    NSURL *storeURL = [NSURL fileURLWithPath:filename isDirectory:NO];
    [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil];
    
    NSManagedObjectContext *managedObjectContext = nil;//TODO[self.device.logging managedObjectContext];
    for (uint64_t i = 0; i < 1000000; i++) {
        @autoreleasepool {
            MBLRawLogEntry *entry = (MBLRawLogEntry *)[NSEntityDescription insertNewObjectForEntityForName:@"MBLRawLogEntry" inManagedObjectContext:managedObjectContext];
            entry.timestamp = [NSDate dateWithTimeIntervalSince1970:i];
            entry.resetId = 0;
            entry.triggerId = 0;
            uint32_t x = arc4random();
            entry.data = [NSData dataWithBytes:&x length:4];
        }
    }
    
    NSError *error;
    [managedObjectContext save:&error];
    if (error) {
        NSLog(@"Unable to execute save.");
        NSLog(@"%@, %@", error, error.localizedDescription);
        
    } else {
        NSLog(@"Save good");
    }
}
/*
- (void)testFindNumToDrop
{
    NSManagedObjectContext *managedObjectContext = [self.device.logging managedObjectContext];
    
    [self measureBlock:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MBLRawLogEntry"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"timestamp == %@", [NSDate dateWithTimeIntervalSince1970:999900]];
        fetchRequest.includesPropertyValues = NO;
        
        NSError *error;
        NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (error) {
            NSLog(@"Unable to execute fetch request.");
            NSLog(@"%@, %@", error, error.localizedDescription);
        } else {
            NSManagedObject *obj = [results firstObject];
            NSDate *x = [obj valueForKey:@"timestamp"];
            
            NSFetchRequest *fetch2 = [NSFetchRequest fetchRequestWithEntityName:@"MBLRawLogEntry"];
            fetch2.predicate = [NSPredicate predicateWithFormat:@"timestamp >= %@", x];
            NSUInteger count = [managedObjectContext countForFetchRequest:fetch2 error:&error];
            NSLog(@"%ld", count);
        }
    }];
}

- (void)testFindNewestUidDate
{
    [self measureBlock:^{
        [self.device.logging guessUidStartingDate:1];
    }];
}

- (void)testQueryForTriggerId
{
    NSManagedObjectContext *managedObjectContext = [self.device.logging managedObjectContext];
    
    [self measureBlock:^{
        [managedObjectContext performBlockAndWait:^{
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MBLRawLogEntry"];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"triggerId == %d", 0];
            
            NSError *error;
            NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (error) {
                NSLog(@"Unable to execute fetch request.");
                NSLog(@"%@, %@", error, error.localizedDescription);
            } else {
                NSLog(@"%ld", results.count);
            }
        }];
    }];
}

- (void)testQueryForEntry
{
    NSManagedObjectContext *managedObjectContext = [self.device.logging managedObjectContext];
    
    [self measureBlock:^{
        [managedObjectContext performBlockAndWait:^{
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MBLRawLogEntry"];
            fetchRequest.predicate = [NSPredicate predicateWithFormat:@"timestamp == %@", [NSDate dateWithTimeIntervalSince1970:456]];
            fetchRequest.includesPropertyValues = NO;
            
            NSError *error;
            NSUInteger count = [managedObjectContext countForFetchRequest:fetchRequest error:&error];
            if (error) {
                NSLog(@"Unable to execute fetch request.");
                NSLog(@"%@, %@", error, error.localizedDescription);
            } else {
                NSLog(@"%ld", count);
            }
        }];
    }];
}

- (void)testDeleteFetch
{
    NSManagedObjectContext *managedObjectContext = [self.device.logging managedObjectContext];
    
    [self measureBlock:^{
        NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"MBLRawLogEntry"];
        fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]];
        fetchRequest.fetchLimit = 1;
        fetchRequest.includesPropertyValues = NO;
        
        NSError *error;
        NSArray *results = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (error) {
            NSLog(@"Unable to execute fetch request.");
            NSLog(@"%@, %@", error, error.localizedDescription);
        } else {
            MBLRawLogEntry *obj = [results firstObject];
            NSLog(@"%@, %@", obj.timestamp, obj.data);
        }
    }];
}

*/
@end
