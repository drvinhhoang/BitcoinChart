//
//  Candelstick.swift
//  BitcoinChart
//
//  Created by VinhHoang on 30/04/2023.
//

import Foundation

typealias Candlestick = [CoinProperty]

enum CoinProperty: Codable {
    case integer(Int)
    case string(String)
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(Candlestick.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for WelcomeElement"))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

extension CoinProperty {
    var stringValue: String {
        switch self {
        case .integer(let value):
            return String(value)
        case .string(let stringVal):
            return stringVal
        }
    }
    
    var integerValue: Int? {
        switch self {
        case .integer(let value):
            return value
        case .string(let stringVal):
            return Int(stringVal)
        }
    }
}

extension Candlestick {
    var kLineOpenTime: Int? {
        return self[safelyIndex: 0]?.integerValue
    }
    
    var openPrice: String? {
        return self[safelyIndex: 1]?.stringValue
    }
    
    var highPrice: String? {
        return self[safelyIndex: 2]?.stringValue
    }
    
    var lowPrice: String? {
        return self[safelyIndex: 3]?.stringValue
    }
    
    var closePrice: String? {
        return self[safelyIndex: 4]?.stringValue
    }
    
    var volume: String? {
        return self[safelyIndex: 5]?.stringValue
    }
    
    var kLineCloseTime: Int? {
        return self[safelyIndex: 6]?.integerValue
    }
    
    var quoteAssetVolume: String? {
        return self[safelyIndex: 7]?.stringValue
    }
    
    var numberOfTrades: Int? {
        return self[safelyIndex: 8]?.integerValue
    }
    
    var takerBuyBaseAssetVolume: String? {
        return self[safelyIndex: 9]?.stringValue
    }
    
    var takerBuyQuoteAssetVolume: String? {
        return self[safelyIndex: 10]?.stringValue
    }
}

struct CandleStickDisplayData {
    var kLineOpenTime: Date
    var kLineCloseTime: Date
    var openPrice: String
    var highPrice: String
    var lowPrice: String
    var closePrice: String
    var volume: String
}
