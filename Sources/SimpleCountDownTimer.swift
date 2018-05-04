//
//  SimpleCountDownTimer.swift
//  SimpleTimer
//
//  Created by 刘栋 on 2018/5/4.
//  Copyright © 2018年 yidongyunshi.com. All rights reserved.
//

import Dispatch

public class SimpleCountDownTimer {
    
    public typealias SimpleCountDownTimerHandler = (SimpleCountDownTimer, _ leftTimes: Int) -> Void
    
    private let internalTimer: SimpleTimer
    private var leftTimes: Int
    private let originalTimes: Int
    private let handler: SimpleCountDownTimerHandler
    
    public init(interval: DispatchTimeInterval, times: Int, queue: DispatchQueue = .main, handler: @escaping SimpleCountDownTimerHandler) {
        self.leftTimes = times
        self.originalTimes = times
        self.handler = handler
        self.internalTimer = SimpleTimer.repeating(interval: interval, queue: queue, handler: { _ in })
        self.internalTimer.reschedule { [weak self] swiftTimer in
            guard let strongSelf = self else { return }
            if strongSelf.leftTimes > 0 {
                strongSelf.leftTimes = strongSelf.leftTimes - 1
                strongSelf.handler(strongSelf, strongSelf.leftTimes)
            } else {
                strongSelf.internalTimer.suspend()
            }
        }
    }
    
    public func start() {
        self.internalTimer.start()
    }
    
    public func suspend() {
        self.internalTimer.suspend()
    }
    
    public func reCountDown() {
        self.leftTimes = self.originalTimes
    }
}
