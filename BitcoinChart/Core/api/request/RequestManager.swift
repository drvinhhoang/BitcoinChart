//
//  RequestManager.swift
//  BitcoinChart
//
//  Created by VinhHoang on 02/05/2023.
//

import Foundation

protocol RequestManagerProtocol {
    var apiManager: APIManagerProtocol { get }
    func initRequest<T: Decodable>(with data: RequestProtocol) async throws -> T
}

final class RequestManager: RequestManagerProtocol {
    private var jsonDecoder: JSONDecoder = JSONDecoder()
    let apiManager: APIManagerProtocol
    
    init(apiManager: APIManagerProtocol = APIManager()) {
        self.apiManager = apiManager
    }
    
    func initRequest<T: Decodable>(with data: RequestProtocol) async throws -> T {
        let data = try await apiManager.initRequest(with: data)
        let decoded: T = try parse(data: data)
        return decoded
    }
    
    func parse<T: Decodable>(data: Data) throws -> T {
        return try jsonDecoder.decode(T.self, from: data)
    }
}
