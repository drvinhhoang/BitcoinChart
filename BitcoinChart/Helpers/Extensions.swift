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
