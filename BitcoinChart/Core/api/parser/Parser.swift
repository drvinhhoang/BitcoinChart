//
//  DataParser.swift
//  BitcoinChart
//
//  Created by VinhHoang on 02/05/2023.
//

import Foundation

protocol DataParserProtocol {
    func parse<T: Decodable>(data: Data) throws -> T
}

final class DataParser: DataParserProtocol {
    private var jsonDecoder: JSONDecoder
    
    init(jsonDecoder: JSONDecoder = JSONDecoder()) {
        self.jsonDecoder = jsonDecoder
    }
    
    func parse<T: Decodable>(data: Data) throws -> T {
        return try jsonDecoder.decode(T.self, from: data)
    }
}
