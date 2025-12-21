//
//  AmountDetectionViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 30/10/2025.
//

import UIKit
import AVFoundation

class AmountDetectionViewController: UIViewController {

    private var amountView: AmountView?
    
    private let spacing: CGFloat = 32
    
    let defaults = UserDefaults.standard
    
    let synthesizer = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showAmountView(_ name: String) {
        guard amountView == nil else {
            return
        }
        
        let slices = name.split(separator: "_")
        
        guard slices.count == 2 else {
            return
        }
        
        let currency = getLocalizedCurrency(slices[0].uppercased())
        let amount = "\(slices[1])"
        
        let amountView = AmountView()
        amountView.translatesAutoresizingMaskIntoConstraints = false
        amountView.isAccessibilityElement = true
        amountView.amountLabel.text = amount
        amountView.currencyLabel.text = currency
        amountView.accessibilityLabel = "\(amount) \(currency)"
        self.amountView = amountView
        view.addSubview(amountView)

        NSLayoutConstraint.activate([
            amountView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: spacing),
            amountView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -spacing),
            amountView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            amountView.heightAnchor.constraint(equalTo: amountView.widthAnchor)
        ])

        UIAccessibility.post(notification: .layoutChanged, argument: amountView)
        
        speak("\(amount) \(currency)")
    }
    
    func hideAmountView() {
        guard amountView != nil else { return }
        amountView?.removeFromSuperview()
        amountView = nil
    }
    
    func getLocalizedCurrency(_ currencyCode: String) -> String {
        let code = languages[defaults.integer(forKey: "language")].code
        let translateLocale = Locale(identifier: code)
        return if code == "en" {
            currencyCode
        } else {
            translateLocale.localizedString(forCurrencyCode: currencyCode) ?? currencyCode
        }
    }
    
    func speak(_ text: String) {
        guard let voice = getSelectedVoice(defaults) else {
            return
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice
        utterance.rate = getSelectedRate(defaults)
        utterance.pitchMultiplier = getSelectedPitch(defaults)
        utterance.volume = 1.0
        synthesizer.speak(utterance)
    }
}
