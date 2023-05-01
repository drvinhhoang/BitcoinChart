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
    
    var upperBound: Decimal {
        let val = getUpperBound(currentPrices)
        return val + (val / 50)
    }
    
    var lowerBound: Decimal {
        let val = getLowerBound(currentPrices)
        return val - (val / 50)
    }

    init(prices: [CandleStick]) {
        self.currentPrices = prices
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
                close: .value("Close", price.close)
            )
            .foregroundStyle(price.open < price.close ? .green : .red)
        }
        .frame(maxWidth: .infinity, maxHeight: 400)
        .chartYScale(domain: ClosedRange(uncheckedBounds: (lower: lowerBound, upper: upperBound)))
        .chartYAxis { AxisMarks(preset: .inset, values: .stride(by: 1000)) }
        .padding(.horizontal)
    }
}

struct CandleStickMark: ChartContent {
    let timestamp: PlottableValue<Date>
    let open: PlottableValue<Decimal>
    let high: PlottableValue<Decimal>
    let low: PlottableValue<Decimal>
    let close: PlottableValue<Decimal>
    
    var body: some ChartContent {
        Plot {
            // Composite ChartContent MUST be grouped into a plot for accessibility to work
            BarMark(
                x: timestamp,
                yStart: open,
                yEnd: close,
                width: 10
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

struct CandleStickChart_Previews: PreviewProvider {
    static var previews: some View {
        CandleStickChart(prices: [])
    }
}
