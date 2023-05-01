//
//  Extensions.swift
//  BitcoinChart
//
//  Created by VinhHoang on 30/04/2023.
//

import Foundation

extension Collection {
    subscript(safelyIndex i: Index) -> Element? {
        get {
            guard self.indices.contains(i) else { return nil }
            return self[i]
        }
    }
}

extension Decimal {
    var asDouble: Double { Double(truncating: self as NSNumber) }
    
    var floatValue: Float {
        return NSDecimalNumber(decimal:self).floatValue
    }
    
    var intValue: Int {
        return NSDecimalNumber(decimal:self).intValue
    }
}

extension Decimal {
    var currency: String { self.formatted(.currency(code: "USD")) }
}

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}


