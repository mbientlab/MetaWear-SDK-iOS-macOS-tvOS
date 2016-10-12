/**
 * MBLMovingAverage.m
 * MetaWear
 *
 * Created by Stephen Schiffli on 2/24/16.
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
//
// Created by Alex Manarpies on 12/17/14.
//

#import "MBLMovingAverage.h"


@interface MBLMovingAverage ()

@property(nonatomic, strong) NSMutableArray *queue;
@property(nonatomic) NSUInteger period;
@property(nonatomic) NSUInteger count;

@property(nonatomic, readwrite) double movingAverage;
@property(nonatomic, readwrite) double cumulativeAverage;

@end

@implementation MBLMovingAverage

- (instancetype)initWithPeriod:(NSUInteger)period {
    self = [self init];
    if (self) {
        _period = period;
        _queue = [[NSMutableArray alloc] initWithCapacity:period];
    }
    return self;
}

- (void)addDatum:(NSNumber *)datum {
    [self.queue insertObject:datum atIndex:0];

    //double removed = 0;
    double datumd = [datum doubleValue];

    if (self.queue.count > self.period) {
        //removed = [[self.queue lastObject] doubleValue];
        [self.queue removeLastObject];
    }

    //self.movingAverage = self.movingAverage - (removed / self.period) + (datumd / self.period);
    self.movingAverage = [[self.queue valueForKeyPath:@"@avg.self"] doubleValue];
    self.cumulativeAverage = self.cumulativeAverage + (datumd - self.cumulativeAverage) / ++self.count;
}

@end