//
//  ContentView.swift
//  BitcoinChart
//
//  Created by VinhHoang on 30/04/2023.
//

import SwiftUI
import Charts

struct CoinView: View {
    @StateObject var vm = CoinViewModel(coinFetcher: CoinService(requestManager: RequestManager()))
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
                ChooseIntervalView(selectedRange: $vm.selectedRange)
                ScrollView(.horizontal) {
                    CandleStickChart(prices: vm.chartData?.items ?? [], candleWidth: vm.selectedRange.candleWidth, bound: vm.chartData?.bounds ?? 0...10000)
                        .frame(width:  proxy.size.width, height: proxy.size.height * 0.4)
                }
            }
        }
        .onAppear {
            Task {
                 await vm.fetchCoinKlineData()
            }
        }
    }
    
    private var currentPrice: some View {
        HStack {
            Text(Double(vm.currentPrice)?.asNumberWith2Decimals() ?? "")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.green)
            Text(vm.priceChangePercent.asPercentString())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(vm.priceChangePercent.asNumberString() >= "0" ? .green : .red)
        }
    }
    
    private var statisticView: some View {
        HStack {
            VStack(spacing: 12) {
                priceView(title: "24h High", value: vm.statistic24h?.formattedHigh)
                priceView(title: "24h Low", value: vm.statistic24h?.formattedLow)
            }
            VStack(spacing: 12) {
                priceView(title: "24h Vol(BTC)", value: vm.statistic24h?.formattedBaseVolume)
                priceView(title: "24h Vol(BTC)", value: vm.statistic24h?.formattedQuoteVolume)
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
        CoinView()
    }
}
