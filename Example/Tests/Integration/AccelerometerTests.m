/**
 * AccelerometerTests.m
 * MetaWearTests
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

#import "MetaWearTest.h"

@interface AccelerometerTests : MetaWearTest
@end

@implementation AccelerometerTests

- (void)testDataUpdates
{
    self.device.accelerometer.sampleFrequency = 800;
    [self eventUpdateTest:self.device.accelerometer.dataReadyEvent time:3];
}

- (void)testDataLogging
{
    self.device.accelerometer.sampleFrequency = 100;
    [self eventLoggingTest:self.device.accelerometer.dataReadyEvent time:2];
}

- (void)testXAxisUpdates
{
    self.device.accelerometer.sampleFrequency = 50;
    [self eventUpdateTest:self.device.accelerometer.xAxisReadyEvent time:5];
}

- (void)testXAxisLogging
{
    self.device.accelerometer.sampleFrequency = 50;
    [self eventLoggingTest:self.device.accelerometer.xAxisReadyEvent time:5];
}

- (void)testYAxisUpdates
{
    self.device.accelerometer.sampleFrequency = 50;
    [self eventUpdateTest:self.device.accelerometer.yAxisReadyEvent time:5];
}

- (void)testYAxisLogging
{
    self.device.accelerometer.sampleFrequency = 50;
    [self eventLoggingTest:self.device.accelerometer.yAxisReadyEvent time:5];
}

- (void)testZAxisUpdates
{
    self.device.accelerometer.sampleFrequency = 50;
    [self eventUpdateTest:self.device.accelerometer.zAxisReadyEvent time:5];
}

- (void)testZAxisLogging
{
    self.device.accelerometer.sampleFrequency = 50;
    [self eventLoggingTest:self.device.accelerometer.zAxisReadyEvent time:5];
}

- (void)testRMSUpdates
{
    [self eventUpdateTest:self.device.accelerometer.rmsDataReadyEvent time:5];
}

- (void)testRMSLogging
{
    [self eventLoggingTest:self.device.accelerometer.rmsDataReadyEvent time:5];
}

- (void)testLogRecovery
{
    [self.device.accelerometer.rmsDataReadyEvent startLoggingAsync];
    
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"testLogRecovery"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.device.testDebug resetDevice];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[self.device connectAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
                XCTAssertNil(t.error);
                [self.device.accelerometer.rmsDataReadyEvent startLoggingAsync];
                [[self.device.accelerometer.rmsDataReadyEvent downloadLogAndStopLoggingAsync:YES] success:^(NSArray<MBLRMSAccelerometerData *> * _Nonnull result) {
                    for (MBLRMSAccelerometerData *obj in result) {
                        NSLog(@"%@", obj);
                    }
                    [waitingExpectation fulfill];
                }];
                return nil;
            }];
        });
    });
    [self waitForExpectationsWithTimeout:30 handler:nil];
}


- (void)testSummedRMSPeriodicUpdates
{
    MBLEvent *event = [[self.device.accelerometer.rmsDataReadyEvent summationOfEvent] periodicSampleOfEvent:200];
    [self eventUpdateTest:event time:5];
}

- (void)testSummedRMSPeriodicLogging
{
    MBLEvent *event = [[self.device.accelerometer.rmsDataReadyEvent summationOfEvent] periodicSampleOfEvent:200];
    [self eventLoggingTest:event time:5];
}

- (void)testRMSLoggingDisconnect
{
    [self.device.accelerometer.rmsDataReadyEvent startLoggingAsync];
    [[self.device disconnectAsync] success:^(id result) {
        NSLog(@"Bye Bye");
    }];
    
    // Reconnect after a few seconds
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"testRMSLoggingDisconnect"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self.device connectAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
            XCTAssertNil(t.error);
            XCTAssertTrue(self.device.accelerometer.rmsDataReadyEvent.isLogging);
            [[self.device.accelerometer.rmsDataReadyEvent downloadLogAndStopLoggingAsync:YES] success:^(NSArray<MBLRMSAccelerometerData *> * _Nonnull result) {
                for (MBLRMSAccelerometerData *obj in result) {
                    NSLog(@"Log: %@", obj);
                }
                [waitingExpectation fulfill];
            }];
            return nil;
        }];
    });
    [self waitForExpectationsWithTimeout:60 handler:nil];
}

@end
