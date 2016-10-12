/**
 * MBLBarometerBMP280.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 7/28/15.
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

#import "MBLBarometerBMP280.h"
#import "MBLBarometerBosch+Private.h"
#import "MBLRegister+Private.h"

typedef struct __attribute__((packed)) {
    uint8_t                         mode:2;
    MBLBarometerBoschOversample    osrs_p:3;
    MBLBarometerBoschOversample    osrs_t:3;
    uint8_t                         spi3w_en:1;
    uint8_t                         :1;
    MBLBarometerBoschFilter        filter:3;
    MBLBarometerBMP280Standby       t_sb:3;
} bmp280_ctrl_regs_t;


@implementation MBLBarometerBMP280

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        self.standbyTime = MBLBarometerBMP280Standby500;
    }
    return self;
}

- (BFTask *)performAsyncInitialization
{
    bmp280_ctrl_regs_t params = { 0 };
    params.osrs_p = self.pressureOversampling;
    // If pressure at x16 then temp should be x2 otherwise x1 is fine
    // http://ae-bst.resource.bosch.com/media/products/dokumente/bmp280/BST-BMP280-DS001-10.pdf
    if (self.pressureOversampling == MBLBarometerBoschOversampleUltraHighResolution) {
        params.osrs_t = MBLBarometerBoschOversampleLowPower;
    } else {
        params.osrs_t = MBLBarometerBoschOversampleUltraLowPower;
    }
    params.filter = self.hardwareAverageFilter;
    params.t_sb = self.standbyTime;
    return [self.mode writeDataAsync:[NSData dataWithBytes:&params length:sizeof(params)]];
}

@end
