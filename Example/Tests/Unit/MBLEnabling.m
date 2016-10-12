/**
 * MBLEnabling.m
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


@interface MBLEnabling : MBLMockMetaWearUnitTest

@end

@implementation MBLEnabling

///
/// TODO: These all need to be enabled and automated
///
- (void)testProximity
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];
    
    [[self.device.proximity.proximity readAsync] success:^(MBLNumericData * _Nonnull result) {
        [waitingExpectation fulfill];
    }];

    [self waitForExpectationsWithTimeout:2000000000 handler:nil];
}


- (void)testHumidity
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];

    //[[self.device.hygrometer.humidity readAsync] success:^(MBLNumericData * _Nonnull result) {
    //    [waitingExpectation fulfill];
    //}];
    
    MBLHygrometerBME280 *hygrometer = (MBLHygrometerBME280 *)self.device.hygrometer;
    [hygrometer.periodicHumidity startNotificationsWithHandlerAsync:^(MBLNumericData * _Nullable obj, NSError * _Nullable error) {
        [waitingExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:2000000000 handler:nil];
}


- (void)testColor
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];
    
    //[[self.device.hygrometer.humidity readAsync] success:^(MBLNumericData * _Nonnull result) {
    //    [waitingExpectation fulfill];
    //}];
    
    MBLPhotometerTCS3472 *photometer = (MBLPhotometerTCS3472 *)self.device.photometer;
    photometer.integrationTime = 1.0;
    photometer.integrationTime = 10000.0;
    [[photometer.color readAsync] success:^(MBLRGBData * _Nonnull result) {
        [waitingExpectation fulfill];
    }];
    [[photometer.redColor readAsync] success:^(MBLNumericData * _Nonnull result) {
        
    }];

    [self waitForExpectationsWithTimeout:2000000000 handler:nil];
}


- (void)testProgramCommands
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];
    
    
    // Event causes read to be logged
    //[aReg logReads];
    
    MBLI2CData *whoami = [self.device.serial dataAtDeviceAddress:0x1C registerAddress:0x0D length:1];
    MBLEvent *event = [self.device.mechanicalSwitch.switchUpdateEvent readDataOnEvent:whoami];
    [event startNotificationsWithHandlerAsync:^(id obj, NSError *error) {
        NSLog(@"%@", obj);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [event stopNotificationsAsync];
    });
    //[self.device.mechanicalSwitch.switchUpdateEvent programCommandsToRunOnEventAsync:^{
    //[self.device.hapticBuzzer startHapticWithDutyCycle:248 pulseWidth:500 completion:nil]; // Write
    //[aReg readAsync]; // Read
    //[self.device.accelerometer.dataReadyEvent startLoggingAsync];  // Start log
    //}];
    //int __block count = 0;
    //MBLEvent *event = [self.device.timer eventWithPeriod:1000];
    //    [event startNotificationsWithHandlerAsync:^(MBLNumericData * _Nullable obj, NSError * _Nullable error) {
    //        NSLog(@"%@", obj);
    //        if (++count == 4) {
    //            [[event stopNotificationsAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull task) {
    //                [waitingExpectation fulfill];
    //                return nil;
    //            }];
    //        }
    //    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.mock spoofData:@[@"0C-06-00"]];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.mock spoofData:@[@"0C-06-00"]];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.mock spoofData:@[@"0C-06-00"]];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self.mock spoofData:@[@"0C-06-00"]];
                });
            });
        });
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2000000000 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [waitingExpectation fulfill];
    });
    
    [self waitForExpectationsWithTimeout:2000000000 handler:nil];
}




- (void)testTimer
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];
    
    int __block count = 0;
    MBLEvent<MBLDataSample *> *event = [self.device.timer eventWithPeriod:1000];
    BFTask *task = [event startNotificationsWithHandlerAsync:^(MBLDataSample * _Nullable obj, NSError * _Nullable error) {
        NSLog(@"%@", obj);
        if (++count == 4) {
            [[event stopNotificationsAsync] success:^(id  _Nonnull result) {
                [waitingExpectation fulfill];
            }];
        }
    }];
    
    [task continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        XCTAssertFalse(task.faulted);
        [self.mock spoofData:@[@"0C-06-00",
                               @"0C-06-00",
                               @"0C-06-00",
                               @"0C-06-00"]];
        return nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testANCS
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];
    
    int __block count = 0;
    MBLEvent<MBLANCSEventData *> *event = [self.device.ancs eventWithCategoryIds:MBLANCSCategoryIDAny];
    BFTask *task = [event startNotificationsWithHandlerAsync:^(MBLANCSEventData * _Nullable obj, NSError * _Nullable error) {
        NSLog(@"%@", obj);
        if (++count == 4) {
            [[event stopNotificationsAsync] continueOnDispatchWithBlock:^id _Nullable(BFTask * _Nonnull task) {
                [waitingExpectation fulfill];
                return nil;
            }];
        }
    }];
    
    [task continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        XCTAssertFalse(task.faulted);
        [self.mock spoofData:@[@"0E-05-00-00-00-00-00",
                               @"0E-05-00-01-00-00-00",
                               @"0E-05-00-02-00-00-00",
                               @"0E-05-00-04-00-00-00"]];
        return nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testFilters
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];
    
    int __block count = 0;
    MBLEvent<MBLNumericData *> *event = [self.device.mechanicalSwitch.switchUpdateEvent compareEventUsingOperation:MBLComparisonOperationEqual data:@[@0] output:MBLComparisonOutputValue];
    BFTask *task = [event startNotificationsWithHandlerAsync:^(MBLNumericData * _Nullable obj, NSError * _Nullable error) {
        NSLog(@"%@", obj);
        if (++count == 4) {
            [[event stopNotificationsAsync] success:^(id _Nonnull result) {
                [waitingExpectation fulfill];
            }];
        }
    }];
    
    [task continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        XCTAssertFalse(task.faulted);
        [self.mock spoofData:@[@"09-03-00-00",
                               @"09-03-00-00",
                               @"09-03-00-00",
                               @"09-03-00-00"]];
        return nil;
    }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testNeoPixelException
{
    const int length = 30;
    const MBLColorOrdering color = MBLColorOrderingRGB;
    const MBLStrandSpeed speed = MBLStrandSpeedSlow;
    MBLNeopixelStrand *strand = [self.device.neopixel strandWithColor:color speed:speed pin:0 length:length];
    
    XCTAssertNoThrow([strand deinitializeAsync]);
    XCTAssertThrows([strand setPixelAsync:0 color:[MBLColor whiteColor]]);
    XCTAssertThrows([strand setRainbowWithHoldAsync:YES]);
    XCTAssertThrows([strand clearFromStartPixelAsync:0 endPixel:1]);
    XCTAssertThrows([strand clearAllPixelsAsync]);
    XCTAssertThrows([strand holdStrandWithEnableAsync:YES]);
    XCTAssertThrows([strand rotateStrandWithDirectionAsync:MBLRotationDirectionAwayFromBoard repetitions:1 period:100]);
    
    [strand initializeAsync];
    
    XCTAssertThrows([strand setPixelAsync:100 color:[MBLColor whiteColor]]);
    XCTAssertThrows([strand clearFromStartPixelAsync:100 endPixel:0]);
    XCTAssertThrows([strand clearFromStartPixelAsync:20 endPixel:50]);
    
    [strand deinitializeAsync];
}

- (void)testNeoPixel
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];
    
    const int length = 30;
    const MBLColorOrdering color = MBLColorOrderingRGB;
    const MBLStrandSpeed speed = MBLStrandSpeedSlow;
    
    MBLNeopixelStrand *strand = [self.device.neopixel strandWithColor:color speed:speed pin:0 length:length];
    [[[[strand initializeAsync] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [strand setPixelAsync:0 color:[MBLColor whiteColor]];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [strand deinitializeAsync];
    }] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        XCTAssertFalse(task.faulted);
        [waitingExpectation fulfill];
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
    
    /*
     [strand holdStrandWithEnable:YES];
     
     for (int i = 0; i < 3; i++) {
     [strand setPixel:0 + (i * 10) color:[MBLColor redColor]];
     [strand setPixel:1 + (i * 10) color:[MBLColor greenColor]];
     [strand setPixel:2 + (i * 10) color:[MBLColor blueColor]];
     [strand setPixel:3 + (i * 10) color:[MBLColor cyanColor]];
     [strand setPixel:4 + (i * 10) color:[MBLColor yellowColor]];
     [strand setPixel:5 + (i * 10) color:[MBLColor magentaColor]];
     [strand setPixel:6 + (i * 10) color:[MBLColor orangeColor]];
     [strand setPixel:7 + (i * 10) color:[MBLColor purpleColor]];
     [strand setPixel:8 + (i * 10) color:[MBLColor brownColor]];
     [strand setPixel:9 + (i * 10) color:[MBLColor whiteColor]];
     }
     [strand holdStrandWithEnable:NO];
     
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
     [strand rotateStrandWithDirection:MBLRotationDirectionTowardsBoard repetitions:0xFF period:250];
     });
     
     XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"pause for manual verification"];
     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(30.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
     [strand clearAllPixels];
     [strand deinitialize];
     [waitingExpectation fulfill];
     });
     [self waitForExpectationsWithTimeout:35 handler:nil];
     */
    [strand deinitializeAsync];
}


