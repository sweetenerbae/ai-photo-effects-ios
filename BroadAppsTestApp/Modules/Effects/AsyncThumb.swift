//
//  AsyncThumb.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 17.10.25.
//

import SwiftUI
import SDWebImageSwiftUI

struct AsyncThumb: View {
    let urlString: String?

    var body: some View {
        Group {
            if let assetName = urlString.flatMap(PortfolioDemoData.assetName(from:)) {
                Image(assetName)
                    .resizable()
                    .scaledToFill()
            } else if let urlString, let url = URLResolver.absolute(urlString) {
                WebImage(url: url)
                    .resizable()
                    .scaledToFill()
            } else {
                Color.gray.opacity(0.3)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.white)
                    )
            }
        }
    }
}
