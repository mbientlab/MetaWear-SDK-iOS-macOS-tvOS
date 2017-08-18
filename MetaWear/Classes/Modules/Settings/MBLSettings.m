/**
 * MBLSettings.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 1/19/15.
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

#import "MBLSettings+Private.h"
#import "MBLModule+Private.h"
#import "MBLMetaWear+Private.h"
#import "MBLMacAddressFormat.h"
#import "MBLNumericFormatter.h"
#import "MBLNumericData+Private.h"

typedef struct __attribute__((packed)) {
    uint16_t    min_conn_interval;
    uint16_t    max_conn_interval;
    uint16_t    slave_latency;
    uint16_t    conn_sup_timeout;
} ble_gap_conn_params_t;

typedef struct __attribute__((packed)) {
    uint8_t     power_status_supported:1;
    uint8_t     charger_status_supported:1;
} mw_settings_feature_bitmask_t;

@interface MBLSettings ()
@property (nonatomic) MBLRegister *deviceName;
@property (nonatomic) MBLRegister *advertisingIntervalRegister;
@property (nonatomic) MBLRegister *txPower;
@property (nonatomic) MBLRegister *bondsDelete;
@property (nonatomic) MBLRegister *startAdvertising;
@property (nonatomic) MBLRegister *initiateBonding;
@property (nonatomic) MBLRegister *scanResponsePacket;
@property (nonatomic) MBLRegister *scanResponsePacketPartial;
@property (nonatomic) MBLRegister *connectionParameters;
@property (nonatomic) MBLEvent *disconnectEvent;
@property (nonatomic) MBLData *macAddress;
@property (nonatomic) MBLData *batteryRemaining;
@property (nonatomic) MBLData *batteryVoltage;
@property (nonatomic) MBLRegister *watchdogEnable;
@property (nonatomic) MBLRegister *watchdogConfig;
@property (nonatomic) MBLRegister *watchdogAutoRefresh;
@property (nonatomic) MBLRegister *watchdogUserRefresh;
@property (nonatomic) MBLEvent *powerStatus;
@property (nonatomic) MBLEvent *chargerStatus;


// Setting the following properties causes side effects, so we
// create an internal property for storing the actual value, allowing
// us to safely get/set during serialization of this class
@property (nonatomic) double advertisingIntervalImpl;
@property (nonatomic) uint8_t advertisingTimeoutImpl;
@property (nonatomic) MBLTransmitPower transmitPowerImpl;
@property (nonatomic) NSData *scanResponseImpl;
@property (nonatomic) BOOL circularBufferLogImpl;
@end

@implementation MBLSettings

- (instancetype)initWithDevice:(MBLMetaWear *)device moduleInfo:(MBLModuleInfo *)moduleInfo
{
    self = [super initWithDevice:device moduleInfo:moduleInfo];
    if (self) {
        mw_settings_feature_bitmask_t features = { 0 };
        if (moduleInfo.moduleData.length > 0) {
            features = *(mw_settings_feature_bitmask_t *)moduleInfo.moduleData.bytes;
        }
        self.advertisingIntervalImpl = 417.5;
        self.advertisingTimeoutImpl = 0;
        self.transmitPowerImpl = MBLTransmitPower0dBm;
        self.scanResponseImpl = nil;
        self.circularBufferLogImpl = NO;
        
        self.minimumConnectionInterval = 7.5 / 1.25;
        self.maximumConnectionInterval = 1000 / 1.25;
        self.slaveLatency = 0;
        self.supervisoryTimeout = 6000 / 10;
        
        self.deviceName = [[MBLRegister alloc] initWithModule:self registerId:0x1 format:[[MBLFormat alloc] initEncodedDataWithLength:8]];
        self.advertisingIntervalRegister = [[MBLRegister alloc] initWithModule:self registerId:0x2 format:[[MBLFormat alloc] initEncodedDataWithLength:moduleInfo.moduleRevision >= 6 ? 4 : 3]];
        self.txPower = [[MBLRegister alloc] initWithModule:self registerId:0x3 format:[[MBLFormat alloc] initEncodedDataWithLength:1]];
        self.bondsDelete = [[MBLRegister alloc] initWithModule:self registerId:0x4 format:[[MBLFormat alloc] initEncodedDataWithLength:1]];
        self.startAdvertising = [[MBLRegister alloc] initWithModule:self registerId:0x5 format:[[MBLFormat alloc] initEncodedDataWithLength:0]];
        self.initiateBonding = [[MBLRegister alloc] initWithModule:self registerId:0x6 format:[[MBLFormat alloc] initEncodedDataWithLength:0]];
        self.scanResponsePacket = [[MBLRegister alloc] initWithModule:self registerId:0x7 format:[[MBLFormat alloc] initEncodedDataWithLength:18]];
        self.scanResponsePacketPartial = [[MBLRegister alloc] initWithModule:self registerId:0x8 format:[[MBLFormat alloc] initEncodedDataWithLength:13]];
        if (moduleInfo.moduleRevision >= 1) {
            self.connectionParameters = [[MBLRegister alloc] initWithModule:self registerId:0x9 format:[[MBLFormat alloc] initEncodedDataWithLength:8]];
        }
        if (moduleInfo.moduleRevision >= 2) {
            self.disconnectEvent = [[MBLEvent alloc] initWithModule:self registerId:0xA format:[[MBLFormat alloc] initEncodedDataWithLength:0]];
            self.macAddress = [[MBLData alloc] initWithModule:self registerId:0xB format:[[MBLMacAddressFormat alloc] initWithAddressType:moduleInfo.moduleRevision >= 6]];
        }
        if (moduleInfo.moduleRevision >= 3) {
            self.batteryRemaining = [[MBLData alloc] initWithModule:self registerId:0xC format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
            self.batteryVoltage = [[MBLData alloc] initWithModule:self registerId:0xC format:[[MBLNumericFormatter alloc] initIntWithLength:2 isSigned:NO offset:1]];
        }
        if (moduleInfo.moduleRevision >= 4) {
            self.watchdogEnable = [[MBLRegister alloc] initWithModule:self registerId:0xD format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
            self.watchdogConfig = [[MBLRegister alloc] initWithModule:self registerId:0xE format:[[MBLFormat alloc] initEncodedDataWithLength:5]];
            self.watchdogAutoRefresh = [[MBLRegister alloc] initWithModule:self registerId:0xF format:[[MBLFormat alloc] initEncodedDataWithLength:1]];
            self.watchdogUserRefresh = [[MBLRegister alloc] initWithModule:self registerId:0x10 format:[MBLFormat writeOnly]];
        }
        if (moduleInfo.moduleRevision >= 5) {
            if (features.power_status_supported) {
                self.powerStatus = [[MBLEvent alloc] initWithModule:self registerId:0x11 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
            }
            if (features.charger_status_supported) {
                self.chargerStatus = [[MBLEvent alloc] initWithModule:self registerId:0x12 format:[[MBLNumericFormatter alloc] initIntWithLength:1 isSigned:NO]];
            }
        }
        if (moduleInfo.moduleRevision >= 6) {
            // TODO: We can't do whitelist with iOS devices unless we pair
            // enable this when the time comes
        }
    }
    return self;
}

- (double)advertisingInterval
{
    return self.advertisingIntervalImpl;
}

- (void)setAdvertisingInterval:(double)advertisingInterval
{
    self.advertisingIntervalImpl = advertisingInterval;
    [self updateAdvertisingIntervalRegister];
}

- (uint8_t)advertisingTimeout
{
    return self.advertisingTimeoutImpl;
}

- (void)setAdvertisingTimeout:(uint8_t)advertisingTimeout
{
    self.advertisingTimeoutImpl = advertisingTimeout;
    [self updateAdvertisingIntervalRegister];
}

typedef struct __attribute__((packed)) {
    uint16_t    interval;
    uint8_t     timeout;
} advertising_interval_param_t;

typedef struct __attribute__((packed)) {
    uint16_t    interval;
    uint8_t     timeout;
    uint8_t     advertisement_type;
} advertising_interval_param_v2_t;

- (void)updateAdvertisingIntervalRegister
{
    uint16_t intValue = self.advertisingIntervalImpl;
    if (self.moduleInfo.moduleRevision >= 1) {
        intValue = roundf(self.advertisingIntervalImpl / 0.625);
    }
    NSData *data;
    if (self.moduleInfo.moduleRevision >= 6) {
        advertising_interval_param_v2_t params = {0};
        params.interval = intValue;
        params.timeout = self.advertisingTimeoutImpl;
        params.advertisement_type = 0;
        data = [NSData dataWithBytes:&params length:sizeof(advertising_interval_param_v2_t)];
    } else {
        advertising_interval_param_t params = {0};
        params.interval = intValue;
        params.timeout = self.advertisingTimeoutImpl;
        data = [NSData dataWithBytes:&params length:sizeof(advertising_interval_param_t)];
    }
    [self.advertisingIntervalRegister writeDataAsync:data];
}

- (MBLTransmitPower)transmitPower
{
    return self.transmitPowerImpl;
}

- (void)setTransmitPower:(MBLTransmitPower)transmitPower
{
    self.transmitPowerImpl = transmitPower;
    int8_t intPower;
    switch (transmitPower) {
        case MBLTransmitPower4dBm:
            intPower = 4;
            break;
        case MBLTransmitPower0dBm:
            intPower = 0;
            break;
        case MBLTransmitPowerMinus4dBm:
            intPower = -4;
            break;
        case MBLTransmitPowerMinus8dBm:
            intPower = -8;
            break;
        case MBLTransmitPowerMinus12dBm:
            intPower = -12;
            break;
        case MBLTransmitPowerMinus16dBm:
            intPower = -16;
            break;
        case MBLTransmitPowerMinus20dBm:
            intPower = -20;
            break;
        case MBLTransmitPowerMinus30dBm:
            intPower = -30;
            break;
    }
    [self.txPower writeDataAsync:[NSData dataWithBytes:&intPower length:1]];
}

- (NSData *)scanResponse
{
    return self.scanResponseImpl;
}

- (void)setScanResponse:(NSData *)scanResponse
{
    if (scanResponse.length > 31) {
        [NSException raise:@"Invalid scanResponse data"
                    format:@"length of %lu is invalid, valid range is [0, 31]", (unsigned long)scanResponse.length];
    }
    if (scanResponse.length > 18) {
        [self.scanResponsePacketPartial writeDataAsync:[scanResponse subdataWithRange:NSMakeRange(0, 13)]];
        [self.scanResponsePacket writeDataAsync:[scanResponse subdataWithRange:NSMakeRange(13, scanResponse.length - 13)]];
    } else {
        [self.scanResponsePacket writeDataAsync:scanResponse];
    }
    self.scanResponseImpl = scanResponse;
}

- (BOOL)circularBufferLog
{
    return self.circularBufferLogImpl;
}

- (void)setCircularBufferLog:(BOOL)circularBufferLog
{
    self.circularBufferLogImpl = circularBufferLog;
    [self.device.logging.circularBufferMode writeByteAsync:circularBufferLog];
}

- (BFTask *)initiatePairingAsync
{
    return [self.initiateBonding writeDataAsync:nil];
}

- (BFTask *)deleteAllBondsAsync
{
    return [self.bondsDelete writeByteAsync:1];
}

- (BFTask *)startAdvertisementAsync
{
    return [self.startAdvertising writeDataAsync:nil];
}

- (BFTask *)applyConnectionParametersAsync
{
    /*
     #define MIN_CONN_INTERVAL                    MSEC_TO_UNITS(7.5, UNIT_1_25_MS)          //Minimum acceptable connection interval (0.5 seconds).
     #define MAX_CONN_INTERVAL                    MSEC_TO_UNITS(1000, UNIT_1_25_MS)         //Maximum acceptable connection interval (1 second).
     #define SLAVE_LATENCY                        0                                         //Slave latency.
     #define CONN_SUP_TIMEOUT                     MSEC_TO_UNITS(6000, UNIT_10_MS)           //Connection supervisory timeout (4 seconds).
     
     Interval Max * (Slave Latency + 1) ≤ 2 seconds
     Interval Min ≥ 20 ms
     Interval Min + 20 ms ≤ Interval Max Slave Latency ≤ 4
     connSupervisionTimeout ≤ 6 seconds
     Interval Max * (Slave Latency + 1) * 3 < connSupervisionTimeout
     
     1 * (0 + 1) < 2 pass
     7.5ms > 20 fail
     7.5 + 20 < 1 * (0 + 1) < 4 pass
     */
    
    ble_gap_conn_params_t params = { 0 };
    params.min_conn_interval = self.minimumConnectionInterval;
    params.max_conn_interval = self.maximumConnectionInterval;
    params.slave_latency = self.slaveLatency;
    params.conn_sup_timeout = self.supervisoryTimeout;
    
    return [self.connectionParameters writeDataAsync:[NSData dataWithBytes:&params length:sizeof(ble_gap_conn_params_t)]];
}

- (BFTask *)startWatchdog:(double)seconds runWhileSleeping:(BOOL)runWhileSleeping
{
    uint32_t ticks = (seconds * 32768.0) - 1;
    NSMutableData *data = [NSMutableData dataWithBytes:&ticks length:sizeof(ticks)];
    uint8_t tmp = runWhileSleeping ? 1 : 0;
    [data appendBytes:&tmp length:sizeof(tmp)];
    
    return [[[self.watchdogConfig writeDataAsync:data] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [self refreshOnScheduler:NO enteringSleep:YES];
    }] continueOnMetaWearWithSuccessBlock:^id _Nullable(BFTask * _Nonnull task) {
        return [self.watchdogEnable writeByteAsync:1];
    }];
}

- (BFTask *)refreshOnScheduler:(BOOL)scheduler enteringSleep:(BOOL)enteringSleep
{
    uint8_t data = 0;
    data |= scheduler ? (1 << 0) : 0;
    data |= enteringSleep ? (1 << 1) : 0;
    return [self.watchdogAutoRefresh writeByteAsync:data];
}

@end
