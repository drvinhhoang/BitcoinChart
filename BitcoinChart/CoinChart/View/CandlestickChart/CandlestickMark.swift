//
//  CandlestickMark.swift
//  BitcoinChart
//
//  Created by VinhHoang on 03/05/2023.
//

import SwiftUI
import Charts

struct CandleStickMark: ChartContent {
    let timestamp: PlottableValue<Date>
    let open: PlottableValue<Double>
    let high: PlottableValue<Double>
    let low: PlottableValue<Double>
    let close: PlottableValue<Double>
    let width: Double
    var hlWidth: Double {
        width * 0.2
    }
    
    var body: some ChartContent {
        Plot {
            // Composite ChartContent MUST be grouped into a plot for accessibility to work
            BarMark(
                x: timestamp,
                yStart: open,
                yEnd: close,
                width: MarkDimension(floatLiteral: width)
            )
            BarMark(
                x: timestamp,
                yStart: high,
                yEnd: low,
                width: MarkDimension(floatLiteral: hlWidth)
            )
            .opacity(0.8)
        }
    }
}
