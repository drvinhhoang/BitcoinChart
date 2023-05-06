//
//  ChartData.swift
//  BitcoinChart
//
//  Created by VinhHoang on 02/05/2023.
//

import Foundation
import Combine

struct ChartData {
    let items: [CandleStick]
    var intervalRange: IntervalRange
    let bounds: ClosedRange<Double>
    var changePercent: Double? {
        guard let last = items.last else { return nil }
        let change = (last.close - last.open) / last.open
        return change * 100
    }
    
    init(_ items: [CandleStick], intervalRange: IntervalRange) {
        self.items = items
        self.bounds = Self.getChartBounds(items)
        self.intervalRange = intervalRange
    }
    
    private static func getChartBounds(_ arr: [CandleStick]) -> ClosedRange<Double> {
        let max = arr.max(by: { $0.high < $1.high })?.high ?? 0
        let low = arr.min(by: { $0.low < $1.low })?.low ?? 0
        return low...max
    }
}

extension Collection where Element == CandleStick {
    var high: Double {
        let max = self.max(by: { $0.high < $1.high })?.high ?? 0
        return max
    }
    
    var low: Double {
        let low = self.min(by: { $0.low < $1.low })?.low ?? 0
        return low
    }
}
