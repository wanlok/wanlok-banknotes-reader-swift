//
//  ARSCNViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 26/10/2025.
//

import UIKit
import ARKit

class ARSCNViewController: CameraViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var arscnView: ARSCNView!

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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arscnView.session.pause()
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
