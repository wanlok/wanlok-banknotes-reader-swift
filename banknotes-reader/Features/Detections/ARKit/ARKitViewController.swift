//
//  ARKitViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 30/11/2025.
//

import UIKit
import ARKit
import CoreData

class ARKitViewController: AmountDetectionViewController, ARSCNViewDelegate {
    
    @IBOutlet weak var arscnView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arscnView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getBanknotes() { rows in
            var detectionImages: Set<ARReferenceImage> = []
            
            for row in rows {
                guard let data = row.imageData, let cgImage = UIImage(data: data)?.cgImage else {
                    continue
                }
                let banknote = row.banknote
                let referenceImage = ARReferenceImage(cgImage, orientation: .up, physicalWidth: CGFloat(banknote.width))
                referenceImage.name = banknote.name
                detectionImages.insert(referenceImage)
            }
            
            let configuration = ARImageTrackingConfiguration()
            configuration.trackingImages = detectionImages
            configuration.maximumNumberOfTrackedImages = 1
            configuration.isAutoFocusEnabled = true
            
            self.arscnView.session.run(configuration)
            
            if rows.count == 0 {
                showEmptyDatasetAlert(self, self.defaults)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arscnView.session.pause()
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor, let name = imageAnchor.referenceImage.name else { return }
        if imageAnchor.isTracked {
            DispatchQueue.main.async {
                self.showAmountView(name)
            }
        } else {
            DispatchQueue.main.async {
                self.hideAmountView()
            }
        }
    }
}
