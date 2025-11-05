//
//  AmountDetectionViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 30/10/2025.
//

import UIKit

class AmountDetectionViewController: UIViewController {

    private var amountView: AmountView?
    
    private let spacing: CGFloat = 32
    
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
        
        let currency = "\(slices[0])"
        let amount = "\(slices[1])"
        
        let amountView = AmountView()
        amountView.translatesAutoresizingMaskIntoConstraints = false
        amountView.isAccessibilityElement = true
        amountView.currencyLabel.text = currency
        amountView.amountLabel.text = amount
        amountView.accessibilityLabel = "\(currency) \(amount)"
        self.amountView = amountView
        view.addSubview(amountView)

        NSLayoutConstraint.activate([
            amountView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: spacing),
            amountView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -spacing),
            amountView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            amountView.heightAnchor.constraint(equalTo: amountView.widthAnchor)
        ])

        UIAccessibility.post(notification: .layoutChanged, argument: amountView)
    }

    func hideAmountView() {
        guard amountView != nil else { return }
        amountView?.removeFromSuperview()
        amountView = nil
    }

}
