/**
 * MBLModuleMock.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 9/26/16.
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

#import "MBLModuleMock.h"
#import "MBLMockUtils.h"
#import "MBLBluetoothPeripheralMock.h"
#import "MBLBluetoothCentralMock.h"
#import "MBLMetaWearManager+Private.h"
#import "MBLLogging.h"
#import "MBLLED+Private.h"
#import "MBLTimer+Private.h"


static const uint8_t MECHANICAL_SWITCH_ID   = 0x1;
static const uint8_t LED_ID                 = 0x2;
//static const uint8_t ACCELEROMETER_ID       = 0x3;
static const uint8_t TEMPERATURE_ID         = 0x4;
static const uint8_t GPIO_ID                = 0x5;
//static const uint8_t NEOPIXEL_ID            = 0x6;
//static const uint8_t IBEACON_ID             = 0x7;
static const uint8_t HAPTIC_BUZZER_ID       = 0x8;
//static const uint8_t DATA_PROCESSOR_ID      = 0x9;
//static const uint8_t COMMAND_ID             = 0xA;
static const uint8_t LOGGING_ID             = 0xB;
static const uint8_t TIMER_ID               = 0xC;
static const uint8_t SERIAL_ID              = 0xD;
//static const uint8_t ANCS_ID                = 0xE;
//static const uint8_t MACRO_ID               = 0xF;
//static const uint8_t CONDUCTANCE_ID         = 0x10;
//static const uint8_t SETTINGS_ID            = 0x11;
static const uint8_t BAROMETER_ID           = 0x12;
//static const uint8_t GYRO_ID                = 0x13;
//static const uint8_t AMBIENT_LIGHT_ID       = 0x14;
//static const uint8_t MAGNETOMETER_ID        = 0x15;
//static const uint8_t HYGROMETER_ID          = 0x16;
//static const uint8_t PHOTOMETER_ID          = 0x17;
//static const uint8_t PROXIMITY_ID           = 0x18;
//static const uint8_t SENSOR_FUSTION_ID      = 0x19;

static const uint8_t TEST_DEBUG_ID          = 0xFE;


typedef void (^MBLMessageHandler)(message_payload_t const *msg);
typedef void (^MBLNotificationMessageHandler)(message_payload_t const *msg, BOOL isStarting);


@interface MBLGPIOMock : MBLModuleMock
@property (nonatomic) NSArray *pins;
- (instancetype)initWithPeripheral:(MBLBluetoothPeripheralMock *)peripheral;
@end


@interface MBLModuleMock ()
@property (nonatomic) MBLBluetoothPeripheralMock *peripheral;
@property (nonatomic) uint8_t modId;
@property (nonatomic) NSMutableDictionary *handlers;
 
- (void)handleRead:(uint8_t)regId handler:(MBLMessageHandler)handler;
- (void)handleWrite:(uint8_t)regId handler:(MBLMessageHandler)handler;
- (void)handleNotification:(uint8_t)regId handler:(MBLNotificationMessageHandler)handler;

@end

@implementation MBLModuleMock

- (instancetype)initWithPeripheral:(MBLBluetoothPeripheralMock *)peripheral
                 modId:(uint8_t)modId
                   modImpl:(uint8_t)modImpl
                    modRev:(uint8_t)modRev
                     extra:(NSData *)extra
{
    self = [super init];
    if (self) {
        self.peripheral = peripheral;
        self.modId = modId;
        self.handlers = [NSMutableDictionary dictionary];
        
        // Default mod info reg handling
        uint8_t header[] = { modImpl, modRev };
        NSMutableData *data = [NSMutableData dataWithBytes:header length:sizeof(header)];
        if (extra) {
            [data appendData:extra];
        }
        [self handleRead:0 handler:^(message_payload_t const *msg) {
            [peripheral messageSend:msg->mod_id regId:msg->red_id notifyen:1 data:data];
        }];
    }
    return self;
}

- (void)processMessage:(message_payload_t const *)msg
{
    MBLMessageHandler handler = self.handlers[[NSNumber numberWithUnsignedChar:msg->red_id]];
    if (handler) {
        handler(msg);
    }
}

- (void)handleRead:(uint8_t)regId handler:(MBLMessageHandler)handler
{
    self.handlers[[NSNumber numberWithUnsignedChar:regId | 0x80]] = handler;
}

- (void)handleWrite:(uint8_t)regId handler:(MBLMessageHandler)handler
{
    self.handlers[[NSNumber numberWithUnsignedChar:regId]] = handler;
}

- (void)handleNotification:(uint8_t)regId handler:(MBLNotificationMessageHandler)handler
{
    [self handleWrite:regId handler:^(message_payload_t const *msg) {
        if (msg->data[0]) {
            handler(msg, YES);
        } else {
            handler(msg, NO);
        }
    }];
}

//[self addHardcodedResponse:@"03-80-01-00" toRequest:@"03-80"];
//[self addHardcodedResponse:@"05-80-00-02-03-03-03-03-01-01-01-01" toRequest:@"05-80"];
//[self addHardcodedResponse:@"06-80-00-00" toRequest:@"06-80"];
//[self addHardcodedResponse:@"07-80-00-00" toRequest:@"07-80"];
//[self addHardcodedResponse:@"08-80-00-00" toRequest:@"08-80"];
//[self addHardcodedResponse:@"09-80-00-00-1C" toRequest:@"09-80"];
//[self addHardcodedResponse:@"0B-80-00-00-08-80-2F" toRequest:@"0B-80"];
//[self addHardcodedResponse:@"0A-80-00-00-1C" toRequest:@"0A-80"];
//[self addHardcodedResponse:@"0C-80-00-00-08" toRequest:@"0C-80"];
//[self addHardcodedResponse:@"0D-80-00-00" toRequest:@"0D-80"];
//[self addHardcodedResponse:@"0E-80-00-00-04" toRequest:@"0E-80"];
//[self addHardcodedResponse:@"0F-80-00-00" toRequest:@"0F-80"];
//[self addHardcodedResponse:@"10-80" toRequest:@"10-80"];
//[self addHardcodedResponse:@"11-80-00-00" toRequest:@"11-80"];
//[self addHardcodedResponse:@"12-80-00-00" toRequest:@"12-80"];
//[self addHardcodedResponse:@"13-80-00-00" toRequest:@"13-80"];
//[self addHardcodedResponse:@"14-80-00-00" toRequest:@"14-80"];
//[self addHardcodedResponse:@"15-80-00-00" toRequest:@"15-80"];
//[self addHardcodedResponse:@"16-80-00-00" toRequest:@"16-80"];
//[self addHardcodedResponse:@"17-80-00-00" toRequest:@"17-80"];
//[self addHardcodedResponse:@"18-80-00-00" toRequest:@"18-80"];
//[self addHardcodedResponse:@"FE-80-00-00" toRequest:@"FE-80"];

+ (instancetype)mechanicalSwitch:(MBLBluetoothPeripheralMock *)peripheral
{
    MBLModuleMock *module = [[MBLModuleMock alloc] initWithPeripheral:peripheral modId:MECHANICAL_SWITCH_ID modImpl:0 modRev:0 extra:nil];
    
    uint8_t __block switchState = 0;
    [module handleRead:1 handler:^(message_payload_t const *msg) {
        [peripheral messageSend:msg->mod_id regId:msg->red_id notifyen:1 data:[NSData dataWithBytes:&switchState length:sizeof(switchState)]];
        switchState = switchState ? 0 : 1;
    }];
    
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC, 0.01 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(timer, ^{
        [peripheral messageSend:MECHANICAL_SWITCH_ID regId:1 notifyen:1 data:[NSData dataWithBytes:&switchState length:sizeof(switchState)]];
        switchState = switchState ? 0 : 1;
    });
    [module handleNotification:1 handler:^(message_payload_t const *msg, BOOL isStarting) {
        if (isStarting) {
            dispatch_resume(timer);
        } else {
            dispatch_suspend(timer);
        }
    }];
    
    return module;
}

+ (instancetype)led:(MBLBluetoothPeripheralMock *)peripheral
{
    MBLModuleMock *module = [[MBLModuleMock alloc] initWithPeripheral:peripheral modId:LED_ID modImpl:0 modRev:0 extra:nil];
    
    NSNumber __block *timeToTurnOff = nil;
    [module handleWrite:1 handler:^(message_payload_t const *msg) {
        NSLog(@"LED ON");
        if (timeToTurnOff) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeToTurnOff.doubleValue * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                NSLog(@"LED OFF");
            });
        }
    }];
    [module handleWrite:2 handler:^(message_payload_t const *msg) {
        NSLog(@"LED OFF");
    }];
    [module handleWrite:3 handler:^(message_payload_t const *msg) {
        mw_led_flash_params_t *params = (mw_led_flash_params_t *)msg->data;
        if (params->repeat_count != 0xFF) {
            timeToTurnOff = [NSNumber numberWithDouble:(double)(params->repeat_count * params->time_period) / 1000.0];
        }
    }];
    
    return module;
}

+ (instancetype)temperature:(MBLBluetoothPeripheralMock *)peripheral
{
    uint8_t extra[] = { 0x00, 0x03, 0x01, 0x02 };
    MBLModuleMock *module = [[MBLModuleMock alloc] initWithPeripheral:peripheral
                                                                modId:TEMPERATURE_ID
                                                              modImpl:1
                                                               modRev:0
                                                                extra:[NSData dataWithBytes:&extra length:sizeof(extra)]];

    [module handleRead:1 handler:^(const message_payload_t *msg) {
        const int16_t temp = 208;
        uint8_t data[] = { msg->data[0], temp & 0xFF, temp >> 8 };
        [peripheral messageSend:msg->mod_id regId:msg->red_id notifyen:1 data:[NSData dataWithBytes:&data length:sizeof(data)]];
    }];
    return module;
}

+ (instancetype)serial:(MBLBluetoothPeripheralMock *)peripheral
{
    MBLModuleMock *module = [[MBLModuleMock alloc] initWithPeripheral:peripheral modId:SERIAL_ID modImpl:0 modRev:1 extra:nil];

    NSMutableDictionary *i2cData = [NSMutableDictionary dictionary];
    [module handleWrite:1 handler:^(message_payload_t const *msg) {
        NSNumber *key = [NSNumber numberWithInt:*((uint16_t *)&msg->data[0])];
        NSData *value = [NSData dataWithBytes:&msg->data[4] length:msg->data[3]];
        i2cData[key] = value;
    }];
    [module handleRead:1 handler:^(message_payload_t const *msg) {
        NSData *result = i2cData[[NSNumber numberWithInt:*((uint16_t *)&msg->data[0])]];
        if (!result) {
            uint8_t data[17] = { 0 };
            result = [NSData dataWithBytes:&data length:msg->data[3]];
        }
        NSMutableData *data = [NSMutableData dataWithBytes:&msg->data[2] length:1];
        [data appendData:result];
        [peripheral messageSend:msg->mod_id regId:msg->red_id notifyen:1 data:data];
    }];    
    
    return module;
}

+ (instancetype)gpio:(MBLBluetoothPeripheralMock *)peripheral
{
    return [[MBLGPIOMock alloc] initWithPeripheral:peripheral];
}

+ (instancetype)hapticBuzzer:(MBLBluetoothPeripheralMock *)peripheral
{
    MBLModuleMock *module = [[MBLModuleMock alloc] initWithPeripheral:peripheral modId:HAPTIC_BUZZER_ID modImpl:0 modRev:0 extra:nil];
    [module handleWrite:1 handler:^(message_payload_t const *msg) {
        BOOL isBuzzer = msg->data[3] == 1;
        uint16_t pwidth = *((uint16_t *)&msg->data[1]);
        uint8_t dcycle = msg->data[0];
        if (isBuzzer) {
            if (peripheral.buzzerHandler) {
                peripheral.buzzerHandler(dcycle, pwidth);
            }
        } else {
            if (peripheral.hapticHandler) {
                peripheral.hapticHandler(dcycle, pwidth);
            }
        }
    }];
    return module;
}

+ (instancetype)logging:(MBLBluetoothPeripheralMock *)peripheral
{
    mw_log_module_info extra = { 0 };
    extra.logTriggers = 8;
    extra.logCap = 10000;
    MBLModuleMock *module = [[MBLModuleMock alloc] initWithPeripheral:peripheral
                                                                modId:LOGGING_ID
                                                              modImpl:0
                                                               modRev:2
                                                                extra:[NSData dataWithBytes:&extra length:sizeof(extra)]];
    
    [module handleRead:4 handler:^(message_payload_t const *msg) {
        uint64_t resp = 0;
        [peripheral messageSend:msg->mod_id regId:msg->red_id notifyen:1 data:[NSData dataWithBytes:&resp length:5]];
    }];
    return module;
}

+ (instancetype)timer:(MBLBluetoothPeripheralMock *)peripheral
{
    uint8_t extra[] = { 0x08 };
    NSMutableArray *timers = [NSMutableArray array];
    MBLModuleMock *module = [[MBLModuleMock alloc] initWithPeripheral:peripheral
                                                                modId:TIMER_ID
                                                              modImpl:0
                                                               modRev:0
                                                                extra:[NSData dataWithBytes:&extra length:sizeof(extra)]];
    
    [module handleWrite:2 handler:^(const message_payload_t *msg) {
        mw_timer_param_t *timer = (mw_timer_param_t *)msg->data;
        [timers addObject:[NSValue valueWithBytes:timer objCType:@encode(mw_timer_param_t)]];
    }];
    [module handleRead:2 handler:^(message_payload_t const *msg) {
        mw_timer_param_t timer;
        NSValue *value = timers[msg->data[0]];
        [value getValue:&timer];
        [peripheral messageSend:msg->mod_id regId:msg->red_id notifyen:1 data:[NSData dataWithBytes:&timer length:sizeof(mw_timer_param_t)]];
    }];
    return module;
}

+ (instancetype)barometer:(MBLBluetoothPeripheralMock *)peripheral
{
    MBLModuleMock *module = [[MBLModuleMock alloc] initWithPeripheral:peripheral modId:BAROMETER_ID modImpl:0 modRev:0 extra:nil];
    
    BOOL __block pressureState = 0;
    [module handleRead:1 handler:^(message_payload_t const *msg) {
        uint32_t resp = pressureState ? 0xFFFC1800 : 0x0003E800;
        pressureState = pressureState ? 0 : 1;
        [peripheral messageSend:msg->mod_id regId:msg->red_id notifyen:1 data:[NSData dataWithBytes:&resp length:sizeof(resp)]];
    }];
    
    BOOL __block altitudeState = 0;
    [module handleRead:2 handler:^(message_payload_t const *msg) {
        uint32_t resp = altitudeState ? 0xFFFC1800 : 0x0003E800;
        altitudeState = altitudeState ? 0 : 1;
        [peripheral messageSend:msg->mod_id regId:msg->red_id notifyen:1 data:[NSData dataWithBytes:&resp length:sizeof(resp)]];
    }];
    
    return module;
}

+ (instancetype)testDebug:(MBLBluetoothPeripheralMock *)peripheral
{
    MBLModuleMock *module = [[MBLModuleMock alloc] initWithPeripheral:peripheral modId:TEST_DEBUG_ID modImpl:0 modRev:1 extra:nil];
    [module handleRead:4 handler:^(message_payload_t const *msg) {
        uint32_t keyValue = peripheral.keyRegister;
        [peripheral messageSend:msg->mod_id regId:msg->red_id notifyen:1 data:[NSData dataWithBytes:&keyValue length:sizeof(keyValue)]];
    }];
    
    [module handleWrite:6 handler:^(message_payload_t const *msg) {
        [((MBLBluetoothCentralMock *)[MBLMetaWearManager sharedManager].centralManager) cancelPeripheralConnection:peripheral];
    }];
    [module handleWrite:2 handler:^(message_payload_t const *msg) {
        peripheral.isMetaBoot = YES;
        [((MBLBluetoothCentralMock *)[MBLMetaWearManager sharedManager].centralManager) cancelPeripheralConnection:peripheral];
    }];
    return module;
}


@end


@interface MBLPinMock : NSObject
@property (nonatomic) uint16_t  analogRef;
@property (nonatomic) uint16_t  analogAbs;
@property (nonatomic) uint8_t   digital;

- (void)setHigh;
- (void)setLow;
@end

@implementation MBLPinMock
- (instancetype)init
{
    self = [super init];
    [self setDouble];
    return self;
}
- (void)setHigh
{
    self.digital = 1;
    self.analogAbs = 3000;
    self.analogRef = 1020;
}
- (void)setLow
{
    self.digital = 0;
    self.analogAbs = 10;
    self.analogRef = 2;
}
- (void)setDouble
{
    self.digital = 0;
    self.analogAbs = 600;
    self.analogRef = 181;
}
@end


@implementation MBLGPIOMock
- (instancetype)initWithPeripheral:(MBLBluetoothPeripheralMock *)peripheral
{
    uint8_t extra[] = { 03, 03, 03, 03, 01, 01, 01, 01 };
    self = [super initWithPeripheral:peripheral
                               modId:GPIO_ID
                             modImpl:0
                              modRev:2
                               extra:[NSData dataWithBytes:&extra length:sizeof(extra)]];
    if (self) {
        self.pins = @[[[MBLPinMock alloc] init],[[MBLPinMock alloc] init],[[MBLPinMock alloc] init],[[MBLPinMock alloc] init],
                      [[MBLPinMock alloc] init],[[MBLPinMock alloc] init],[[MBLPinMock alloc] init],[[MBLPinMock alloc] init]];
    }
    return self;
}
- (void)processMessage:(message_payload_t const *)msg
{
    uint8_t pinIdx = msg->data[0];
    uint8_t indexSpoof = msg->data[4];
    MBLPinMock *pin = self.pins[pinIdx];
    
    if (indexSpoof != 0xFF) {
        pinIdx = indexSpoof;
    }
    
    if (msg->red_id == 0x1) {
        [pin setHigh];
    } else if (msg->red_id == 0x2) {
        [pin setLow];
    } else if (msg->red_id == 0x3) {
        [pin setHigh];
    } else if (msg->red_id == 0x4) {
        [pin setLow];
    } else if (msg->red_id == 0x5) {
        [pin setDouble];
    } else if (msg->red_id == 0x86) {
        uint8_t data[] = { pinIdx, pin.analogAbs & 0xFF, pin.analogAbs >> 8 };
        [self.peripheral messageSend:msg->mod_id regId:msg->red_id notifyen:1 data:[NSData dataWithBytes:&data length:sizeof(data)]];
    } else if (msg->red_id == 0x87) {
        uint8_t data[] = { pinIdx, pin.analogRef & 0xFF, pin.analogRef >> 8 };
        [self.peripheral messageSend:msg->mod_id regId:msg->red_id notifyen:1 data:[NSData dataWithBytes:&data length:sizeof(data)]];
    } else if (msg->red_id == 0x88) {
        uint8_t data[] = { pinIdx, pin.digital };
        [self.peripheral messageSend:msg->mod_id regId:msg->red_id notifyen:1 data:[NSData dataWithBytes:&data length:sizeof(data)]];
    } else if (msg->red_id == 0x80) {
        [super processMessage:msg];
    }
}
@end
