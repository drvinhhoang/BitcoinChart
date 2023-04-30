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

let coin = Coin(
    eventType: "kline",
    eventTime: 1682814793580,
    symbol: "BTCUSDT",
    kLine: KLine(startTime: 1682814780000,
                 closeTime: 1682814839999,
                 symbol: "BTCUSDT",
                 interval: "1m",
                 firstTradeId: 3100292333,
                 lastTradeId: 3100292519,
                 openPrice: "29189.47000000",
                 closePrice: "29185.75000000",
                 highPrice: "29189.48000000",
                 lowPrice: "29185.74000000",
                 baseAssetVolume: "0.81487000",
                 numberOfTrades: 187,
                 isKLineClosed: false,
                 quoteAssetVolume: "23783.46872390",
                 takerBuyBaseAssetVolume: "0.20981000",
                 takerBuyQuoteAssetVolume: "6123.78564460",
                 ignore: "0"
                ))


