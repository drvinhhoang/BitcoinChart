//
//  ContentView.swift
//  BitcoinChart
//
//  Created by VinhHoang on 30/04/2023.
//

import SwiftUI
import Charts

struct ContentView: View {
    @StateObject var networkManager = NetworkManager()
    //    @StateObject var ws = WebSocket()
    var body: some View {
        GeometryReader { proxy in
            
            VStack {
                VStack {
                    HStack {
                        Text("BTC/USDT")
                            .fontWeight(.bold)
                            .font(.headline)
                    }
                    HStack {
                        currentPrice
                        Spacer()
                        statisticView
                            .frame(maxWidth: 200)
                    }
                    .frame(maxWidth: .infinity, maxHeight: 300)
                    .padding(.horizontal)
                }
                ChooseIntervalView(selectedRange: $networkManager.selectedRange)
                ScrollView(.horizontal) {
                    CandleStickChart(prices: networkManager.chartData?.items ?? [], candleWidth: networkManager.selectedRange.candleWidth, bound: networkManager.chartData?.bounds ?? 0...10000)
                        .frame(width:  proxy.size.width, height: proxy.size.height * 0.4)
                }
            }
        }
        .onAppear {
            Task {
                try await networkManager.callApiCoinData()
                
            }
        }
    }
    
    private var currentPrice: some View {
        HStack {
            Text(Double(networkManager.currentPrice)?.asNumberWith2Decimals() ?? "")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.green)
            Text(networkManager.change.asPercentString())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(networkManager.change.asNumberString() >= "0" ? .green : .red)
        }
    }
    
    private var statisticView: some View {
        HStack {
            VStack(spacing: 12) {
                priceView(title: "24h High", value: networkManager.statistic24h?.formattedHigh)
                priceView(title: "24h Low", value: networkManager.statistic24h?.formattedLow)
            }
            VStack(spacing: 12) {
                priceView(title: "24h Vol(BTC)", value: networkManager.statistic24h?.formattedBaseVolume)
                priceView(title: "24h Vol(BTC)", value: networkManager.statistic24h?.formattedQuoteVolume)
            }
        }
    }
    
    @ViewBuilder
    func priceView(title: String?, value: String?) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title ?? "")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            Text(value ?? "")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.black)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
