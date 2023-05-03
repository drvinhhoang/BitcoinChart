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
            return 1 * (60)
        case .fiveMins:
            return 1 * 6 * (60/5)
        case .fifteenMins:
            return 12 * (60/15)
        case .oneHour:
            return 2 * 24
        case .fourHour:
            return 7 * (24/4)
        case .oneDay:
            return 7 * 4
        }
    }
    
    var chartWidth: CGFloat {
        
        if self == .oneDay {
            return .infinity
        } else {
            return CGFloat(Double(candleCount) * candleWidth * 1.2)
        }
    }
    
    var candleWidth: Double {
        switch self {
        case .oneMins:
            return 4
        case .fiveMins:
            return 4
        case .fifteenMins:
            return 4
        case .oneHour:
            return 6
        case .fourHour:
            return 8
        case .oneDay:
            return 10
        }
    }
}
