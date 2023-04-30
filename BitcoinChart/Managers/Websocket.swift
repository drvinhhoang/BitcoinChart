//
//  Websocket.swift
//  BitcoinChart
//
//  Created by VinhHoang on 30/04/2023.
//

import Foundation

class WebSocket: ObservableObject {
    @Published var messages: [String] = []
    private var webSocketTask: URLSessionWebSocketTask!
    
    init() {
        setupSocket()
    }
    
    func setupSocket() {
        let webSocketURL = URL(string: "wss://stream.binance.com:9443/ws/btcusdt@kline_1m")!
        webSocketTask = URLSession.shared.webSocketTask(with: webSocketURL)
        listenForMessage()
        webSocketTask.resume()
    }
    
    func listenForMessage() {
        webSocketTask.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .failure(let error):
                print("Failed to receive message: \(error)")
            case .success(let message):
                switch message {
                case .string(let text):
                    let data = text.data(using: .utf8)
                    let object = try? JSONDecoder().decode(Coin.self, from: data!)
                    let mess = "\(object!)"
                    self.messages.insert(mess, at: 0)
                case .data(let data):
                    print("Received binary message: \(data)")
                @unknown default:
                    fatalError()
                }
                self.listenForMessage()
            }
        }
    }
    
    func closeScocket() {
        webSocketTask.cancel(with: .goingAway, reason: nil)
        messages = []
    }
}
