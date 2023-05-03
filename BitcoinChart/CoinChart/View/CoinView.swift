//
//  ContentView.swift
//  BitcoinChart
//
//  Created by VinhHoang on 30/04/2023.
//

import SwiftUI
import Charts

struct CoinView: View {
    @StateObject var vm = CoinViewModel(
        coinFetcher: CoinService(requestManager: RequestManager()),
        statisticFetcher: WebsocketService(),
        coinPersistence: CoinPersistenceService()
    )
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
                                .frame(maxWidth: proxy.size.width * 0.5)
                            Spacer()
                            statisticView
                                .frame(maxWidth: proxy.size.width * 0.5)
                        }
                        .frame(maxWidth: .infinity, maxHeight: proxy.size.width * 0.6)
                        .padding(.horizontal)
                    }
                    ChooseIntervalView(selectedRange: $vm.selectedRange.animation(.easeInOut))
                }
                CandleStickChart(chartData: vm.chartData)
                    .frame(width: proxy.size.width)
                    .frame(maxHeight: proxy.size.height * (isPortrait ? 0.5 : 1))
            }
        }
        .ignoresSafeArea(edges: .horizontal)
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
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CoinView()
            .previewDevice("iPhone 8")
    }
}

// MARK: - Views

extension CoinView {
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
