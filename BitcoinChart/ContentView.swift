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
    var body: some View {
        VStack {
            CandleStickChart(prices: networkManager.items)
        }
        .onAppear {
            Task {
                try await networkManager.callApiCoinData()
            }
        }
    }
 
}






struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
