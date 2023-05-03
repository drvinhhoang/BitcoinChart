//
//  CandleStickChart.swift
//  BitcoinChart
//
//  Created by VinhHoang on 01/05/2023.
//

import SwiftUI
import Charts

struct CandleStickChart: View {

    var candleSticks: [CandleStick]
    var candleWidth: Double
    
    var bound: ClosedRange<Double>
    
    init(chartData: ChartData?) {
        self.candleSticks = chartData?.items ?? []
        self.candleWidth = chartData?.intervalRange.candleWidth ?? 0
        self.bound = chartData?.bounds ?? 0...10000
    }

    var body: some View {
        VStack {
            chart
        }
    }

    private var chart: some View {
        GeometryReader { proxy in
            Chart(candleSticks) { candle in
                CandleStickMark(
                    timestamp: .value("Date", candle.timestamp),
                    open: .value("Open", candle.open),
                    high: .value("High", candle.high),
                    low: .value("Low", candle.low),
                    close: .value("Close", candle.close),
                    width: (proxy.size.width / CGFloat(candleSticks.count)) * 0.85)
                .foregroundStyle(candle.open < candle.close ? .green : .red)
            }
            .chartYAxis { AxisMarks(preset: .automatic, values: .stride(by: 1000)) }
            .chartYScale(domain: bound)
            .padding(.horizontal)
        }
       
    }
}

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
