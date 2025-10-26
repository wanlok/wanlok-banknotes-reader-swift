//
//  LandingViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 19/10/2025.
//

import UIKit
import ARKit

class LandingViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var arscnView: ARSCNView!

    var amountView: AmountView!
    
    let spacing: CGFloat = 32
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arscnView.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        if let referenceImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) {
            configuration.detectionImages = referenceImages
            configuration.maximumNumberOfTrackedImages = 1
        }
        arscnView.session.run(configuration)
    }
    
    func showAmountView(currency: String, amount: String) {
        guard amountView == nil else {
            return
        }
        amountView = AmountView()
        amountView.translatesAutoresizingMaskIntoConstraints = false
        amountView.currencyLabel.text = currency
        amountView.amountLabel.text = amount
        view.addSubview(amountView);
        NSLayoutConstraint.activate([
            amountView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: spacing),
            amountView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -spacing),
            amountView.centerYAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.centerYAnchor),
            amountView.heightAnchor.constraint(equalTo: amountView.widthAnchor)
        ])
    }
    
    func hideAmountView() {
        guard amountView != nil else {
            return
        }
        amountView.removeFromSuperview()
        amountView = nil
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor, let name = imageAnchor.referenceImage.name else { return }
        if imageAnchor.isTracked {
            let slices = name.split(separator: "_")
            if slices.count == 2 {
                DispatchQueue.main.async {
                    self.showAmountView(currency: "\(slices[0])", amount: "\(slices[1])")
                }
            }
        } else {
            DispatchQueue.main.async {
                self.hideAmountView()
            }
        }
    }
}
