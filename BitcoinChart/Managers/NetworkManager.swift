//
//  NetworkManager.swift
//  BitcoinChart
//
//  Created by VinhHoang on 30/04/2023.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidData
}

class NetworkManager: ObservableObject {
    
    @Published var items: [CandleStick] = []
    
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
    
    func callApiCoinData() async throws {
        let request = try? request()

        let url = URL(string: "https://data.binance.com/api/v3/klines?symbol=BTCUSDT&interval=1d&endTime=1682904305000&limit=30")!
        let (data, _) = try await URLSession.shared.data(from: url)

        do {
            let decodedData = try JSONDecoder().decode([CoinData].self, from: data)
            print(decodedData)
            let chartData: [CandleStick] = decodedData.compactMap(\.candleStick)
            await MainActor.run {
                self.items = chartData
            }
        } catch {
            print(error.localizedDescription)
        }

    }
    
//    init() {
//        self.items = getMockOneWeek4hIntervalData()
//    }

    
    
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
            print(chartData)
            
            return chartData
        } catch {
            print(error.localizedDescription)
            
        }
        return []
    }
    
    func addMockData() {
        self.items = getMockOneWeek4hIntervalData()
    }
}
