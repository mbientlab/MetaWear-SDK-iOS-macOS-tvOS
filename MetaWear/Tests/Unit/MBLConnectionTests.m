/**
 * MBLConnectionTests.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 9/27/16.
 * Copyright 2016 MbientLab Inc. All rights reserved.
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
#import <CoreData/CoreData.h>
#import "MetaWearSyntaxFriendly.h"

@interface MBLConnectionTests : XCTestCase
@property (nonatomic) MBLMetaWear *device;
@property (nonatomic) MBLBluetoothPeripheralMock *peripheral;
@property (nonatomic) MBLBluetoothCentralMock *central;

@end

@implementation MBLConnectionTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for device"];
    
    MBLSetUseMockManager(YES);
    [MBLMetaWearManager sharedManager].logLevel = MBLLogLevelInfo;
    
    
    [[MBLMetaWearManager sharedManager] startScanForMetaWearsAllowDuplicates:NO handler:^(NSArray<MBLMetaWear *> *array) {
        [[MBLMetaWearManager sharedManager] stopScan];
        self.device = [array firstObject];
        assert(self.device);
        self.central = (MBLBluetoothCentralMock *)[MBLMetaWearManager sharedManager].centralManager;
        [self.central resetKnobs];
        self.peripheral = [[self.central retrievePeripheralsWithIdentifiers:@[self.device.identifier]] firstObject];
        [self.peripheral resetKnobs];
        [waitingExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for disconnect"];
    [[self.device disconnectAsync] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        [waitingExpectation fulfill];
        return nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
    
    [super tearDown];
}

- (void)testConnectionTimeout
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for device"];

    double tmp = self.central.connectWaitTime;
    self.central.connectWaitTime = 99;
    [[self.device connectWithTimeoutAsync:2] failure:^(NSError * _Nonnull error) {
        XCTAssertEqual(error.code, kMBLErrorConnectionTimeout);
        [waitingExpectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];

    self.central.connectWaitTime = tmp;
}

- (void)testMultiConnectionTimeout
{
    double tmp = self.central.connectWaitTime;
    self.central.connectWaitTime = 1.0;
    
    XCTestExpectation *connect1 = [self expectationWithDescription:@"wait for device1"];
    XCTestExpectation *connect2 = [self expectationWithDescription:@"wait for device2"];
    [[self.device connectWithTimeoutAsync:0.5] failure:^(NSError *error) {
        XCTAssertEqual(error.code, kMBLErrorConnectionTimeout);
        [connect1 fulfill];
    }];
    [[self.device connectWithTimeoutAsync:2.0] success:^(id result) {
        [connect2 fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
    
    self.central.connectWaitTime = tmp;
}

- (void)testMultiConnection
{
    double tmp = self.central.connectWaitTime;
    self.central.connectWaitTime = 0.5;
    
    XCTestExpectation *connect1 = [self expectationWithDescription:@"wait for device1"];
    XCTestExpectation *connect2 = [self expectationWithDescription:@"wait for device2"];
    XCTestExpectation *connect3 = [self expectationWithDescription:@"wait for device3"];
    [[self.device connectAsync] success:^(id result) {
        [connect1 fulfill];
    }];
    [[self.device connectAsync] success:^(id result) {
        [connect2 fulfill];
    }];
    [[self.device connectAsync] success:^(id result) {
        [connect3 fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
    
    self.central.connectWaitTime = tmp;
}

- (void)testConnectDiscovering
{
    double tmp = self.peripheral.discoverServicesWaitTime;
    self.peripheral.discoverServicesWaitTime = 0.5;
    
    XCTestExpectation *connect1 = [self expectationWithDescription:@"wait for device1"];
    XCTestExpectation *connect2 = [self expectationWithDescription:@"wait for device2"];
    XCTestExpectation *connect3 = [self expectationWithDescription:@"wait for device3"];
    [[self.device connectAsync] success:^(id result) {
        [connect1 fulfill];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self.device connectAsync] success:^(id result) {
            [connect2 fulfill];
        }];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self.device connectAsync] success:^(id result) {
            [connect3 fulfill];
        }];
    });

    [self waitForExpectationsWithTimeout:5 handler:nil];
    
    self.peripheral.discoverServicesWaitTime = tmp;
}

- (void)testDisconnectConnecting
{
    double tmp = self.central.connectWaitTime;
    self.central.connectWaitTime = 5.0;
    
    XCTestExpectation *connect1 = [self expectationWithDescription:@"wait for device1"];
    XCTestExpectation *connect2 = [self expectationWithDescription:@"wait for device2"];
    [[self.device connectAsync] failure:^(NSError * _Nonnull error) {
        XCTAssertEqual(error.code, kMBLErrorDisconnectRequested);
        [connect1 fulfill];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self.device disconnectAsync] success:^(id result) {
            [connect2 fulfill];
        }];
    });
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
    
    self.central.connectWaitTime = tmp;
}

- (void)testDisconnectDiscovering
{
    double tmp = self.peripheral.discoverServicesWaitTime;
    self.peripheral.discoverServicesWaitTime = 5.0;
    
    XCTestExpectation *connect1 = [self expectationWithDescription:@"wait for device1"];
    XCTestExpectation *connect2 = [self expectationWithDescription:@"wait for device2"];
    [[self.device connectAsync] failure:^(NSError * _Nonnull error) {
        XCTAssertEqual(error.code, kMBLErrorDisconnectRequested);
        [connect1 fulfill];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[self.device disconnectAsync] success:^(id result) {
            [connect2 fulfill];
        }];
    });
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
    
    self.peripheral.discoverServicesWaitTime = tmp;
}

- (void)testProgrammedByOtherAppConnection
{
    uint32_t tmp = self.peripheral.keyRegister;
    self.peripheral.keyRegister = 0xDEADBEEF;
    
    XCTestExpectation *connect1 = [self expectationWithDescription:@"wait for device"];
    [[self.device connectAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        XCTAssertTrue(self.device.programedByOtherApp);
        [connect1 fulfill];
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
    
    self.peripheral.keyRegister = tmp;
}

- (void)testConnectionWithRetry
{
    self.peripheral.failServiceDiscoveryOnce = YES;
    
    XCTestExpectation *connect1 = [self expectationWithDescription:@"wait for device1"];
    [[[self.device connectAsync] success:^(MBLMetaWear * _Nonnull result) {
        [connect1 fulfill];
    }] failure:^(NSError * _Nonnull error) {
        XCTAssertNil(error);
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
