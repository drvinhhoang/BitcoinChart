//
//  CandleStickChart.swift
//  BitcoinChart
//
//  Created by VinhHoang on 01/05/2023.
//

import SwiftUI
import Charts

struct CandleStickChart: View {

    var currentPrices: [CandleStick]
    var candleWidth: Double
    
    var bound: ClosedRange<Double>
    
    init(prices: [CandleStick], candleWidth: Double, bound: ClosedRange<Double>) {
        self.currentPrices = prices
        self.candleWidth = candleWidth
        self.bound = bound
    }

    var body: some View {
        VStack {
            chart
        }
    }

    private var chart: some View {
        Chart(currentPrices) { price in
            CandleStickMark(
                timestamp: .value("Date", price.timestamp),
                open: .value("Open", price.open),
                high: .value("High", price.high),
                low: .value("Low", price.low),
                close: .value("Close", price.close),
                width: candleWidth)
            
            .foregroundStyle(price.open < price.close ? .green : .red)
        }
        .chartYAxis { AxisMarks(preset: .automatic, values: .stride(by: 1000)) }
        .chartYScale(domain: bound)
        .padding(.horizontal)
    }
}

struct CandleStickMark: ChartContent {
    let timestamp: PlottableValue<Date>
    let open: PlottableValue<Double>
    let high: PlottableValue<Double>
    let low: PlottableValue<Double>
    let close: PlottableValue<Double>
    let width: Double
    
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
                width: 2
            )
            .opacity(0.5)
        }
    }
}

// MARK: - Preview

//struct CandleStickChart_Previews: PreviewProvider {
//    static var previews: some View {
//        CandleStickChart(prices: [], candleWidth: 10)
//    }
//}
