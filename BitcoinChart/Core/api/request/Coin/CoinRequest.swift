//
//  CoinRequest.swift
//  BitcoinChart
//
//  Created by VinhHoang on 02/05/2023.
//  Updated by Codex

import Foundation

enum CoinRequest: RequestProtocol {
    case getKline(symbol: String, interval: String, endTime: String, limit: String)
    case getCurrentPrice(symbol: String)
    case getAllPrices

    var host: String {
        APIConstants.host
    }

    var path: String {
        switch self {
        case .getKline:
            return "/api/v3/klines"
        case .getCurrentPrice:
            return "/api/v3/avgPrice"
        case .getAllPrices:
            return "/api/v3/ticker/price"
        }
    }

    var urlParams: [String : String?] {
        var params: [String: String?] = [:]
        switch self {
        case let .getKline(symbol, interval, endTime, limit):
            params["symbol"] = symbol
            params["interval"] = interval
            params["endTime"] = endTime
            params["limit"] = limit
        case let .getCurrentPrice(symbol):
            params["symbol"] = symbol
        case .getAllPrices:
            break
        }
        return params
    }

    var requestType: RequestType { .GET }
}
