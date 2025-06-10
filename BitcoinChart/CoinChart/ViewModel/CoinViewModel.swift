//
//  CoinViewModel.swift
//  BitcoinChart
//
//  Created by VinhHoang on 02/05/2023.
//  Updated by Codex

import Combine
import CoreData

protocol CoinFetcher {
    func fetchCoinKlineData(symbol: String, interval: String, endTime: String, limit: String) async throws -> [CoinData]
    func getServerTime() async throws -> String?
    func getCurrentPrice(symbol: String) async -> CurrentPrice?
    func fetchAllPrices() async throws -> [CoinSimple]
}

protocol StatisticFetcher {
    var subject: PassthroughSubject<Statistic24h, Never> { get }
}

protocol CoinPersistence {
    var savedCandlesticks: PassthroughSubject<[CandlestickEntity], Never> { get }
    var savedStatistic24h: PassthroughSubject<Statistic24hEntity?, Never> { get }
    var currentPrice: PassthroughSubject<String, Never> { get }
    func save(candlesticks: [CandleStick], interval: IntervalRange) async throws
    func saveCurrentPrice(_ price: CurrentPrice?) async throws
    func saveStatistic(_ statistic: Statistic24h?) async throws
    func updateDisplayData(range: IntervalRange) async
}

final class CoinViewModel: ObservableObject {
    private var selectRangeTask: Task<(), Error>?
    private var intervalUpdateTask: Task<(), Error>?
    private let timer = Timer
        .publish(every: 5, on: .main, in: .common)
        .autoconnect()
    private var cancellables = Set<AnyCancellable>()
    private let coinFetcher: CoinFetcher
    private let persistence: CoinPersistence
    private let statisticFetcher: StatisticFetcher
    let symbol: String

    @Published @MainActor var priceChangePercent: Double = 0.00
    @Published @MainActor var chartData: ChartData? = nil
    @Published @MainActor var currentPrice: String = ""
    @Published @MainActor var statistic24h: Statistic24h? = nil
    @Published @MainActor var isLoading: Bool = false
    @Published var selectedRange = IntervalRange.fourHour {
        didSet {
            selectRangeTask?.cancel()
            intervalUpdateTask?.cancel()
            selectRangeTask = Task {
                await showLoading(true)
                await fetchCoinKlineData(interval: selectedRange)
                await showLoading(false)
            }
        }
    }

    init(symbol: String,
         coinFetcher: CoinFetcher,
         statisticFetcher: StatisticFetcher,
         coinPersistence: CoinPersistence) {
        self.symbol = symbol
        self.coinFetcher = coinFetcher
        self.persistence = coinPersistence
        self.statisticFetcher = statisticFetcher
        addSubscriptions()
        Task {
            await getCurrentPrice()
        }
    }
}

// MARK: - Subscrtiptions
extension CoinViewModel {
    private func addSubscriptions() {
        addPersistenceSubscriptions()
        $chartData
            .compactMap(\.?.changePercent)
            .receive(on: DispatchQueue.main)
            .assign(to: &$priceChangePercent)

        timer
            .sink { [weak self] _ in
                guard let self else { return }
                self.intervalUpdateTask = Task {
                    await self.getCurrentPrice()
                    await self.fetchCoinKlineData(interval: self.selectedRange)
                }
            }
            .store(in: &cancellables)

        statisticFetcher.subject
            .sink { [weak self] statistic in
                guard let self else { return }
                Task {
                    try? await self.persistence.saveStatistic(statistic)
                }
            }
            .store(in: &cancellables)
    }

    private func addPersistenceSubscriptions() {
        persistence.savedCandlesticks
            .map(convertChartData)
            .receive(on: DispatchQueue.main)
            .assign(to: &$chartData)

        persistence.savedStatistic24h
            .compactMap({ savedObject in
                Statistic24h(managedObject: savedObject)
            })
            .receive(on: DispatchQueue.main)
            .assign(to: &$statistic24h)

        persistence.currentPrice
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentPrice)
    }
}

// MARK: - FETCH DATA
extension CoinViewModel {
    func fetchCoinKlineData(interval: IntervalRange = .fourHour) async {
        do {
            let serverTime = try await coinFetcher.getServerTime()
            guard let serverTime else {
                return
            }
            let klineData = try await coinFetcher.fetchCoinKlineData(symbol: symbol, interval: interval.rawValue, endTime: serverTime, limit: String(interval.candleCount))
            let candlesticks = klineData.compactMap { $0.toCandleStick(with: interval) }
            try await persistence.save(candlesticks: candlesticks, interval: interval)
        } catch {
            BCLogger.log(error.localizedDescription)
            await persistence.updateDisplayData(range: interval)
        }
    }

    private func getCurrentPrice() async {
        let currentPrice = await coinFetcher.getCurrentPrice(symbol: symbol)
        do {
            try await persistence.saveCurrentPrice(currentPrice)
        } catch {
            BCLogger.log(error.localizedDescription)
        }
    }

    func fetchAllCoins() async -> [CoinSimple] {
        do {
            return try await coinFetcher.fetchAllPrices()
        } catch {
            BCLogger.log(error.localizedDescription)
            return []
        }
    }
}

// MARK: - HELPERS
extension CoinViewModel {
    private func convertChartData(_ savedEntities: [CandlestickEntity]) -> ChartData? {
        let candlesticks = savedEntities.map { CandleStick(managedObject: $0) }
        guard let intervalRange = candlesticks.first?.intervalRange else { return nil }
        guard let range = IntervalRange(rawValue: intervalRange) else { return nil }
        return ChartData(candlesticks, intervalRange: range)
    }

    func showLoading(_ show: Bool) async {
        await MainActor.run {
            isLoading = show
        }
    }
}
