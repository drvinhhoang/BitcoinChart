//
//  CoinViewModel.swift
//  BitcoinChart
//
//  Created by VinhHoang on 02/05/2023.
//

import Foundation
import Combine

protocol CoinFetcher {
    func fetchCoinKlineData(interval: String, endTime: String, limit: String) async -> [CoinData]
    func getServerTime() async -> String?
    func getCurrentPrice() async -> String?
}

final class CoinViewModel: ObservableObject {

    private var task: Task<(), Error>?
    let timer = Timer
        .publish(every: 2, on: .main, in: .common)
        .autoconnect()
    var cancellables = Set<AnyCancellable>()
    @Published var priceChangePercent: Double = 0.00

    
    @Published var chartData: ChartData? = nil
    @Published var currentPrice: String = ""
  
    @Published var selectedRange = IntervalRange.fourHour {
        didSet {
            task?.cancel()
            task = Task {
                await fetchCoinKlineData(interval: selectedRange)
            }
        }
    }
    let coinFetcher: CoinFetcher
    
    init(coinFetcher: CoinFetcher) {
        self.coinFetcher = coinFetcher
    }
}

// MARK: - FETCH DATA
extension CoinViewModel {
    func fetchCoinKlineData(interval: IntervalRange = .fourHour) async {
        guard let serverTime = await coinFetcher.getServerTime() else { return }
        let klineData = await coinFetcher.fetchCoinKlineData(interval: interval.rawValue, endTime: serverTime, limit: String(interval.candleCount))
        let candleSticks = klineData.compactMap(\.candleStick)
        let chartRange = getChartRange(candleSticks)
        let chartData = ChartData(items: candleSticks, bounds: chartRange)
        await MainActor.run(body: {
            self.chartData = chartData
        })
    }
}

// MARK: - HELPERS
extension CoinViewModel {
    private func getChartRange(_ arr: [CandleStick]) -> ClosedRange<Double> {
        let max = arr.max(by: { $0.high < $1.high })?.high ?? 0
        let low = arr.min(by: { $0.low < $1.low })?.low ?? 0
        return low...max
    }
    
    private func calculatePriceChangePercent(openPrice: Double?) -> Double? {
        guard let openPrice else { return nil}
        let changePercent = ((Double(currentPrice) ?? 0) - openPrice) / openPrice
        let percent = changePercent * 100
        return percent
    }
}
