//
//  Websocket.swift
//  BitcoinChart
//
//  Created by VinhHoang on 30/04/2023.
//

import Foundation

// MARK: - Welcome
struct Statistic24h: Codable {
    let symbol, priceChangePercent, averagePrice, high: String?
    let low, baseVolume, quoteVolume: String?

    enum CodingKeys: String, CodingKey {
        case symbol = "s"
        case priceChangePercent = "P"
        case averagePrice = "w"
        case high = "h"
        case low = "l"
        case baseVolume = "v"
        case quoteVolume =  "q"
    }
    
    var formattedHigh: String {
        Double(high ?? "0")?.asNumberWith2Decimals() ?? ""
    }
    
    var formattedLow: String {
        Double(low ?? "")?.asNumberWith2Decimals() ?? ""
    }
    
    var formattedBaseVolume: String {
        Double(baseVolume ?? "")?.asNumberWith2Decimals() ?? ""
    }
    
    var formattedQuoteVolume: String {
        Double(quoteVolume ?? "")?.formattedWithAbbreviations() ?? ""
    }
}
