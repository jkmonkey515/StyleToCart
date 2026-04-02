//
//  ShareViewController.swift
//  ShareExtension
//
//  Created by NemoClaw on 4/1/26.
//

//import UIKit
//import Social
//
//class ShareViewController: SLComposeServiceViewController {
//
//    override func isContentValid() -> Bool {
//        // Do validation of contentText and/or NSExtensionContext attachments here
//        return true
//    }
//
//    override func didSelectPost() {
//        // This is called after the user selects Post. Do the upload of contentText and/or NSExtensionContext attachments.
//    
//        // Inform the host that we're done, so it un-blocks its UI. Note: Alternatively you could call super's -didSelectPost, which will similarly complete the extension context.
//        self.extensionContext!.completeRequest(returningItems: [], completionHandler: nil)
//    }
//
//    override func configurationItems() -> [Any]! {
//        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
//        return []
//    }
//
//}


//
//  ShareViewController.swift
//  StyleToCart Share Extension
//
//  Created by NemoClaw on 4/1/26.
//

import UIKit
import Social
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .red
        handleSharedContent()
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
        // Encode the URL to pass it to the main app
        let encodedURL = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Create a custom URL scheme to open the main app
        // Format: styletocart://additem?url=<encoded_url>
        if let appURL = URL(string: "styletocart://additem?url=\(encodedURL)") {
            // Try to open the main app
            var responder: UIResponder? = self
            while responder != nil {
                if let application = responder as? UIApplication {
                    application.perform(#selector(openURL(_:)), with: appURL)
                    break
                }
                responder = responder?.next
            }
            
            // Alternative method for iOS 13+
            self.extensionContext?.open(appURL, completionHandler: { [weak self] success in
                self?.closeExtension()
            })
        } else {
            closeExtension()
        }
    }
    
    @objc private func openURL(_ url: URL) {
        // This method is called via perform selector
    }
    
    private func closeExtension() {
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
}
