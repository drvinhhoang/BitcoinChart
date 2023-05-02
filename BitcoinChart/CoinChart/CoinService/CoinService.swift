//
//  KlineChartService.swift
//  BitcoinChart
//
//  Created by VinhHoang on 02/05/2023.
//

import Foundation

actor CoinService {
    private let requestManager: RequestManagerProtocol
    
    init(requestManager: RequestManagerProtocol) {
        self.requestManager = requestManager
    }
}

extension CoinService: CoinFetcher {
    func getCurrentPrice() async -> String? {
        let request = CoinRequest.getCurrentPrice
        do {
            let currentPriceData: CurrentPrice = try await requestManager.initRequest(with: request)
            return currentPriceData.price
        } catch {
            BCLogger.log(error.localizedDescription)
            return nil
        }
    }
    
    func getServerTime() async -> String? {
        let request = ServerTimeRequest()
        do {
            let data: ServerTime = try await requestManager.initRequest(with: request)
            return String(data.serverTime)
        } catch {
            BCLogger.log(error.localizedDescription)
            return nil
        }
    }
    
    func fetchCoinKlineData(interval: String, endTime: String, limit: String) async -> [CoinData] {
        let request = CoinRequest.getBtcUsdtKline(interval: interval, endTime: endTime, limit: limit)
        do {
            let coinData: [CoinData] = try await requestManager.initRequest(with: request)
            return coinData
        } catch {
            BCLogger.log(error.localizedDescription)
            return []
        }
    }
}
