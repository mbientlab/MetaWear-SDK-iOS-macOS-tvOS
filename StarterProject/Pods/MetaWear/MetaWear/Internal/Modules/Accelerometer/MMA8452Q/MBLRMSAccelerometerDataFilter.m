/**
 * MBLRMSAccelerometerDataFilter.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 10/21/14.
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

#import "MBLRMSAccelerometerDataFilter.h"
#import "MBLAccelerometerMMA8452Q+Private.h"
#import "MBLAccelerometerBosch+Private.h"
#import "MBLRMSAccelerometerData+Private.h"
#import "MBLDataSample+Private.h"
#import "MBLModule+Private.h"
#import "MBLFilter+Private.h"
#import "MBLAccelerometerMMA8452QRMSFormat.h"
#import "MBLAccelerometerBoschRMSFormat.h"

typedef struct __attribute__((packed)) {
    uint8_t      filter_id;
    uint8_t      outputlen:2;
    uint8_t      inputlen:2;
    uint8_t      inputcount:3;
    uint8_t      issigned:1;
    uint8_t      mode:3;
} df_rms_param_t;


static const int RMS_MODE_RMS = 0;
//static const int RMS_MODE_RSS = 1;

@implementation MBLRMSAccelerometerDataFilter

- (instancetype)initWithAccelerometer:(MBLAccelerometerMMA8452Q *)accelerometer
{
    df_rms_param_t params = {0};
    params.filter_id = 7;
    params.outputlen = 4 - 1;
    params.inputlen = 2 - 1;
    params.inputcount = 3 - 1;
    params.issigned = YES;
    params.mode = RMS_MODE_RMS;
    
    self = [super initWithTrigger:accelerometer.dataReadyEvent
                 filterParameters:[NSData dataWithBytes:&params length:sizeof(df_rms_param_t)]
                           format:[[MBLAccelerometerMMA8452QRMSFormat alloc] initWithAccelerometer:accelerometer]];
    return self;
}

- (instancetype)initWithAccelerometerBosch:(MBLAccelerometerBosch *)accelerometer
{
    df_rms_param_t params = {0};
    params.filter_id = 7;
    params.outputlen = 4 - 1;
    params.inputlen = 2 - 1;
    params.inputcount = 3 - 1;
    params.issigned = YES;
    params.mode = RMS_MODE_RMS;

    self = [super initWithTrigger:accelerometer.dataReadyEvent
                 filterParameters:[NSData dataWithBytes:&params length:sizeof(df_rms_param_t)]
                           format:[[MBLAccelerometerBoschRMSFormat alloc] initWithAccelerometer:accelerometer]];
    return self;
}

@end
