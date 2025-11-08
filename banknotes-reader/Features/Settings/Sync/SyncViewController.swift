//
//  SyncViewController.swift
//  banknotes-reader
//
//  Created by wanlok on 8/11/2025.
//

import UIKit
import WebKit

class SyncViewController: UIViewController, WKNavigationDelegate {
    let targetURL = "https://wanlok.github.io/#/api/banknotes"
    var webView = WKWebView(frame: .zero)
    var retryCount = 0
    let retryCountThreshold = 10
    let retryInterval = 0.5
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = URL(string: targetURL) else {
            return
        }
        webView.navigationDelegate = self
        webView.load(URLRequest(url: url))
        retryCount = 0
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        retryCount = retryCount + 1
        getResult() { result in
            print(self.retryCount)
            print(result)
        }
    }
    
    func getResult(completion: @escaping (String) -> Void) {
        webView.evaluateJavaScript("document.body.innerText") { result, error in
            guard let result = result as? String else {
                return
            }
            print(result.count)
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
}
