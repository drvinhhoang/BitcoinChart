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
    private var webSocketTasks24h: URLSessionWebSocketTask!
    private var task: Task<(), Error>?
    private let timer = Timer
        .publish(every: 2, on: .main, in: .common)
        .autoconnect()
    private var cancellables = Set<AnyCancellable>()
    private let coinFetcher: CoinFetcher
    
    @Published @MainActor var priceChangePercent: Double = 0.00
    @Published @MainActor var chartData: ChartData? = nil
    @Published @MainActor var currentPrice: String = ""
    @Published @MainActor var statistic24h: Statistic24h? = nil
    @Published @MainActor var selectedRange = IntervalRange.fourHour {
        didSet {
            task?.cancel()
            task = Task {
                await fetchCoinKlineData(interval: selectedRange)
            }
        }
    }
    
    init(coinFetcher: CoinFetcher) {
        self.coinFetcher = coinFetcher
        getStatistic24h()
        Task {
            let currentPrice = await coinFetcher.getCurrentPrice()
            await MainActor.run {
                guard let currentPrice else { return }
                self.currentPrice = currentPrice
            }
        }
        subscribeTimer()
    }
    
    deinit {
        closeScocket()
    }
    
    func subscribeTimer() {
        timer
            .sink { time in
                Task {
                    await self.coinFetcher.getCurrentPrice()
                }
            }
            .store(in: &cancellables)
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
            self.priceChangePercent = self.calculatePriceChangePercent(openPrice: chartData.lastOpenPrice)
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
    
    @MainActor
    private func calculatePriceChangePercent(openPrice: Double?) -> Double {
        guard let openPrice else { return 0 }
        let changePercent = ((Double(currentPrice) ?? 0) - openPrice) / openPrice
        let percent = changePercent * 100
        return percent
    }
}

// MARK: - SOCKET

extension CoinViewModel {
    
    func getStatistic24h() {
        let webSocketURL = URL(string:"wss://stream.binance.com:9443/ws/btcusdt@ticker")!
        webSocketTasks24h = setupSocket(url: webSocketURL)
        listenForStatistic24h()
    }
    
    func setupSocket(url: URL) -> URLSessionWebSocketTask {
        let ws = URLSession.shared.webSocketTask(with: url)
        ws.resume()
        return ws
    }
    
    func listenForStatistic24h() {
        webSocketTasks24h.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error):
                print("Failed to receive message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    let data = text.data(using: .utf8)
                    let object = try? JSONDecoder().decode(Statistic24h.self, from: data!)
                    DispatchQueue.main.async {
                        self.statistic24h = object
                    }
                case .data(let data):
                    print("Received binary message: \(data)")
                @unknown default:
                    fatalError()
                }
            }
            self.listenForStatistic24h()
        }
    }
    
    func closeScocket() {
        webSocketTasks24h.cancel(with: .goingAway, reason: nil)
    }
}
