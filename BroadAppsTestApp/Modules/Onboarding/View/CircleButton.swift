//
//  CirleButton.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 10.10.25.
//

import SwiftUI

struct CircleButton: View {
    let system: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.black)
                .frame(width: 48, height: 48)
                .background(.white)
                .clipShape(Circle())
        }
    }
}
