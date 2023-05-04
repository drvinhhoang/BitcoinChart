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
    let isLoading: Bool
    
    init(chartData: ChartData?, isLoading: Bool) {
        self.chartData = chartData
        self.candleSticks = chartData?.items ?? []
        self.candleWidth = chartData?.intervalRange.candleWidth ?? 0
        self.bound = chartData?.bounds ?? 0...100
        self.isLoading = isLoading
    }

    var body: some View {
        VStack {
            ZStack {
                chart
                if isLoading {
                    ProgressView("Loading...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                    
                }
            }
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
            .chartYAxis { AxisMarks(preset: .automatic, values: .automatic()) }
            .chartXAxis { AxisMarks(preset: .automatic, values: .automatic()) }
            .chartYScale(domain: bound)
        }
    }
}
