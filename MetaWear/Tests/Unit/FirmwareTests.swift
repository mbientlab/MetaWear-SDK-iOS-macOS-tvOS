/**
 * FirmwareTests.swift
 * MetaWear-Tests
 *
 * Created by Stephen Schiffli on 1/9/18.
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

import XCTest
import BoltsSwift
@testable import MetaWear
@testable import MetaWearCpp

class FirmwareTests: XCTestCase {
    func testFirmwareUpdateManager() {
        let myExpectation = XCTestExpectation(description: "getting info1")
        
        FirmwareServer.getAllFirmwareAsync(hardwareRev: "0.1", modelNumber: "0").continueOnSuccessWithTask { result -> Task<FirmwareBuild> in
            XCTAssertEqual(result[0].firmwareURL.absoluteString,
                           "https://mbientlab.com/releases/metawear/0.1/0/vanilla/1.0.4/firmware.bin")
            XCTAssertEqual(result[1].firmwareURL.absoluteString,
                           "https://mbientlab.com/releases/metawear/0.1/0/vanilla/1.1.0/firmware.bin")
            XCTAssertEqual(result[2].firmwareURL.absoluteString,
                           "https://mbientlab.com/releases/metawear/0.1/0/vanilla/1.1.1/firmware.bin")
            XCTAssertEqual(result[3].firmwareURL.absoluteString,
                           "https://mbientlab.com/releases/metawear/0.1/0/vanilla/1.1.2/firmware.bin")
            XCTAssertEqual(result[4].firmwareURL.absoluteString,
                           "https://mbientlab.com/releases/metawear/0.1/0/vanilla/1.1.3/firmware.bin")
            XCTAssertEqual(result[5].firmwareURL.absoluteString,
                           "https://mbientlab.com/releases/metawear/0.1/0/vanilla/1.2.3/firmware.bin")
            XCTAssertEqual(result[6].firmwareURL.absoluteString,
                           "https://mbientlab.com/releases/metawear/0.1/0/vanilla/1.2.4/firmware.bin")
            XCTAssertEqual(result[7].firmwareURL.absoluteString,
                           "https://mbientlab.com/releases/metawear/0.1/0/vanilla/1.2.5/firmware.bin")
            XCTAssertEqual(result[8].firmwareURL.absoluteString,
                           "https://mbientlab.com/releases/metawear/0.1/0/vanilla/1.3.4/firmware.bin")
            XCTAssertEqual(result[9].firmwareURL.absoluteString,
                           "https://mbientlab.com/releases/metawear/0.1/0/vanilla/1.3.6/firmware.bin")
            return FirmwareServer.getLatestFirmwareAsync(hardwareRev: "0.1", modelNumber: "0")
        }.continueOnSuccessWithTask { result -> Task<URL> in
            XCTAssertEqual(result.firmwareURL.absoluteString,
                           "https://mbientlab.com/releases/metawear/0.1/0/vanilla/1.3.6/firmware.bin")
            return result.firmwareURL.downloadAsync()
        }.continueWith { t in
            XCTAssertFalse(t.faulted)
            XCTAssertNil(t.error)
            myExpectation.fulfill()
        }
        wait(for: [myExpectation], timeout: 60)
    }
    
    func testGetAllFirmwareAsync() {
        let myExpectation = XCTestExpectation(description: "getting info1")
        
        FirmwareServer.getAllFirmwareAsync(hardwareRev: "0.2", modelNumber: "18").continueOnSuccessWith { result in
            XCTAssertEqual(result[0].firmwareURL.absoluteString,
                           "https://mbientlab.com/releases/metawear/0.2/18/vanilla/1.4.0/firmware.zip")
            XCTAssertEqual(result[1].firmwareURL.absoluteString,
                           "https://mbientlab.com/releases/metawear/0.2/18/vanilla/1.4.1/firmware.zip")
            XCTAssertEqual(result[2].firmwareURL.absoluteString,
                           "https://mbientlab.com/releases/metawear/0.2/18/vanilla/1.18.0/firmware.zip")
        }.continueWith { t in
            XCTAssertFalse(t.faulted)
            XCTAssertNil(t.error)
            myExpectation.fulfill()
        }
        wait(for: [myExpectation], timeout: 60)
    }
}
