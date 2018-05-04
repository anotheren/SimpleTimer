//
//  SimpleTimerTests.swift
//  SimpleTimerTests iOS
//
//  Created by 刘栋 on 2018/5/4.
//  Copyright © 2018年 yidongyunshi.com. All rights reserved.
//

import XCTest
@testable import SimpleTimer

class SimpleTimerTests: XCTestCase {
    
    func testSingleTimer() {
        let expectation = self.expectation(description: "Timer fire")
        
        let timer = SimpleTimer(interval: .seconds(2)) { _ in
            print("timer fire")
            expectation.fulfill()
        }
        timer.start()
        self.waitForExpectations(timeout: 2.01, handler: nil)
    }
    
    func testRepeaticTimer() {
        let expectation = self.expectation(description: "Timer fire")
        
        var count = 0
        let timer = SimpleTimer.repeating(interval: .seconds(1)) { _ in
            count = count + 1
            if count == 2 {
                expectation.fulfill()
            }
        }
        timer.start()
        self.waitForExpectations(timeout: 2.01, handler: nil)
    }
    
    func testTimerAndInternalTimerRetainCycle() {
        var count = 0
        weak var weakReference: SimpleTimer?
        do {
            let timer = SimpleTimer.repeating(interval: .seconds(1)) { _ in
                count += 1
                print(count)
            }
            weakReference = timer
            timer.start()
        }
        XCTAssertNil(weakReference)
    }
    
    func testThrottle() {
        let expectation = self.expectation(description: "Test Throttle")
        
        var count = 0
        let timer = SimpleTimer.repeating(interval: .seconds(1)) { _ in
            
            SimpleTimer.throttle(interval: .from(seconds: 1.5), identifier: "not pass") {
                XCTFail("should not pass")
                expectation.fulfill()
            }
            
            SimpleTimer.throttle(interval: .from(seconds: 0.5), identifier: "pass") {
                count = count + 1
                if count == 4 {
                    expectation.fulfill()
                }
            }
        }
        timer.start()
        self.waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testRescheduleRepeating() {
        let expectation = self.expectation(description: "Reschedule Repeating")
        
        var count = 0
        let timer = SimpleTimer.repeating(interval: .seconds(1)) { timer in
            count = count + 1
            print(Date())
            if count == 3 {
                timer.reschedule(repeating: .seconds(3))
            }
            if count == 4 {
                expectation.fulfill()
            }
        }
        timer.start()
        self.waitForExpectations(timeout: 6.1, handler: nil)
    }
    
    func testRescheduleHandler() {
        let expectation = self.expectation(description: "Reschedule Handler")
        
        let timer = SimpleTimer(interval: .seconds(2)) { _ in
            print("should not pass")
        }
        timer.reschedule { _ in
            expectation.fulfill()
        }
        timer.start()
        self.waitForExpectations(timeout: 2, handler: nil)
    }
}
