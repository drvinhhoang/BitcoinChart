//
//  ContentView.swift
//  BitcoinChart
//
//  Created by VinhHoang on 30/04/2023.
//

import SwiftUI
import Charts

struct ContentView: View {
    let networkManager = NetworkManager()
    var body: some View {
        VStack {
            
        }
        .onAppear {
            networkManager.getMockOneWeek4hIntervalData()
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
