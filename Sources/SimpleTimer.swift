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
    
    private let internalTimer: DispatchSourceTimer
    private var isRunning = false
    private var handler: SimpleTimerHandler
    
    public let repeats: Bool
    
    public init(interval: DispatchTimeInterval, repeats: Bool = false, leeway: DispatchTimeInterval = .seconds(0), queue: DispatchQueue = .main , handler: @escaping SimpleTimerHandler) {
        self.handler = handler
        self.repeats = repeats
        internalTimer = DispatchSource.makeTimerSource(queue: queue)
        internalTimer.setEventHandler { [weak self] in
            guard let strongSelf = self else { return }
            handler(strongSelf)
        }
        
        if repeats {
            internalTimer.schedule(deadline: .now() + interval, repeating: interval, leeway: leeway)
        } else {
            internalTimer.schedule(deadline: .now() + interval, leeway: leeway)
        }
    }
    
    deinit {
        if !self.isRunning {
            internalTimer.resume()
        }
    }
    
    public func fire() {
        if repeats {
            handler(self)
        } else {
            handler(self)
            internalTimer.cancel()
        }
    }
    
    public func start() {
        if !isRunning {
            internalTimer.resume()
            isRunning = true
        }
    }
    
    public func suspend() {
        if isRunning {
            internalTimer.suspend()
            isRunning = false
        }
    }
    
    public func reschedule(repeating interval: DispatchTimeInterval) {
        if repeats {
            internalTimer.schedule(deadline: .now() + interval, repeating: interval)
        }
    }
    
    public func reschedule(handler: @escaping SimpleTimerHandler) {
        self.handler = handler
        internalTimer.setEventHandler { [weak self] in
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
