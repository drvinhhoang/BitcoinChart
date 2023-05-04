//
//  ContentView.swift
//  BitcoinChart
//
//  Created by VinhHoang on 30/04/2023.
//

import SwiftUI
import Charts

struct CoinView: View {
    @Environment(\.sizeCategory) var sizeCategory
    @StateObject var vm = CoinViewModel(
        coinFetcher: CoinService(requestManager: RequestManager()),
        statisticFetcher: WebsocketService(),
        coinPersistence: CoinPersistenceService()
    )
    
    var isPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
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
                        .padding(.top, 50)
                        HStack(alignment: .center, spacing: isPad ? 40 : 20) {
                            currentPrice
                                .frame(maxWidth: proxy.size.width * 0.5)
                            statisticView
                                .frame(maxWidth: proxy.size.width * 0.5)
                        }
                        .frame(maxHeight: proxy.size.height * 0.6)
                    }
                    ChooseIntervalView(selectedRange: $vm.selectedRange.animation(.easeInOut))
                }
                CandleStickChart(chartData: vm.chartData, isLoading: vm.isLoading)
                    .padding()
                    .frame(width: proxy.size.width, height: proxy.size.height * (isPortrait ? 0.5 : 1))
                    .overlay(
                        FullScreenButton(isPortrait: isPortrait)
                            .offset(x: 40, y: -40)
                            .onTapGesture(perform: {
                                isPortrait.toggle()
                                changeOrientation(to: isPortrait ? .portrait : .landscape)
                            })
                        , alignment: .bottomLeading
                    )
            }
        }
        .onAppear {
            Task {
                await vm.showLoading(true)
                await vm.fetchCoinKlineData()
                await vm.showLoading(false)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
            guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            self.isPortrait = scene.interfaceOrientation.isPortrait
        }
    }
    
    private func changeOrientation(to orientation: UIInterfaceOrientationMask) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return
        }
        scene.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
    }
    
    private func getSize() -> CGFloat {
        switch sizeCategory {
        case .extraSmall:
            return 16
        case .small:
            return 18
        case .medium:
            return 20
        case .large:
            return 22
        case .extraLarge:
            return 24
        case .extraExtraLarge:
            return 26
        case .extraExtraExtraLarge:
            return 28
        default:
            return 20
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        CoinView()
    }
}

// MARK: - Views

extension CoinView {
    private var currentPrice: some View {
        HStack {
            Text(Double(vm.currentPrice)?.asNumberWith2Decimals() ?? "")
                .font(isPad ? .system(size: getSize()) : .title2)
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
                priceView(title: "24h Vol(USDT)", value: vm.statistic24h?.formattedQuoteVolume)
            }
        }
    }
    
    @ViewBuilder
    private func priceView(title: String?, value: String?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title ?? "")
                .font(isPad ? .system(size: getSize()) : .caption)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            Text(value ?? "")
                .font(isPad ? .system(size: getSize()) : .caption)
                .fontWeight(.semibold)
                .foregroundColor(.black)
        }
    }
}
