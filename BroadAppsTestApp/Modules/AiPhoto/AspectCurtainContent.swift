//
//  AspectCurtainContent.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 12.10.25.
//

import SwiftUI

struct AspectCurtainContent: View {
    @ObservedObject var vm: AiPhotoViewModel
    private let columns = [GridItem(.flexible(), spacing: 12),
                           GridItem(.flexible(), spacing: 12)]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(AiPhotoViewModel.Aspect.allCases, id: \.self) { aspect in
                Button {
                    vm.aspect = aspect
                    vm.activeSheet = nil
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: vm.aspect == aspect ? "checkmark.square.fill" : "square")
                        Text(aspect.title).font(.system(size: 15, weight: .semibold))
                        Spacer()
                    }
                    .padding(.horizontal, 14).padding(.vertical, 12)
                    .background(Color.grayButton)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.top, 8)
    }
}
