//
//  WebsocketService.swift
//  BitcoinChart
//
//  Created by VinhHoang on 03/05/2023.
//

import Combine
import Foundation

final class WebsocketService: StatisticFetcher {
    
    private var webSocketTasks24h: URLSessionWebSocketTask!
    let subject = PassthroughSubject<Statistic24h, Never>()
    
    init() {
        getStatistic24h()
    }
    
    deinit {
        closeScocket()
    }
    
    func getStatistic24h() {
        guard let webSocketURL = URL(string:"wss://stream.binance.com:9443/ws/btcusdt@ticker") else { return }
        webSocketTasks24h = setupSocket(url: webSocketURL)
        listenForStatistic24h()
    }
    
    func setupSocket(url: URL) -> URLSessionWebSocketTask {
        let ws = URLSession.shared.webSocketTask(with: url)
        ws.resume()
        return ws
    }
    
    func listenForStatistic24h() {
        webSocketTasks24h.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error):
                BCLogger.log("Failed to receive message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    guard let data = text.data(using: .utf8) else { return }
                    guard let object = try? JSONDecoder().decode(Statistic24h.self, from: data) else { return }
                    self.subject.send(object)
                case .data(let data):
                    BCLogger.log("Received binary message: \(data)")
                @unknown default:
                    fatalError()
                }
            }
            self.listenForStatistic24h()
        }
    }
    
    func closeScocket() {
        webSocketTasks24h.cancel(with: .goingAway, reason: nil)
    }
}
