/**
 * MBLMetaBootTests.m
 * MetaWearUnitTests
 *
 * Created by Stephen Schiffli on 9/28/16.
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

#import "MBLMockMetaWearUnitTest.h"

@interface MBLMetaBootTests : MBLMockMetaWearUnitTest
@end

@implementation MBLMetaBootTests

- (void)testFirmwareUpdateManager
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for completion"];
    
    [[[[MBLFirmwareUpdateManager isFirmwareReachableAsync] continueOnDispatchWithSuccessBlock:^id _Nullable(BFTask<NSNumber *> * _Nonnull t) {
        MBLDeviceInfo *info = [[MBLDeviceInfo alloc] init];
        info.modelNumber = @"0";
        info.hardwareRevision = @"0.1";
        return [MBLFirmwareUpdateManager getLatestFirmwareForDeviceAsync:info];
    }] continueOnDispatchWithSuccessBlock:^id (BFTask<MBLFirmwareBuild *> *t) {
        XCTAssertTrue([t.result.firmwareURL.absoluteString isEqualToString:@"https://mbientlab.com/releases/metawear/0.1/0/vanilla/1.2.5/firmware.bin"]);
        return [MBLFirmwareUpdateManager downloadFirmwareVersionAsync:t.result];
    }] continueOnDispatchWithBlock:^id _Nullable(BFTask<NSNumber *> * _Nonnull t) {
        XCTAssertNil(t.error);
        [waitingExpectation fulfill];
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:20 handler:nil];
}

#if TARGET_OS_SIMULATOR
- (void)testUpdateManager
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for completion"];

    [[self.device prepareForFirmwareUpdateAsync] failure:^(NSError * _Nonnull error) {
        // TODO: Maybe mock out the firmware update manager, for now we expect it to fail at that point
        XCTAssertEqual(error.code, kMBLErrorBluetoothUnsupported);
        [waitingExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:20 handler:nil];
}
#endif

@end
