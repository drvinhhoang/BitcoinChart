//
//  Coin.swift
//  BitcoinChart
//
//  Created by VinhHoang on 30/04/2023.
//

import Foundation

struct Coin: Codable {
    let eventType: String
    let eventTime: Int
    let symbol: String
    let kLine: KLine
    
    enum CodingKeys: String, CodingKey {
        case eventType = "e"
        case eventTime = "E"
        case symbol = "s"
        case kLine = "k"
    }
}

// MARK: - K
struct KLine: Codable {
    let startTime, closeTime: Int
    let symbol, interval: String
    let firstTradeId, lastTradeId: Int
    let openPrice, closePrice, highPrice, lowPrice: String
    let baseAssetVolume: String
    let numberOfTrades: Int
    let isKLineClosed: Bool
    let quoteAssetVolume, takerBuyBaseAssetVolume, takerBuyQuoteAssetVolume, ignore: String
    
    enum CodingKeys: String, CodingKey {
        case startTime = "t"
        case closeTime = "T"
        case symbol = "s"
        case interval = "i"
        case firstTradeId = "f"
        case lastTradeId = "L"
        case openPrice = "o"
        case closePrice = "c"
        case highPrice = "h"
        case lowPrice = "l"
        case baseAssetVolume = "v"
        case numberOfTrades = "n"
        case isKLineClosed = "x"
        case quoteAssetVolume = "q"
        case takerBuyBaseAssetVolume = "V"
        case takerBuyQuoteAssetVolume = "Q"
        case ignore = "B"
    }
}
