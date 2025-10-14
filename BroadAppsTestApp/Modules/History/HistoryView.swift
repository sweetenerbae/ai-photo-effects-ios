//
//  HistoryView.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 14.10.25.
//

import SwiftUI

struct HistoryView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: 24) {
                    Spacer()

                    Image(systemName: "sparkles")
                        .font(.system(size: 40, weight: .regular))
                        .foregroundStyle(Color.primaryOrange)

                    Text("It’s empty now")
                        .appFont(.title)
                        .foregroundStyle(Color.labelBlack)

                    Button {
                    } label: {
                        Text("It’s empty now")
                            .appFont(.button)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.labelBlack)
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 32)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 16)
                .background(Color.grayButton)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .padding(.horizontal, 16)
            }
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
