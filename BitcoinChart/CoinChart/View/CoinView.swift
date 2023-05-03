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
    @State private var isPortrait = true
    var body: some View {
        GeometryReader { proxy in
            VStack {
                if isPortrait {
                    VStack {
                        HStack {
                            Text("BTC/USDT")
                                .fontWeight(.bold)
                                .font(.largeTitle)
                        }
                        .padding(.top, 20)
                        HStack {
                            currentPrice
                            Spacer()
                            statisticView
                                .frame(maxWidth: 200)
                        }
                        .frame(maxWidth: .infinity, maxHeight: proxy.size.width * 0.6)
                        .padding(.horizontal)
                    }
                    ChooseIntervalView(selectedRange: $vm.selectedRange)
                }
                CandleStickChart(chartData: vm.chartData)
                    .frame(width: proxy.size.width)
                    .frame(maxHeight: proxy.size.height * (isPortrait ? 0.5 : 1))
            }
            .padding(.horizontal)
        }
        .onAppear {
            Task {
                await vm.fetchCoinKlineData()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            guard let scene = UIApplication.shared.windows.first?.windowScene else { return }
            self.isPortrait = scene.interfaceOrientation.isPortrait
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
        HStack(spacing: 20) {
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
        VStack(alignment: .leading, spacing: 8) {
            Text(title ?? "")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            Text(value ?? "")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CoinView()
            .previewDevice("iPhone 8")
    }
}
