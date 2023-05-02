//
//  Candelstick.swift
//  BitcoinChart
//
//  Created by VinhHoang on 30/04/2023.
//

import Foundation

typealias CoinData = [CoinProperty]

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
        throw DecodingError.typeMismatch(CoinData.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for WelcomeElement"))
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

extension CoinData {
    var openTime: Int? {
        return self[safelyIndex: 0]?.integerValue
    }
    
    var open: Double? {
        if let str = self[safelyIndex: 1]?.stringValue {
            return Double(str)
        }
        return nil
    }
    
    var high: Double? {
        if let str = self[safelyIndex: 2]?.stringValue {
            return Double(str)
        }
        return nil
    }
    
    var low: Double? {
        if let str = self[safelyIndex: 3]?.stringValue {
            return Double(str)
        }
        return nil
    }
    
    var close: Double? {
        if let str = self[safelyIndex: 4]?.stringValue {
            return Double(str)
        }
        return nil
    }
    
    var closeTime: Double? {
        if let intVal = self[safelyIndex: 6]?.integerValue {
            return Double(intVal)
        }
        return nil
    }
    
    var candleStick: CandleStick? {
        guard let open, let close, let high, let low, let openTime else {
            return nil
        }
        return CandleStick(timestamp: Date(timeIntervalSince1970: (Double(openTime)/1000)),
                                      open: open,
                                      close: close,
                                      high: high,
                                      low: low)
    }
}

struct CandleStick: Identifiable {
    let id = UUID()
    let timestamp: Date
    let open: Double
    let close: Double
    let high: Double
    let low: Double
}

extension CandleStick {
    var isClosingHigher: Bool {
        self.open < self.close
    }
    
    var accessibilityTrendSummary: String {
        "Price movement: \(isClosingHigher ? "up" : "down")"
    }
    
//    var accessibilityDescription: String {
//        return "Open: \(self.open.currency), Close: \(self.close.currency), High: \(self.high.currency), Low: \(self.low.currency)"
//    }
}

func getLowerBound(_ arr: [CandleStick]) -> Double {
    return arr.min(by: { $0.low < $1.low })?.low ?? 0
}

func getUpperBound(_ arr: [CandleStick]) -> Double {
    return arr.max(by: { $0.low < $1.low })?.high ?? 0
}
