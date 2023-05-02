//
//  NetworkManager.swift
//  BitcoinChart
//
//  Created by VinhHoang on 30/04/2023.
//

import SwiftUI
import Combine

enum NetworkError: Error {
    case invalidURL
    case invalidData
}

class NetworkManager: ObservableObject {
    
    @Published var items: [CandleStick] = [] {
        didSet {
//            calculatePriceChangePercent()
        }
    }
    
    func calculatePriceChangePercent(openPrice: Decimal) {
        
    }
    @Published var currentPrice: String = ""
    let timer = Timer
        .publish(every: 2, on: .main, in: .common)
        .autoconnect()
    
    var cancellables = Set<AnyCancellable>()
    
    @Published var change: Double = 0
    
    @Published var selectedRange = IntervalRange.oneDay {
        didSet {
            Task {
                try await callApiCoinData(interval: selectedRange)
            }
        }
    }
    
    func request() throws -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "data.binance.com"
        components.path = "/api/v3/klines"
        components.queryItems = [ "symbol": "BTCUSDT",
                                  "interval": "1d"].map { URLQueryItem(name: $0, value: $1) }
        guard let url = components.url else { throw NetworkError.invalidURL }
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
    
    func getTimerServer() async throws -> Int? {
        let url = URL(string: "https://api.binance.com/api/v3/time")!
        let (data, res) = try await URLSession.shared.data(from: url)
        
        
        do {
            let decodedData = try JSONDecoder().decode(ServerTime.self, from: data)
            let time = decodedData.serverTime
            return time
        } catch {
            print(error.localizedDescription)
        }
        return nil
    }
    
    func callApiCoinData(interval: IntervalRange = .oneDay) async throws {
        let time = try await getTimerServer()
        guard let time = time else {
            return
        }
        let url = URL(string: "https://data.binance.com/api/v3/klines?symbol=BTCUSDT&interval=\(interval.rawValue)&endTime=\(time)&limit=\(interval.candleCount)")!
        let (data, _) = try await URLSession.shared.data(from: url)

        do {
            let decodedData = try JSONDecoder().decode([CoinData].self, from: data)
            let chartData: [CandleStick] = decodedData.compactMap(\.candleStick)
            await MainActor.run {
                self.items = chartData
            }
        } catch {
            print(error.localizedDescription)
        }

    }
    
    init() {
        getStatistic24h()
        getCurrentPrice()
        subscribeTimer()
    }
    
    func subscribeTimer() {
        timer
            .sink { time in
                self.getCurrentPrice()
            }
            .store(in: &cancellables)
        
    }

    
    
    func getServerTime() async throws -> Int {
        guard let url = URL(string: "https://data.binance.com/api/v3/time") else {
            throw NetworkError.invalidURL
        }
        let (data, _) = try await URLSession.shared.data(from: url)
        do {
            let decodedData = try JSONDecoder().decode(Int.self, from: data)
            return decodedData
        } catch {
            throw NetworkError.invalidData
        }
    }
    
    func getMockOneWeek4hIntervalData() -> [CandleStick] {
        do {
            guard let json = oneDayIntervalData.data(using: .utf8) else { return [] }
            let decodedData = try JSONDecoder().decode([CoinData].self, from: json)
            let chartData: [CandleStick] = decodedData.compactMap(\.candleStick)
            return chartData
        } catch {
            print(error.localizedDescription)
            
        }
        return []
    }
    
    func addMockData() {
        self.items = getMockOneWeek4hIntervalData()
    }
    
    func getCurrentPrice() {
        let url = URL(string: "https://data.binance.com/api/v3/avgPrice?symbol=BTCUSDT")!
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: CurrentPrice.self, decoder: JSONDecoder())
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("error: \(error)")
                }
            }, receiveValue: { res in
                DispatchQueue.main.async {
                    print(res.price, "vinh")
                    self.currentPrice = res.price
                }
            })
            .store(in: &cancellables)

    }
    
    // MARK: - Websocket:
    @Published var statistic24h: Statistic24h? = nil
    private var webSocketTask: URLSessionWebSocketTask!
    private var webSocketTasks24h: URLSessionWebSocketTask!
    
    func updateCandlestick() {
        let webSocketURL = URL(string: "wss://stream.binance.com:9443/ws/btcusdt@kline_\(selectedRange.rawValue)")!
        webSocketTask = setupSocket(url: webSocketURL)
    }
    
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
    

//    func listenForCurrentPrice() {
//        webSocketTask.receive { [weak self] result in
//            guard let self else { return }
//            switch result {
//            case .failure(let error):
//                print("Failed to receive message: \(error)")
//            case .success(let message):
//                switch message {
//                case .string(let text):
//                    let data = text.data(using: .utf8)
//                    let object = try? JSONDecoder().decode(CurrentPrice.self, from: data!)
//                    print("vinhht", object?.result?.price)
//                    DispatchQueue.main.async {
//                        self.currentPrice = object?.result?.price ?? ""
//                    }
//                case .data(let data):
//                    print("Received binary message: \(data)")
//                @unknown default:
//                    fatalError()
//                }
//            }
//           // self.listenForCurrentPrice()
//
//        }
//    }
    
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
        webSocketTask.cancel(with: .goingAway, reason: nil)
        DispatchQueue.main.async {
            self.currentPrice = ""
        }
    }
}

struct CurrentPrice: Codable {
    let mins: Int
    let price: String
}
