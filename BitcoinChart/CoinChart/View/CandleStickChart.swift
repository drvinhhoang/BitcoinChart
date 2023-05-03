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
    let chartData: ChartData?
    
    init(chartData: ChartData?) {
        self.chartData = chartData
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
                    width: (proxy.size.width / CGFloat(candleSticks.count)) * 0.8)
                .foregroundStyle(candle.isClosingHigher ? .green : .red)
            }
            .chartYAxis { AxisMarks(preset: .automatic, values: .stride(by: 500)) }
            .chartYScale(domain: bound)
            .padding(.horizontal)
            .animation(.easeInOut, value: chartData?.intervalRange ?? .fourHour)
        }
    }
}
