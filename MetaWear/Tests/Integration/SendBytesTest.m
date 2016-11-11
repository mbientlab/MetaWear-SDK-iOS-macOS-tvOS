/**
 * SendBytesTest.m
 * MetaWearTests
 *
 * Created by Stephen Schiffli on 12/16/15.
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

#import <XCTest/XCTest.h>
#import "MetaWearSyntaxFriendly.h"

static const int secondsToConnect = 20;

/*
 This test setup bypasses all the setup code normally run when connecting to a device.
 Useful for doing advanced debugging.
 */
@interface SendBytesTest : XCTestCase
@property (nonatomic, retain) MBLMetaWear *device;
@end

@implementation SendBytesTest

- (void)setUp
{
    [super setUp];
    
    // Put setup code here. This method is called before the invocation of each test method in the class.
    XCTestExpectation *connectDeviceExpectation = [self expectationWithDescription:@"connect to device"];
    [MBLMetaWearManager sharedManager].logLevel = MBLLogLevelInfo;
    [[[[MBLDeviceLookup deviceForTestWithTimeout:10.0] continueOnDispatchWithSuccessBlock:^id _Nullable(BFTask<MBLMetaWear *> * _Nonnull t) {
        MBLMetaWear *device = t.result;
        assert(device);
        device.bypassSetup = YES;
        return [device connectWithTimeoutAsync:secondsToConnect];
    }] success:^(MBLMetaWear * _Nonnull result) {
        self.device = result;
        [connectDeviceExpectation fulfill];
    }] failure:^(NSError * _Nonnull error) {
        self.continueAfterFailure = NO;
        XCTAssertNil(error);
    }];
    // The test will pause here, running the run loop, until the timeout is hit
    // or all expectations are fulfilled.
    [self waitForExpectationsWithTimeout:(secondsToConnect * 2) + 10 handler:nil];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    if (self.device) {
        XCTestExpectation *disconnectDeviceExpectation = [self expectationWithDescription:@"disconnect from device"];
        [[self.device disconnectAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
            XCTAssertNil(t.error);
            [disconnectDeviceExpectation fulfill];
            return nil;
        }];
        [self waitForExpectationsWithTimeout:5 handler:nil];
    }
    [super tearDown];
}

- (void)sendData:(NSArray *)data
{
    for (NSString *byteArray in data) {
        NSData *toSend = [MBLMockUtils dataFromString:byteArray];
        [self.device writeCommandRegister:toSend withResponse:NO];
    }
}

- (void)testFreq
{
//    [self.device.accelerometer.dataReadyEvent addNotificationWithExecutor:[BFExecutor dispatchExecutor] handler:^(id  _Nullable obj, NSError * _Nullable error) {
//        NSLog(@"%@", obj);
//    }];
//    [((MBLBarometerBMP280 *)self.device.barometer).periodicPressure addNotificationWithExecutor:[BFExecutor dispatchExecutor] handler:^(id  _Nullable obj, NSError * _Nullable error) {
//        NSLog(@"%@", obj);
//    }];
    [self sendData:@[@"12-83",
                     @"12-84",
                     @"03-83",
                     @"03-81",
                     @"03-82",
                     @"03-85",
                     @"03-89",
                     @"03-8A",
                     @"03-04-01",
                     @"12-01-01"]];
    
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"pause for manual verification"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2000 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [waitingExpectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5000 handler:nil];
}

- (void)testNukeIt
{
    [self sendData:@[@"0F-08",
                     @"FE-05",
                     @"FE-06"]];
    
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"pause for manual verification"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [waitingExpectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testMetaBoot
{
    [self sendData:@[@"FE-02"]];
    
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"pause for manual verification"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [waitingExpectation fulfill];
    });
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testSomeReads
{
    [self sendData:@[@"14-83"]];
    
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"pause for manual verification"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(20 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [waitingExpectation fulfill];
    });
    [self waitForExpectationsWithTimeout:30 handler:nil];
}

@end
