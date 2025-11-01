//
//  DummyViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 26/10/2025.
//

import UIKit

class DummyViewController: UIViewController {

    @IBOutlet var mVuforiaView: VuforiaView!

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startVuforia(self)
    }
}
