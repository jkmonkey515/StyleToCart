//
//  ContentView.swift
//  StyleToCart
//
//  Created by NemoClaw on 4/1/26.
//

import SwiftUI

struct ContentView: View {
    var sharedURL: String?
    var shouldNavigateToAddItem: Bool
    
    @State private var isNavigatingToAddItem = false
    
    var body: some View {
        NavigationStack {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Hello, world!")
                
                NavigationLink(destination: AddItemView(initialURL: nil)) {
                    Text("plub")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Hidden navigation link for programmatic navigation from share extension
                NavigationLink(
                    destination: AddItemView(initialURL: sharedURL),
                    isActive: $isNavigatingToAddItem
                ) {
                    EmptyView()
                }
                .hidden()
            }
            .padding()
            .navigationTitle("StyleToCart")
            .onAppear {
                if shouldNavigateToAddItem {
                    isNavigatingToAddItem = true
                }
            }
            .onChange(of: shouldNavigateToAddItem) { oldValue, newValue in
                if newValue {
                    isNavigatingToAddItem = true
                }
            }
        }
        .onAppear {
            printLog()
        }
    }
    
    func printLog() {
        print("Printing logo")
        let appGroup = "group.com.app.StyleToCart.shared"
        if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) {
            let log = try? String(contentsOf: url.appendingPathComponent("share_extension.log"))
            print(log ?? "no log")
        }
    }
}

#Preview {
    ContentView(sharedURL: "", shouldNavigateToAddItem: false)
}
