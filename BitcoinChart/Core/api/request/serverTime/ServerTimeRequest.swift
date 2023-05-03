//
//  ServerTimeRequest.swift
//  BitcoinChart
//
//  Created by VinhHoang on 03/05/2023.
//

import Foundation

struct ServerTimeRequest: RequestProtocol {
    var requestType: RequestType {
        .GET
    }
    
    var path: String {
        "/api/v3/time"
    }
}
