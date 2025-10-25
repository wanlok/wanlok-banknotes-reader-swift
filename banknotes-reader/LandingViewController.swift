//
//  LandingViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 19/10/2025.
//

import UIKit
import ARKit

class LandingViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var amountView: AmountView!
    @IBOutlet weak var arscnView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arscnView.delegate = self
        amountView.isHidden = true
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
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor, let name = imageAnchor.referenceImage.name else { return }
        DispatchQueue.main.async {
            self.amountView.amountLabel.text = "\(name)"
            self.amountView.currencyLabel.text = "\("AUD")"
            self.amountView.isHidden = !imageAnchor.isTracked
        }
    }
}
