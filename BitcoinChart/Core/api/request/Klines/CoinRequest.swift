//
//  CoinRequest.swift
//  BitcoinChart
//
//  Created by VinhHoang on 02/05/2023.
//

import Foundation

enum CoinRequest: RequestProtocol {
    case getBtcUsdtKline(interval: String, endTime: String, limit: String)
    case getCurrentPrice
    
    var path: String {
        switch self {
        case .getBtcUsdtKline:
            return "v3/klines"
        case .getCurrentPrice:
            return "/v3/avgPrice"
        }
    }
    
    var urlParams: [String : String?] {
        var params: [String: String?] = [:]
        switch self {
        case let .getBtcUsdtKline(interval, endTime, limit):
            params["symbol"] = "BTCUSDT"
            params["interval"] = interval
            params["endTime"] = endTime
            params["limit"] = limit
        case .getCurrentPrice:
            params["symbol"] = "BTCUSDT"
        }
        return params
    }
    
    var requestType: RequestType {
        .GET
    }
}
