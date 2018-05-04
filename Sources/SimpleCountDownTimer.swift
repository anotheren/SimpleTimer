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
    
    private let _timer: SimpleTimer
    private var _leftTimes: Int
    private let _originalTimes: Int
    private let _handler: SimpleCountDownTimerHandler
    
    public init(interval: DispatchTimeInterval, times: Int, queue: DispatchQueue = .main, handler: @escaping SimpleCountDownTimerHandler) {
        self._leftTimes = times
        self._originalTimes = times
        self._handler = handler
        self._timer = SimpleTimer.repeating(interval: interval, queue: queue, handler: { _ in })
        self._timer.reschedule { [weak self] swiftTimer in
            guard let strongSelf = self else { return }
            if strongSelf._leftTimes > 0 {
                strongSelf._leftTimes = strongSelf._leftTimes - 1
                strongSelf._handler(strongSelf, strongSelf._leftTimes)
            } else {
                strongSelf._timer.suspend()
            }
        }
    }
    
    public func start() {
        self._timer.start()
    }
    
    public func suspend() {
        self._timer.suspend()
    }
    
    public func reCountDown() {
        self._leftTimes = self._originalTimes
    }
}
