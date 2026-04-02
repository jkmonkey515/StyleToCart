//
//  StyleToCartApp.swift
//  StyleToCart
//
//  Created by NemoClaw on 4/1/26.
//

import SwiftUI

@main
struct StyleToCartApp: App {
    @State private var sharedURL: String?
    @State private var shouldNavigateToAddItem = false
    
    var body: some Scene {
        WindowGroup {
            ContentView(sharedURL: sharedURL, shouldNavigateToAddItem: shouldNavigateToAddItem)
                .onOpenURL { url in
                    handleIncomingURL(url)
                }
        }
    }
    
    private func handleIncomingURL(_ url: URL) {
        // Handle custom URL scheme: styletocart://additem?url=<encoded_url>
        guard url.scheme == "styletocart",
              url.host == "additem" else {
            return
        }
        
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let urlQueryItem = components.queryItems?.first(where: { $0.name == "url" }),
           let sharedURLString = urlQueryItem.value?.removingPercentEncoding {
            sharedURL = sharedURLString
            shouldNavigateToAddItem = true
        }
    }
}
