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
    var webView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let url = URL(string: targetURL) else {
            return
        }
        let webView = WKWebView(frame: .zero)
        webView.navigationDelegate = self
        webView.load(URLRequest(url: url))
        self.webView = webView
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        getResult() { result in
            print(result)
        }
    }
    
    func getResult(completion: @escaping (String) -> Void) {
        webView?.evaluateJavaScript("document.body.innerText") { result, error in
            guard let result = result as? String else {
                return
            }
            print(result.count)
            if result.count == 0 || result == "[]" {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.getResult(completion: completion)
                }
            } else {
                completion(result)
            }
        }
    }
}
