//
//  View+DeleteAlert.swift
//  BroadAppsTestApp
//
//  Created by Diana Kuchaeva on 19.10.25.
//

import SwiftUI

extension View {
    func deleteAlert(
        isPresented: Binding<Bool>,
        itemName: String = "item",
        onDelete: @escaping () -> Void,
    ) -> some View {
        self.alert("Delete \(itemName)", isPresented: isPresented) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive, action: onDelete)
        } message: {
            Text("This action cannot be undone.")
        }
    }

    func deleteAlert<T: Identifiable>(
        item: Binding<T?>,
        itemName: String = "item",
        onDelete: @escaping (T) -> Void,
        onDismiss: (() -> Void)? = nil
    ) -> some View {
        self.alert("Delete \(itemName)", isPresented: Binding<Bool>(
            get: { item.wrappedValue != nil },
            set: { if !$0 { item.wrappedValue = nil } }
        )) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                if let itemToDelete = item.wrappedValue {
                    onDelete(itemToDelete)
                    onDismiss?()
                }
            }
        } message: {
            Text("This action cannot be undone.")
        }
    }
}
