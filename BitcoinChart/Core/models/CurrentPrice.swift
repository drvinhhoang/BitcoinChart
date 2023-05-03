//
//  CurrentPrice.swift
//  BitcoinChart
//
//  Created by VinhHoang on 02/05/2023.
//

import Foundation
import CoreData

struct CurrentPrice: Codable {
    let price: String
}

extension CurrentPrice {
    init(managedObject: CurrentPriceEntity) {
        self.price = managedObject.currentPrice ?? ""
    }
    
    mutating func toManagedObject(context: NSManagedObjectContext) {
        let entity = CurrentPriceEntity(context: context)
        entity.currentPrice = self.price
    }
}
