//
//  APIViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 24/11/2025.
//

import UIKit
import WebKit

class APIViewController: UIViewController, WKNavigationDelegate {
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
            if (result.count == 0 || result == "[]") && self.retryCount < self.retryCountThreshold {
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
}