- (void)testGpioReadEnable
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for readings"];
    
    // TODO: Can we check this works better
    MBLGPIOPin *pin = self.device.gpio.pins[0];
    
    MBLData *x = [pin analogRatioWithPullUp:@1 pullDown:nil readDelay:200];
    [[x readAsync] success:^(MBLNumericData * _Nonnull result) {
        NSLog(@"%@", result);
        XCTAssertEqualWithAccuracy(result.value.floatValue, 0.006843, 0.25);
        [waitingExpectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testiBeaconException
{
    MBLiBeacon *iBeacon = self.device.iBeacon;
    XCTAssertThrows(iBeacon.calibratedReceiverPower = -129);
    XCTAssertThrows(iBeacon.calibratedReceiverPower = -9);
    XCTAssertThrows(iBeacon.calibratedReceiverPower = 0);
    XCTAssertThrows(iBeacon.calibratedReceiverPower = 100);
    XCTAssertThrows(iBeacon.frequency = 19);
    XCTAssertThrows(iBeacon.frequency = 10241);
}

- (void)testiBeacon
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for readings"];
    
    MBLiBeacon *iBeacon = self.device.iBeacon;
    iBeacon.uuid = [CBUUID UUIDWithString:@"326A9001-85CB-9195-D9DD-464CFBBAE75A"];
    iBeacon.major = 0x100;
    iBeacon.minor = 0x200;
    iBeacon.calibratedReceiverPower = -128;
    iBeacon.calibratedReceiverPower = -10;
    iBeacon.transmitPower = MBLiBeaconTransmitPowerMinus12dBm;
    iBeacon.frequency = 20;
    iBeacon.frequency = 10240;
    [[[iBeacon setBeaconOnAsync:YES] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [iBeacon setBeaconOnAsync:NO];
    }] continueOnMetaWearWithBlock:^id _Nullable(BFTask * _Nonnull task) {
        XCTAssertFalse(task.faulted);
        [waitingExpectation fulfill];
        return nil;
    }];
    
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

/*
 - (void)testFullLogDownload
 {
 XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"wait for reads"];
 
 [self.device.mechanicalSwitch.switchUpdateEvent startLoggingAsync];
 [self spoofData:@[@"0B-02-00"]];
 
 const int size = 5;//524288;
 [self.device.mechanicalSwitch.switchUpdateEvent downloadLogAndStopLogging:YES handler:^(NSArray *array, NSError *error) {
 XCTAssertEqual(array.count, size * 2);
 [waitingExpectation fulfill];
 } progressHandler:^(float number, NSError *error) {
 }];
 
 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
 [self spoofData:@[@"0B-84-CA-0A-00-00-00"]];
 });
 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
 [self spoofData:@[@"0B-85-28-04-00-00"]];
 });
 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
 self.spoof.value = [self dataFromString:@"0B-07-00-AC-07-00-00-00-01-00-00-00-BA-07-00-00-00-01-00-00"];
 for (int i = 0; i < size; i++) {
 [self.device peripheral:nil didUpdateValueForCharacteristic:self.spoof error:nil];
 }
 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
 [self spoofData:@[@"0B-08-00-00-00-00"]];
 });
 });
 
 [self waitForExpectationsWithTimeout:5000 handler:nil];
 }
 */

@end
