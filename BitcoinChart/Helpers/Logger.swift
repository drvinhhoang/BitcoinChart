//
//  Logger.swift
//  BitcoinChart
//
//  Created by VinhHoang on 02/05/2023.
//

import Foundation
import OSLog

struct BCLogger {
    private static let logger = Logger()
    static func log(_ mess: String, file: String = #fileID, line: Int = #line, function: String = #function) {
        logger.log(level: .default, "[file: \(file), line: \(line), \(function)] : \(mess)")
    }
}
