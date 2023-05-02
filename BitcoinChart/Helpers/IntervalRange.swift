//
//  IntervalRange.swift
//  BitcoinChart
//
//  Created by VinhHoang on 01/05/2023.
//

import Foundation

public enum IntervalRange: String, CaseIterable, Identifiable {
    public var id: UUID {
        UUID()
    }
    
    case oneMins = "1m"
    case fiveMins = "5m"
    case fifteenMins = "15m"
    case oneHour = "1h"
    case fourHour = "4h"
    case oneDay = "1d"
    
    public var candleCount: Int {
        switch self {
        case .oneMins:
            return 7 * 24 * 60
        case .fiveMins:
            return 7 * 24 * 60/5
        case .fifteenMins:
            return 7 * (60/15) * 24
        case .oneHour:
            return 7 * 24
        case .fourHour:
            return 7 * (24/4)
        case .oneDay:
            return 7 * 2
        }
    }
    
    var chartWidth: CGFloat {
        CGFloat(candleCount * candleWidth * 2)
    }
    
    var candleWidth: Int {
        switch self {
        case .oneMins:
            return 1
        case .fiveMins:
            return 1
        case .fifteenMins:
            return 2
        case .oneHour:
            return 4
        case .fourHour:
            return 8
        case .oneDay:
            return 16
        }
    }

}
