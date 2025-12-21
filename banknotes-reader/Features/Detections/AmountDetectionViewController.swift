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
        
        let currency = slices[0].uppercased()
        let amount = "\(slices[1])"
        let localizedCurrency = if let key = currencyMapping[currency] {
            Localization.shared.get(key)
        } else {
            ""
        }
        let localizedCurrencySpeak = if let key = currencyMapping[currency] {
            Localization.shared.get("\(key)_speak")
        } else {
            ""
        }
        
        let amountView = AmountView()
        amountView.translatesAutoresizingMaskIntoConstraints = false
        amountView.isAccessibilityElement = true
        amountView.amountLabel.text = amount
        amountView.currencyLabel.text = localizedCurrency
        amountView.accessibilityLabel = "\(amount) \(localizedCurrency)"
        self.amountView = amountView
        view.addSubview(amountView)

        NSLayoutConstraint.activate([
            amountView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: spacing),
            amountView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -spacing),
            amountView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            amountView.heightAnchor.constraint(equalTo: amountView.widthAnchor)
        ])

        UIAccessibility.post(notification: .layoutChanged, argument: amountView)
        
        speak("\(amount) \(localizedCurrencySpeak)")
    }
    
    func hideAmountView() {
        guard amountView != nil else { return }
        amountView?.removeFromSuperview()
        amountView = nil
    }
    
    func speak(_ text: String) {
        guard let voice = getSelectedVoice(defaults) else {
            return
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = voice
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        synthesizer.speak(utterance)
    }
}
