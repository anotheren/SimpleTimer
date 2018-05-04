//
//  SimpleTimer.swift
//  SimpleTimer
//
//  Created by 刘栋 on 2018/5/4.
//  Copyright © 2018年 yidongyunshi.com. All rights reserved.
//

import Dispatch

public class SimpleTimer {
    
    public typealias SimpleTimerHandler = (SimpleTimer) -> Void
    
    private let _timer: DispatchSourceTimer
    private var _isRunning = false
    private var _handler: SimpleTimerHandler
    
    public let repeats: Bool
    
    public init(interval: DispatchTimeInterval, repeats: Bool = false, leeway: DispatchTimeInterval = .seconds(0), queue: DispatchQueue = .main , handler: @escaping SimpleTimerHandler) {
        self._handler = handler
        self.repeats = repeats
        _timer = DispatchSource.makeTimerSource(queue: queue)
        _timer.setEventHandler { [weak self] in
            guard let strongSelf = self else { return }
            handler(strongSelf)
        }
        
        if repeats {
            _timer.schedule(deadline: .now() + interval, repeating: interval, leeway: leeway)
        } else {
            _timer.schedule(deadline: .now() + interval, leeway: leeway)
        }
    }
    
    deinit {
        if !self._isRunning {
            _timer.resume()
        }
    }
    
    public func fire() {
        if repeats {
            _handler(self)
        } else {
            _handler(self)
            _timer.cancel()
        }
    }
    
    public func start() {
        if !_isRunning {
            _timer.resume()
            _isRunning = true
        }
    }
    
    public func suspend() {
        if _isRunning {
            _timer.suspend()
            _isRunning = false
        }
    }
    
    public func reschedule(repeating interval: DispatchTimeInterval) {
        if repeats {
            _timer.schedule(deadline: .now() + interval, repeating: interval)
        }
    }
    
    public func reschedule(handler: @escaping SimpleTimerHandler) {
        self._handler = handler
        _timer.setEventHandler { [weak self] in
            guard let strongSelf = self else { return }
            handler(strongSelf)
        }
    }
}

// MARK: - Repeating

extension SimpleTimer {
    
    public static func repeating(interval: DispatchTimeInterval, leeway: DispatchTimeInterval = .seconds(0), queue: DispatchQueue = .main , handler: @escaping SimpleTimerHandler) -> SimpleTimer {
        return SimpleTimer(interval: interval, repeats: true, leeway: leeway, queue: queue, handler: handler)
    }
}

// MARK: - Throttle

extension SimpleTimer {
    
    private static var timers = [String: DispatchSourceTimer]()
    
    public static func throttle(interval: DispatchTimeInterval, identifier: String, queue: DispatchQueue = .main , handler: @escaping () -> Void) {
        if let previousTimer = timers[identifier] {
            previousTimer.cancel()
            timers.removeValue(forKey: identifier)
        }
        
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timers[identifier] = timer
        timer.schedule(deadline: .now() + interval)
        timer.setEventHandler {
            handler()
            timer.cancel()
            timers.removeValue(forKey: identifier)
        }
        timer.resume()
    }
    
    public static func cancelThrottlingTimer(identifier: String) {
        if let previousTimer = timers[identifier] {
            previousTimer.cancel()
            timers.removeValue(forKey: identifier)
        }
    }
}
