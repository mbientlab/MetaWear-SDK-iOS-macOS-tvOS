/**
 * EnablingTests.m
 * MetaWearTests
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

#import "MetaWearTest.h"

@interface MBLBoschTiltFormat : MBLFormat
@property (nonatomic, weak) MBLAccelerometerBosch *accelerometer;
- (instancetype)initWithAccelerometer:(MBLAccelerometerBosch *)accelerometer;
@end

@implementation MBLBoschTiltFormat

- (instancetype)initWithAccelerometer:(MBLAccelerometerBosch *)accelerometer
{
    self = [super initNumberWithLength:4 isSigned:NO];
    if (self) {
        self.accelerometer = accelerometer;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    MBLAccelerometerBoschRMSFormat *newFormat = [super copyWithZone:zone];
    newFormat.accelerometer = self.accelerometer;
    return newFormat;
}

- (id)entryFromData:(NSData *)data date:(NSDate *)date
{
    uint32_t raw = *(uint32_t *)data.bytes;
    double scale;
    switch (self.accelerometer.fullScaleRange) {
        case MBLAccelerometerBoschRange16G:
            scale = 16.0 / 32768.0;
            break;
        case MBLAccelerometerBoschRange8G:
            scale = 8.0 / 32768.0;
            break;
        case MBLAccelerometerBoschRange4G:
            scale = 4.0 / 32768.0;
            break;
        case MBLAccelerometerBoschRange2G:
            scale = 2.0 / 32768.0;
            break;
    }
    double angle;
    if (raw & 0x10000) {
        raw &= 0xffff;
        angle = 180.0 - ((asin(MIN(1.0, (double)raw * scale)) /  M_PI) * 180.0);
    } else {
        angle = ((asin(MIN(1.0, (double)raw * scale)) /  M_PI) * 180.0);
    }
    return [[MBLNumericData alloc] initWithNumber:[NSNumber numberWithDouble:angle] timestamp:date];
}

- (NSNumber *)numberFromDouble:(double)value
{
    return [NSNumber numberWithInt:(int)value];
}

@end



@interface EnablingTests : MetaWearTest
@end

@implementation EnablingTests

- (void)testTraker
{
    XCTestExpectation *waitingExpectation = [self expectationWithDescription:@"testSwitchRead"];
    
    //[MBLMetaWearManager sharedManager].logLevel = MBLLogLevelWarning;
    self.device.accelerometer.sampleFrequency = 100;
    
    MBLEvent *rss = [self.device.accelerometer.dataReadyEvent
                     rssOfEventWithInputLength:2
                     inputCount:2
                     format:[[MBLBoschTiltFormat alloc] initWithAccelerometer:(MBLAccelerometerBosch *)self.device.accelerometer]];
    
    MBLFilter *avg = [rss averageOfEventWithDepth:128];
    MBLFilter *ang = [avg modifyEventUsingOperation:MBLArithmeticOperationAdd withData:0x10000];
    
    MBLFilter *zChange = [self.device.accelerometer.zAxisReadyEvent changeOfEventAcrossThreshold:0.0 hysteresis:0.15 output:MBLThresholdValueOutputBinary];
    MBLFilter *upFacing = [zChange compareEventUsingOperation:MBLComparisonOperationEqual data:@[@1] output:MBLComparisonOutputValue];
    MBLFilter *downFacing = [zChange compareEventUsingOperation:MBLComparisonOperationEqual data:@[@-1] output:MBLComparisonOutputValue];
    
    [[[[avg programCommandsToRunOnEventAsync:^{
        [avg resetAsync];
    }] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        return [ang startNotificationsWithHandlerAsync:^(id  _Nullable obj, NSError * _Nullable error) {
            NSLog(@"%@", obj);
        }];
    }] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        return [upFacing startNotificationsWithHandlerAsync:^(id  _Nullable obj, NSError * _Nullable error) {
            uint8_t data[] = { 0x09, 0x0f, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00 };
            int dataSize = sizeof(data) / sizeof(data[0]);
            [ang resetParametersWithData:[NSData dataWithBytes:&data length:dataSize]];
        }];
    }] continueWithSuccessBlock:^id _Nullable(BFTask * _Nonnull t) {
        return [downFacing programCommandsToRunOnEventAsync:^{
            uint8_t data[] = { 0x09, 0x0f, 0x01, 0x00, 0x00, 0x01, 0x00, 0x00 };
            int dataSize = sizeof(data) / sizeof(data[0]);
            [ang resetParametersWithData:[NSData dataWithBytes:&data length:dataSize]];
        }];
    }];
    
    
//    return [batteryNotCharging programCommandsToRunOnEventAsync:^{
//        //return [batteryNotCharging startNotificationsWithHandlerAsync:^(id  _Nullable obj, NSError * _Nullable error) {
//        uint8_t data[] = { 0x09, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00 };
                             //OURS0x09, 0x0f, 0x01, 0x00, 0x00, 0x01, 0x00, 0x00
//        int dataSize = sizeof(data) / sizeof(data[0]);
//        [batteryChargeArithmetic resetParametersWithData:[NSData dataWithBytes:&data length:dataSize]];
//        [self.device.settings.batteryRemaining localReadAsync];
//    }];
    
//    [[self.device.accelerometer.dataReadyEvent startNotificationsWithHandlerAsync:^(MBLAccelerometerData * _Nullable obj, NSError * _Nullable error) {
//        //NSLog(@"%@", obj);
//        double op = sqrt((obj.y * obj.y) + (obj.x * obj.x));
//        NSLog(@"%f", (atan2(op, obj.z) /  M_PI) * 180.0);
//        NSLog(@"%f", (asin(op) /  M_PI) * 180.0);
//    }] success:^(id  _Nonnull result) {
//        [rss startNotificationsWithHandlerAsync:^(id  _Nullable obj, NSError * _Nullable error) {
//            NSLog(@"%@", obj);
//        }];
//    }];
//    

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(600 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [waitingExpectation fulfill];
    });
    [self waitForExpectationsWithTimeout:61000000 handler:nil];
}

@end
