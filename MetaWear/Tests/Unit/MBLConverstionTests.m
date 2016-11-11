/**
 * MBLConverstionTests.m
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

#import <XCTest/XCTest.h>
#import "MetaWearSyntaxFriendly.h"

@interface MBLConverstionTests : XCTestCase

@end

@implementation MBLConverstionTests

typedef struct __attribute__((packed)) {
    uint8_t         random;
    uint8_t         int32[4];
    uint8_t         int16[2];
    uint8_t         uint32[4];
    uint8_t         uint16[2];
} conversion_test_struct;

- (void)testInt32Conversion
{
    conversion_test_struct params = {0};
    // Test a successful positive
    XCTAssertTrue([MBLConversion number:@10 toInt32:(int32_t *)params.int32]);
    XCTAssertEqual(*(int32_t *)params.int32, 10);
    
    // Test a successful negative
    XCTAssertTrue([MBLConversion number:@(-10) toInt32:(int32_t *)params.int32]);
    XCTAssertEqual(*(int32_t *)params.int32, -10);
    
    // Test failure
    XCTAssertFalse([MBLConversion number:@(INT64_MAX) toInt32:(int32_t *)params.int32]);
}

- (void)testUint16Conversion
{
    conversion_test_struct params = {0};
    // Test a successful
    XCTAssertTrue([MBLConversion number:@10 toUint16:(uint16_t *)params.uint16]);
    XCTAssertEqual(*(uint16_t *)params.uint16, 10);
    
    // Test failure
    XCTAssertFalse([MBLConversion number:@(-10) toUint16:(uint16_t *)params.uint16]);
}

- (void)testNumericFormaterError
{
    XCTAssertThrows([[MBLNumericFormatter alloc] initDoubleWithLength:9 isSigned:NO scale:2.0 offset:1]);
    XCTAssertThrows([[MBLNumericFormatter alloc] initIntWithLength:9 isSigned:NO offset:0]);
}

- (void)testNumericFormaterSigned
{
    MBLNumericFormatter *format = [[MBLNumericFormatter alloc] initIntWithLength:3 isSigned:YES];
    MBLNumericData *data = [format entryFromData:[MBLMockUtils dataFromString:@"FF-FF-FF"] date:[NSDate date]];
    XCTAssertEqual(-1, data.value.intValue);
}

- (void)testBoschOrientationFormat
{
    MBLAccelerometerBoschOrientationFormat *format = [[MBLAccelerometerBoschOrientationFormat alloc] init];
    XCTAssertEqual([format numberFromDouble:MBLAccelerometerOrientationPortraitUpsideDown].intValue, 0x7);
    XCTAssertEqual([format numberFromDouble:MBLAccelerometerOrientationPortrait].intValue, 0x5);
    XCTAssertEqual([format numberFromDouble:MBLAccelerometerOrientationLandscapeLeft].intValue, 0x3);
    XCTAssertEqual([format numberFromDouble:MBLAccelerometerOrientationLandscapeRight].intValue, 0x1);
}

- (void)testCSVRepresentation
{
    uint8_t a = 0x5A;
    NSData *b = [NSData dataWithBytes:&a length:1];
    NSString *c = [[[MBLDataSample alloc] initWithTimestamp:[NSDate dateWithTimeIntervalSince1970:1234.5678] data:b] csvRepresentation];
    NSLog(@"%@", c);
    XCTAssertTrue([c isEqualToString:@"1234.567800,5A\n"]);
    
    
    uint32_t e = 0x12345678;
    NSData *f = [NSData dataWithBytes:&e length:3];
    NSString *g = [[[MBLDataSample alloc] initWithTimestamp:[NSDate dateWithTimeIntervalSince1970:1234.5678] data:f] csvRepresentation];
    NSLog(@"%@", g);
    XCTAssertTrue([g isEqualToString:@"1234.567800,78-56-34\n"]);
}

- (void)testCSVNumericRepresentation
{
    NSString *a = [[[MBLNumericData alloc] initWithNumber:@123.4 timestamp:[NSDate dateWithTimeIntervalSince1970:1234.5678]] csvRepresentation];
    NSLog(@"%@", a);
    XCTAssertTrue([a isEqualToString:@"1234.567800,123.4\n"]);
}

@end
