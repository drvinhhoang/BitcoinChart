//
//  NetworkError.swift
//  BitcoinChart
//
//  Created by VinhHoang on 02/05/2023.
//

import Foundation

public enum NetworkError: LocalizedError {
    case invalidServerResponse
    case invalidURL
    case invalidData
    public var errorDescription: String? {
        switch self {
        case .invalidServerResponse:
            return "The server returned an invalid response."
        case .invalidURL:
            return "URL string is malformed."
        case .invalidData:
            return "Data is not in correct format"
        }
    }
}
