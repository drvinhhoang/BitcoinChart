//
//  FullscreenButton.swift
//  BitcoinChart
//
//  Created by VinhHoang on 05/05/2023.
//

import SwiftUI

struct FullScreenButton: View {
    let isPortrait: Bool
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .frame(width: 30, height: 30)
                .background(Color.lightGray)
                .opacity(0.1)
            Image(systemName: isPortrait ? ImageName.fullScreenIcon : ImageName.minimizeIcon)
                .fontWeight(.bold)
                .frame(width: 25, height: 25)
        }
    }
}
