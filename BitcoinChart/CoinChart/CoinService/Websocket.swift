//
//  Websocket.swift
//  BitcoinChart
//
//  Created by VinhHoang on 30/04/2023.
//

import Foundation
import CoreData

// MARK: - Welcome
struct Statistic24h: Codable {
    let high, low, baseVolume, quoteVolume: String?

    enum CodingKeys: String, CodingKey {
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

// MARK: - Coredata entity

extension Statistic24h {
    init?(managedObject: Statistic24hEntity?) {
        self.high = managedObject?.high
        self.low = managedObject?.low
        self.baseVolume = managedObject?.baseVolume
        self.quoteVolume = managedObject?.quoteVolume
    }
    
    mutating func toManagedObject(context: NSManagedObjectContext) {
        let statistic24h = Statistic24hEntity(context: context)
        statistic24h.high = self.high
        statistic24h.low = self.low
        statistic24h.baseVolume = self.baseVolume
        statistic24h.quoteVolume = self.quoteVolume
    }
}
