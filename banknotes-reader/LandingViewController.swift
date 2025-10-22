//
//  LandingViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 19/10/2025.
//

import UIKit
import ARKit

class LandingViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var dummy: AmountView!
    @IBOutlet weak var arscnView: ARSCNView!
    
    var lastImageAnchor: ARImageAnchor?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
      
        dummy.amountLabel.text = "\(50)"
        dummy.currencyLabel.text = "\("AUD")"
        
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
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
//        if let lastImageAnchor = lastImageAnchor, lastImageAnchor != imageAnchor {
//            self.arscnView.session.remove(anchor: lastImageAnchor)
//        }
        print("\(imageAnchor.referenceImage.name ?? "") \(imageAnchor.isTracked)")
        lastImageAnchor = imageAnchor
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
