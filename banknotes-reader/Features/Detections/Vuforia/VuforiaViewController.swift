//
//  VuforiaViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 5/11/2025.
//

import UIKit

class VuforiaViewController: AmountDetectionViewController {
    var vuforiaView: VuforiaView?
    var vuforiaWorker: VuforiaWorker?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let vuforiaView = VuforiaView()
        vuforiaView.translatesAutoresizingMaskIntoConstraints = false
        vuforiaView.backgroundColor = .black
        self.vuforiaView = vuforiaView
        view.addSubview(vuforiaView)

        NSLayoutConstraint.activate([
            vuforiaView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
            vuforiaView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            vuforiaView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            vuforiaView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
        ])
        
        vuforiaWorker = VuforiaWorker(vuforiaView: vuforiaView) { targetName in
            if let targetName = targetName {
                self.showAmountView(targetName)
            } else {
                self.hideAmountView()
            }
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
