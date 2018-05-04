//
//  SimpleCountDownTimerTests.swift
//  SimpleTimerTests iOS
//
//  Created by 刘栋 on 2018/5/4.
//  Copyright © 2018年 yidongyunshi.com. All rights reserved.
//

import XCTest
@testable import SimpleTimer

class SimpleCountDownTimerTests: XCTestCase {
    
    func testCountDownTimer() {
        let expectation = self.expectation(description: "Test Count Down Timer")
        
        let label = UILabel()
        let timer = SimpleCountDownTimer(interval: .from(seconds: 0.1), times: 10) { _, leftTimes in
            label.text = "\(leftTimes)"
            print(label.text!)
            if label.text == "0" {
                expectation.fulfill()
            }
        }
        timer.start()
        
        self.waitForExpectations(timeout: 1.01, handler: nil)
    }
}
