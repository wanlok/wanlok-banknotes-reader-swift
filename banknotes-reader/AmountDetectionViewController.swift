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
    
    func showAmountView(currency: String, amount: String) {
        guard amountView == nil else { return }

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
