//
//  DummyViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 26/10/2025.
//

import UIKit

class DummyViewController: UIViewController {
    var vuforiaView: VuforiaView?
    var vuforiaWorker: VuforiaWorker?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let vuforiaView = VuforiaView()
        vuforiaView.translatesAutoresizingMaskIntoConstraints = false
        self.vuforiaView = vuforiaView
        view.addSubview(vuforiaView)

        NSLayoutConstraint.activate([
            vuforiaView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            vuforiaView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            vuforiaView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            vuforiaView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
        ])
        
        vuforiaWorker = VuforiaWorker(vuforiaView: vuforiaView) { targetName in
            print("TARGET: \(targetName)")
        }
        vuforiaWorker?.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        vuforiaWorker?.stop()
        vuforiaWorker = nil
        vuforiaView?.removeFromSuperview()
        super.viewWillDisappear(animated)
    }
}
