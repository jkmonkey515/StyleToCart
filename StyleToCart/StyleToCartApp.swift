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
                .onAppear {
                    // Check for shared content when app launches
                    checkForSharedContent()
                }
        }
    }
    
    private func checkForSharedContent() {
        let appGroup = "group.com.app.StyleToCart.shared"
        
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) else {
            print("Could not access app group container")
            return
        }
        
        let sharedFileURL = containerURL.appendingPathComponent("shared_url.txt")
        
        // Check if there's a shared URL
        if FileManager.default.fileExists(atPath: sharedFileURL.path),
           let urlString = try? String(contentsOf: sharedFileURL, encoding: .utf8),
           !urlString.isEmpty {
            
            print("Found shared URL: \(urlString)")
            
            // Update state to navigate
            sharedURL = urlString
            shouldNavigateToAddItem = true
            
            // Clear the file after reading
            try? FileManager.default.removeItem(at: sharedFileURL)
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
