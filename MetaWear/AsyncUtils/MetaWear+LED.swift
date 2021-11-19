/**
 * MetaWear+LED.swift
 * MetaWear
 *
 * Created by Stephen Schiffli on 5/3/18.
 * Copyright 2018 MbientLab Inc. All rights reserved.
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

import MetaWearCpp

#if os(macOS)
import AppKit
public typealias MBLColor = NSColor
#else
import UIKit
public typealias MBLColor = UIColor
#endif

extension MetaWear {
    /// Simplify common LED operations with a straightforward interface
    /// Use mbl_mw_led_write_pattern for precise control
    public func flashLED(color: MBLColor, intensity: CGFloat, _repeat: UInt8 = 0xFF, onTime: UInt16 = 200, period: UInt16 = 800) {
        assert(intensity >= 0.0 && intensity <= 1.0, "intensity valid range is [0, 1.0]")
        guard mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_LED) != MBL_MW_MODULE_TYPE_NA else {
            return
        }
        let scaledIntensity = intensity * 31.0
        let rtime = onTime / 2
        let ftime = onTime / 2
        let offset: UInt16 = 0
        
        var red: CGFloat = 0
        var blue: CGFloat = 0
        var green: CGFloat = 0
        color.getRed(&red, green: &green, blue: &blue, alpha: nil)
        let scaledRed = UInt8(round(red * scaledIntensity))
        let scaledBlue = UInt8(round(blue * scaledIntensity))
        let scaledGreen = UInt8(round(green * scaledIntensity))
        
        var pattern = MblMwLedPattern(high_intensity: 31,
                                      low_intensity: 0,
                                      rise_time_ms: rtime,
                                      high_time_ms: onTime,
                                      fall_time_ms: ftime,
                                      pulse_duration_ms: period,
                                      delay_time_ms: offset,
                                      repeat_count: _repeat)
        mbl_mw_led_stop_and_clear(board)
        if (scaledRed > 0) {
            pattern.high_intensity = scaledRed
            mbl_mw_led_write_pattern(board, &pattern, MBL_MW_LED_COLOR_RED)
        }
        if (scaledGreen > 0) {
            pattern.high_intensity = scaledGreen
            mbl_mw_led_write_pattern(board, &pattern, MBL_MW_LED_COLOR_GREEN)
        }
        if (scaledBlue > 0) {
            pattern.high_intensity = scaledBlue
            mbl_mw_led_write_pattern(board, &pattern, MBL_MW_LED_COLOR_BLUE)
        }
        mbl_mw_led_play(board)
    }

    /// Wrapper around mbl_mw_led_stop_and_clear
    public func turnOffLed() {
        guard mbl_mw_metawearboard_lookup_module(board, MBL_MW_MODULE_LED) != MBL_MW_MODULE_TYPE_NA else {
            return
        }
        mbl_mw_led_stop_and_clear(board)
    }
}
