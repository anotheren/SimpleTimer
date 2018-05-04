//
//  SimpleTimer+DispatchTimeInterval.swift
//  SimpleTimer
//
//  Created by 刘栋 on 2018/5/4.
//  Copyright © 2018年 yidongyunshi.com. All rights reserved.
//

import Dispatch

extension DispatchTimeInterval {
    
    public static func from(seconds: Double) -> DispatchTimeInterval {
        return .milliseconds(Int(seconds * 1000))
    }
}
