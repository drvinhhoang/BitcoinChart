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
    let subject = PassthroughSubject<IntervalRange, Never>()
    var intervalRange: IntervalRange
    let bounds: ClosedRange<Double>
    var lastOpenPrice: Double? {
        items.last?.open
    }
}
