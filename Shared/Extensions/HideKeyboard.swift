//
//  Extensions.swift
//
//  Created by Diana Kuchaeva on 10.10.25.
//
import UIKit
import SwiftUI

extension View {
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
