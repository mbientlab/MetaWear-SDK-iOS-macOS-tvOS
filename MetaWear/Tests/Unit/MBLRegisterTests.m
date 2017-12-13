/**
 * MBLRegisterTests.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 12/13/17.
 * Copyright 2017 MbientLab Inc. All rights reserved.
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

///
/// Helpful utils - DRY
///
@interface GlobalStuff : NSObject
+ (BFTask *)disconnectError;
@end
@implementation GlobalStuff
+ (BFTask *)disconnectError
{
    return [BFTask taskWithError:
            [NSError errorWithDomain:kMBLErrorDomain
                                code:kMBLErrorUnexpectedDisconnect
                            userInfo:@{NSLocalizedDescriptionKey : @"Unexpected disconnect.  Please connect again to perform operation."}]];
}
@end

///
/// Create a module that can produce errors on demand
///
@interface MBLErrorModule : MBLModule
@property (nonatomic) BOOL initError;
@property (nonatomic) BOOL deinitError;
@property (nonatomic) BOOL activateError;
@property (nonatomic) BOOL deactivateError;
@end
@implementation MBLErrorModule
- (instancetype)initWithDevice:(MBLMetaWear *)device
{
    self = [super initWithDevice:device moduleInfo:[[MBLModuleInfo alloc] init]];
    if (self) {
        self.initError = NO;
        self.deinitError = NO;
        self.activateError = NO;
        self.deactivateError = NO;
    }
    return self;
}
- (BFTask *)performAsyncInitialization
{
    return self.initError ? [GlobalStuff disconnectError] : [BFTask taskWithResult:nil];
}
- (BFTask *)performAsyncDeinitialization
{
    return self.deinitError ? [GlobalStuff disconnectError] : [BFTask taskWithResult:nil];
}
- (BFTask *)performAsyncActivation
{
    return self.activateError ? [GlobalStuff disconnectError] : [BFTask taskWithResult:nil];
}
- (BFTask *)performAsyncDeactivation
{
    return self.deactivateError ? [GlobalStuff disconnectError] : [BFTask taskWithResult:nil];
}
@end

///
/// Create a register that can produce errors on demand
///
@interface MBLErrorEvent : MBLEvent
@property (nonatomic) BOOL initError;
@property (nonatomic) BOOL deinitError;
@property (nonatomic) BOOL activateError;
@property (nonatomic) BOOL deactivateError;
@end
@implementation MBLErrorEvent
- (instancetype)initWithModule:(MBLModule *)module
{
    self = [super initWithModule:module registerId:0x1 index:0x1 format:[[MBLFormat alloc] initEncodedDataWithLength:1]];
    return self;
}
- (BFTask *)performAsyncInitialization
{
    return self.initError ? [GlobalStuff disconnectError] : [BFTask taskWithResult:nil];
}
- (BFTask *)performAsyncDeinitialization
{
    return self.deinitError ? [GlobalStuff disconnectError] : [BFTask taskWithResult:nil];
}
- (BFTask *)performAsyncActivation
{
    return self.activateError ? [GlobalStuff disconnectError] : [BFTask taskWithResult:nil];
}
- (BFTask *)performAsyncDeactivation
{
    return self.deactivateError ? [GlobalStuff disconnectError] : [BFTask taskWithResult:nil];
}
@end



@interface MBLRegisterTests : XCTestCase
@property (nonatomic) MBLMetaWear *device;
@property (nonatomic) MBLErrorModule *module;
@property (nonatomic) MBLErrorEvent *event;
@end

@implementation MBLRegisterTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    self.device = [[MBLMetaWear alloc] init];
    self.device.state = MBLConnectionStateConnected;
    self.module = [[MBLErrorModule alloc] initWithDevice:self.device];
    self.event = [[MBLErrorEvent alloc] initWithModule:self.module];
}

- (void)testRegisterActivateErrors
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for device"];

    self.event.activateError = YES;
    [[[[[self.event startNotificationsWithHandlerAsync:^(id  _Nullable obj, NSError * _Nullable error) {
        XCTFail(@"Should never call due to init error");
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNotNil(t.error);
        XCTAssertFalse(self.event.isNotifying);
        return [self.event stopNotificationsAsync];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        self.event.activateError = NO;
        return [self.event startNotificationsWithHandlerAsync:^(id  _Nullable obj, NSError * _Nullable error) {
            XCTFail(@"Should never call");
        }];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        return [self.event stopNotificationsAsync];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        [waitingExpectation fulfill];
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testRegisterInitializeErrors
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for device"];
    
    self.event.initError = YES;
    [[[[[self.event startNotificationsWithHandlerAsync:^(id  _Nullable obj, NSError * _Nullable error) {
        XCTFail(@"Should never call due to init error");
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNotNil(t.error);
        XCTAssertFalse(self.event.isNotifying);
        return [self.event stopNotificationsAsync];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        self.event.initError = NO;
        return [self.event startNotificationsWithHandlerAsync:^(id  _Nullable obj, NSError * _Nullable error) {
            XCTFail(@"Should never call");
        }];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        return [self.event stopNotificationsAsync];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        [waitingExpectation fulfill];
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testRegisterDeactivateErrors
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for device"];
    
    self.event.deactivateError = YES;
    [[[[self.event startNotificationsWithHandlerAsync:^(id  _Nullable obj, NSError * _Nullable error) {
        XCTFail(@"Should never call due to init error");
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        XCTAssertTrue(self.event.isNotifying);
        return [self.event stopNotificationsAsync];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNotNil(t.error);
        self.event.deactivateError = NO;
        return [self.event stopNotificationsAsync];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        [waitingExpectation fulfill];
        return nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testRegisterDeinitErrors
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for device"];
    
    self.event.deinitError = YES;
    [[[[self.event startNotificationsWithHandlerAsync:^(id  _Nullable obj, NSError * _Nullable error) {
        XCTFail(@"Should never call due to init error");
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        XCTAssertTrue(self.event.isNotifying);
        return [self.event stopNotificationsAsync];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNotNil(t.error);
        self.event.deinitError = NO;
        return [self.event stopNotificationsAsync];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        [waitingExpectation fulfill];
        return nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}



- (void)testCommandActivateErrors
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for device"];
    
    self.event.activateError = YES;
    [[[[[self.event programCommandsToRunOnEventAsync:^{
        // Do nothing
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNotNil(t.error);
        XCTAssertFalse(self.event.hasCommands);
        return [self.event eraseCommandsToRunOnEventAsync];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNotNil(t.error);
        self.event.activateError = NO;
        return [self.event programCommandsToRunOnEventAsync:^{
            // Do nothing
        }];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        return [self.event eraseCommandsToRunOnEventAsync];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        [waitingExpectation fulfill];
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testCommandInitializeErrors
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for device"];
    
    self.event.initError = YES;
    [[[[[self.event programCommandsToRunOnEventAsync:^{
         // Do nothing
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNotNil(t.error);
        XCTAssertFalse(self.event.hasCommands);
        return [self.event eraseCommandsToRunOnEventAsync];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNotNil(t.error);
        self.event.initError = NO;
        return [self.event programCommandsToRunOnEventAsync:^{
            // Do nothing
        }];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        return [self.event eraseCommandsToRunOnEventAsync];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        [waitingExpectation fulfill];
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testCommandDeactivateErrors
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for device"];
    
    self.event.deactivateError = YES;
    [[[[self.event programCommandsToRunOnEventAsync:^{
        // Do nothing
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        XCTAssertTrue(self.event.hasCommands);
        return [self.event eraseCommandsToRunOnEventAsync];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNotNil(t.error);
        self.event.deactivateError = NO;
        return [self.event eraseCommandsToRunOnEventAsync];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        [waitingExpectation fulfill];
        return nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testCommandDeinitErrors
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for device"];
    
    self.event.deinitError = YES;
    [[[[self.event programCommandsToRunOnEventAsync:^{
        // Do nothing
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        XCTAssertTrue(self.event.hasCommands);
        return [self.event eraseCommandsToRunOnEventAsync];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNotNil(t.error);
        self.event.deinitError = NO;
        return [self.event eraseCommandsToRunOnEventAsync];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        [waitingExpectation fulfill];
        return nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}



- (void)testLoggingActivateErrors
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for device"];
    
    self.event.activateError = YES;
    [[[[[self.event startLoggingAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNotNil(t.error);
        XCTAssertFalse(self.event.isLogging);
        return [self.event downloadLogAndStopLoggingAsync:YES];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        self.event.activateError = NO;
        return [self.event startLoggingAsync];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        XCTAssertTrue(self.event.isLogging);
        return [self.event downloadLogAndStopLoggingAsync:YES];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        XCTAssertFalse(self.event.isLogging);
        [waitingExpectation fulfill];
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testLoggingInitializeErrors
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for device"];
    
    self.event.initError = YES;
    [[[[[self.event startLoggingAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNotNil(t.error);
        XCTAssertFalse(self.event.isLogging);
        return [self.event downloadLogAndStopLoggingAsync:YES];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        XCTAssertFalse(self.event.isLogging);
        self.event.initError = NO;
        return [self.event startLoggingAsync];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        XCTAssertTrue(self.event.isLogging);
        return [self.event downloadLogAndStopLoggingAsync:YES];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        XCTAssertFalse(self.event.isLogging);
        [waitingExpectation fulfill];
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testLoggingDeactivateErrors
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for device"];
    
    self.event.deactivateError = YES;
    [[[[self.event startLoggingAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        XCTAssertTrue(self.event.isLogging);
        return [self.event downloadLogAndStopLoggingAsync:YES];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNotNil(t.error);
        XCTAssertTrue(self.event.isLogging);
        self.event.deactivateError = NO;
        return [self.event downloadLogAndStopLoggingAsync:YES];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        XCTAssertFalse(self.event.isLogging);
        [waitingExpectation fulfill];
        return nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testLoggingDeinitErrors
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for device"];
    
    self.event.deinitError = YES;
    [[[[self.event startLoggingAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNil(t.error);
        XCTAssertTrue(self.event.isLogging);
        return [self.event downloadLogAndStopLoggingAsync:YES];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertNotNil(t.error);
        XCTAssertTrue(self.event.isLogging);
        self.event.deinitError = NO;
        return [self.event downloadLogAndStopLoggingAsync:YES];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull t) {
        XCTAssertFalse(self.event.isLogging);
        XCTAssertNil(t.error);
        [waitingExpectation fulfill];
        return nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

@end
