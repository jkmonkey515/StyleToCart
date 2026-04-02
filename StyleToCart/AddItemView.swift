//
//  AddItemView.swift
//  StyleToCart
//
//  Created by NemoClaw on 4/1/26.
//

import SwiftUI

struct AddItemView: View {
    @Environment(\.dismiss) var dismiss
    @State private var productURL: String = ""
    @State private var productName: String = ""
    @State private var notes: String = ""
    
    let initialURL: String?
    
    var body: some View {
        Form {
            Section(header: Text("Product Details")) {
                TextField("Product URL", text: $productURL)
                    .textContentType(.URL)
                    .keyboardType(.URL)
                    .autocapitalization(.none)
                
                TextField("Product Name", text: $productName)
                
                TextField("Notes", text: $notes, axis: .vertical)
                    .lineLimit(3...6)
            }
            
            Section {
                Button(action: saveItem) {
                    Text("Save Item")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                }
                .listRowBackground(Color.blue)
            }
        }
        .navigationTitle("Add Item")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let initialURL = initialURL, productURL.isEmpty {
                productURL = initialURL
            }
        }
    }
    
    private func saveItem() {
        // TODO: Implement save functionality
        print("Saving item: \(productURL)")
        dismiss()
    }
}

#Preview {
    NavigationStack {
        AddItemView(initialURL: nil)
    }
}
