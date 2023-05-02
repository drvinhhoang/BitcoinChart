//
//  ChartData.swift
//  BitcoinChart
//
//  Created by VinhHoang on 02/05/2023.
//

import Foundation

struct ChartData {
    let items: [CandleStick]
    let bounds: ClosedRange<Double>
    var lastOpenPrice: Double? {
        items.last?.open
    }
}
