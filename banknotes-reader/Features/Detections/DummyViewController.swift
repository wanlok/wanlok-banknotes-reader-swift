//
//  DummyViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 26/10/2025.
//

import UIKit

class DummyViewController: UIViewController {

    @IBOutlet var mVuforiaView: VuforiaView!
    
    var vuforiaWorker: VuforiaWorker?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        vuforiaWorker = VuforiaWorker(vuforiaView: mVuforiaView) { targetName in
            print("TARGET: \(targetName)")
        }
        vuforiaWorker?.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        vuforiaWorker?.stop()
        vuforiaWorker = nil
    }
}
