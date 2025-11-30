//
//  NetworkViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 24/11/2025.
//

import UIKit
import WebKit

class NetworkViewController: UIViewController, WKNavigationDelegate {
    var webView = WKWebView(frame: .zero)
    var getCompletion: ((String) -> Void)?
    var retryCount = 0
    let retryCountThreshold = 10
    let retryInterval = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        retryCount = retryCount + 1
        getResult() { result in
            self.getCompletion?(result)
        }
    }
    
    func getResult(completion: @escaping (String) -> Void) {
        webView.evaluateJavaScript("document.body.innerText") { result, error in
            guard let result = result as? String else {
                return
            }
            if (result.count == 0 || result == "[]" || result == "{}") && self.retryCount < self.retryCountThreshold {
                DispatchQueue.main.asyncAfter(deadline: .now() + self.retryInterval) {
                    self.retryCount = self.retryCount + 1
                    self.getResult(completion: completion)
                }
            } else {
                completion(result)
            }
        }
    }
    
    func get(_ urlString: String, completion: @escaping (String) -> Void) {
        guard let url = URL(string: urlString) else {
            return
        }
        getCompletion = completion
        retryCount = 0
        webView.load(URLRequest(url: url))
    }
    
    func downloadFiles(_ rows: [(url: String, filePath: URL)], _ completion: @escaping () -> Void) {
        let group = DispatchGroup()
                
        func download(url: String, toFilePath: URL) {
            guard let url = URL(string: url) else {
                return
            }
            group.enter()
            URLSession.shared.downloadTask(with: url) { filePath, _, _ in
                if let filePath = filePath {
                    try? FileManager.default.removeItem(at: toFilePath)
                    try? FileManager.default.moveItem(at: filePath, to: toFilePath)
                }
                group.leave()
            }.resume()
        }
        
        for (url, filePath) in rows {
            download(url: url, toFilePath: filePath)
        }
        
        group.notify(queue: .main) {
            completion()
        }
    }
}
