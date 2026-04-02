//
//  ShareViewController.swift
//  StyleToCart Share Extension
//
//  Created by NemoClaw on 4/1/26.
//

import UIKit
import Social
import UniformTypeIdentifiers

class ShareViewController: SLComposeServiceViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Customize the placeholder text
        placeholder = "Add a comment (optional)"
    }
    
    override func isContentValid() -> Bool {
        // Always valid - we just need the URL
        return true
    }
    
    override func didSelectPost() {
        // This is called when the user taps "Post"
        handleSharedContent()
    }
    
    override func didSelectCancel() {
        super.didSelectCancel()
        closeExtension()
    }
    
    private func handleSharedContent() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = extensionItem.attachments?.first else {
            closeExtension()
            return
        }
        
        // Check for URL
        if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            itemProvider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] (item, error) in
                guard let url = item as? URL else {
                    self?.closeExtension()
                    return
                }
                
                DispatchQueue.main.async {
                    self?.openMainApp(with: url.absoluteString)
                }
            }
        } else if itemProvider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
            itemProvider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { [weak self] (item, error) in
                guard let urlString = item as? String else {
                    self?.closeExtension()
                    return
                }
                
                DispatchQueue.main.async {
                    self?.openMainApp(with: urlString)
                }
            }
        } else {
            closeExtension()
        }
    }
    
    private func openMainApp(with urlString: String) {
        // Save the URL to App Group shared storage
        let appGroup = "group.com.app.StyleToCart.shared"
        
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroup) {
            let sharedURL = containerURL.appendingPathComponent("shared_url.txt")
            
            do {
                try urlString.write(to: sharedURL, atomically: true, encoding: .utf8)
                
                // Log for debugging
                let logURL = containerURL.appendingPathComponent("share_extension.log")
                let logMessage = "Shared URL saved: \(urlString) at \(Date())\n"
                try logMessage.write(to: logURL, atomically: true, encoding: .utf8)
                
                // Try to open the main app using URL scheme
                let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
                if let appURL = URL(string: "styletocart://additem?url=\(encodedURL)") {
                    // Attempt to open - this may or may not work depending on iOS version
                    // The shared file will ensure data is available regardless
                    var openedSuccessfully = false
                    
                    // Try the modern approach first
                    if #available(iOS 13.0, *) {
                        self.extensionContext?.open(appURL, completionHandler: { [weak self] success in
                            openedSuccessfully = success
                            print("Extension context open result: \(success)")
                            self?.closeExtensionWithDelay()
                        })
                    }
                    
                    // If the above didn't work, just close
                    if !openedSuccessfully {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                            self?.closeExtension()
                        }
                    }
                } else {
                    closeExtension()
                }
            } catch {
                print("Error saving shared URL: \(error)")
                closeExtension()
            }
        } else {
            print("Could not access app group container")
            closeExtension()
        }
    }
    
    private func closeExtensionWithDelay() {
        // Small delay to ensure the transition happens smoothly
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            self?.closeExtension()
        }
    }
    
    private func closeExtension() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    override func configurationItems() -> [Any]! {
        // You can add configuration items here if needed
        return []
    }
}
