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
    func getCurrentPrice() async -> CurrentPrice? {
        let request = CoinRequest.getCurrentPrice
        do {
            let currentPriceData: CurrentPrice = try await requestManager.initRequest(with: request)
            return currentPriceData
        } catch {
            BCLogger.log(error.localizedDescription)
            return nil
        }
    }
    
    func getServerTime() async throws-> String? {
        let request = ServerTimeRequest()
        let data: ServerTime = try await requestManager.initRequest(with: request)
        return String(data.serverTime)
    }
    
    func fetchCoinKlineData(interval: String, endTime: String, limit: String) async throws -> [CoinData] {
        let request = CoinRequest.getBtcUsdtKline(interval: interval, endTime: endTime, limit: limit)
        let coinData: [CoinData] = try await requestManager.initRequest(with: request)
        return coinData
    }
}
