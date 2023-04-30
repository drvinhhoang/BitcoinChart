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
    
    @Published var candleStickDisplayData: [CandleStickDisplayData] = []
    
    func request() throws -> URLRequest {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "data.binance.com"
        components.path = "/api/v3/klines"
        components.queryItems = [ "symbol": "BTCUSDT",
                                  "interval": "4h"].map { URLQueryItem(name: $0, value: $1) }
        guard let url = components.url else { throw NetworkError.invalidURL }
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return urlRequest
    }
    
    func callApiCoinData() async throws {
        let request = try? request()
        let (data, res) = try await URLSession.shared.data(for: request!)
        
        let decodedData = try? JSONDecoder().decode([Candlestick].self, from: data)
        //    print(String(data: data, encoding: .utf8), res)
        print(decodedData.flatMap({ arr in
            arr.compactMap(\.closePrice)
        }))
    }
    
    init() {
        self.candleStickDisplayData = getMockOneWeek4hIntervalData()
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
    
    func getMockOneWeek4hIntervalData() -> [CandleStickDisplayData] {
        do {
            guard let json = candleStickData.data(using: .utf8) else { return [] }
            let decodedData = try JSONDecoder().decode([Candlestick].self, from: json)
            let chartData: [CandleStickDisplayData] = decodedData.compactMap { data -> CandleStickDisplayData? in
                guard let openTime = data.kLineOpenTime,
                      let closeTime = data.kLineCloseTime,
                      let openPrice = data.openPrice,
                      let closePrice = data.closePrice,
                      let highPrice = data.highPrice,
                      let lowPrice = data.lowPrice,
                      let volume = data.volume else {
                    return nil
                }
                
                let kLineOpenTime = Date(timeIntervalSince1970: TimeInterval(openTime/1000))
                let klineCloseTIme = Date(timeIntervalSince1970: TimeInterval(closeTime/1000))
                return CandleStickDisplayData(kLineOpenTime: kLineOpenTime,
                                              kLineCloseTime: klineCloseTIme,
                                              openPrice: openPrice,
                                              highPrice: highPrice,
                                              lowPrice: lowPrice,
                                              closePrice: closePrice,
                                              volume: volume)
            }
            print(chartData)

            return chartData
        } catch {
            print(error.localizedDescription)

        }
        return []
    }
}
