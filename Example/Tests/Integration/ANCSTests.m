/**
 * ANCSTests.m
 * MetaWearTests
 *
 * Created by Stephen Schiffli on 11/20/14.
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

#import "MetaWearTest.h"

@interface ANCSTests : MetaWearTest
@end

@implementation ANCSTests

- (void)testFilterNothing
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"testFilterNothing"];
    MBLEvent *event = [self.device.ancs eventWithCategoryIds:MBLANCSCategoryIDAny];
    [event startNotificationsWithHandlerAsync:^(id obj, NSError *error) {
        NSLog(@"%@", obj);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(120 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [event stopNotificationsAsync];
        [waitingExpectation fulfill];
    });
    [self waitForExpectationsWithTimeout:130 handler:nil];
}

- (void)testFilterMatchTitle
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"testFilterMatchTitle"];
    MBLEvent *event = [self.device.ancs eventWithCategoryIds:MBLANCSCategoryIDAny
                                                    eventIds:MBLANCSEventIDAny
                                                  eventFlags:MBLANCSEventFlagAny
                                                 attributeId:MBLANCSNotificationAttributeIDTitle
                                               attributeData:@"TestHost"];
    [event startNotificationsWithHandlerAsync:^(id obj, NSError *error) {
        NSLog(@"%@", obj);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(120 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [event stopNotificationsAsync];
        [waitingExpectation fulfill];
    });
    [self waitForExpectationsWithTimeout:130 handler:nil];
}

- (void)testFilterDontMatch
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"testFilterDontMatch"];
    MBLEvent *event = [self.device.ancs eventWithCategoryIds:MBLANCSCategoryIDAny
                                                    eventIds:MBLANCSEventIDAny
                                                  eventFlags:MBLANCSEventFlagAny
                                                 attributeId:MBLANCSNotificationAttributeIDTitle
                                               attributeData:@"TestHost1"];
    [event startNotificationsWithHandlerAsync:^(id obj, NSError *error) {
        NSLog(@"%@", obj);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(120 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [event stopNotificationsAsync];
        [waitingExpectation fulfill];
    });
    [self waitForExpectationsWithTimeout:130 handler:nil];
}

- (void)testFilterSpecificMatch
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"testFilterSpecificMatch"];
    MBLEvent *event = [self.device.ancs eventWithCategoryIds:MBLANCSCategoryIDOther
                                                    eventIds:MBLANCSEventIDNotificationAdded
                                                  eventFlags:MBLANCSEventFlagAny
                                                 attributeId:MBLANCSNotificationAttributeIDMessage
                                               attributeData:@"Test Notification"];
    [event startNotificationsWithHandlerAsync:^(id obj, NSError *error) {
        NSLog(@"%@", obj);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(120 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [event stopNotificationsAsync];
        [waitingExpectation fulfill];
    });
    [self waitForExpectationsWithTimeout:130 handler:nil];
}

- (void)testDisconnectReconnect
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"testDisconnectReconnect"];
    MBLEvent __block *event = [self.device.ancs eventWithCategoryIds:MBLANCSCategoryIDOther
                                                            eventIds:MBLANCSEventIDNotificationAdded
                                                          eventFlags:MBLANCSEventFlagAny
                                                         attributeId:MBLANCSNotificationAttributeIDMessage
                                                       attributeData:@"Test Notification"];
    [event startNotificationsWithHandlerAsync:^(id obj, NSError *error) {
        NSLog(@"%@", obj);
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [event stopNotificationsAsync];
        [[self.device disconnectAsync] success:^(id result) {
            NSLog(@"Bye Bye");
        }];
    });
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self.device connectAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
            XCTAssertNil(t.error);
            event = [self.device.ancs eventWithCategoryIds:MBLANCSCategoryIDOther
                                                  eventIds:MBLANCSEventIDNotificationAdded
                                                eventFlags:MBLANCSEventFlagAny
                                               attributeId:MBLANCSNotificationAttributeIDMessage
                                             attributeData:@"Test Notification"];
            [event startNotificationsWithHandlerAsync:^(id obj, NSError *error) {
                NSLog(@"%@", obj);
            }];
            return nil;
        }];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [event stopNotificationsAsync];
        [waitingExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:130 handler:nil];
}


@end
