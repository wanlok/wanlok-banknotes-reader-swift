//
//  CameraViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 26/10/2025.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {

    private var amountView: AmountView?
    private var session: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    
    let spacing: CGFloat = 32
    
    @IBOutlet weak var cameraView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session?.stopRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = cameraView.bounds
    }
    
    func showAmountView(currency: String, amount: String) {
        guard amountView == nil else {
            return
        }
        let amountView = AmountView()
        amountView.translatesAutoresizingMaskIntoConstraints = false
        amountView.isAccessibilityElement = true
        amountView.currencyLabel.text = currency
        amountView.amountLabel.text = amount
        amountView.accessibilityLabel = "\(currency) \(amount)"
        self.amountView = amountView
        view.addSubview(amountView);
        NSLayoutConstraint.activate([
            amountView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: spacing),
            amountView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -spacing),
            amountView.centerYAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.centerYAnchor),
            amountView.heightAnchor.constraint(equalTo: amountView.widthAnchor)
        ])
        UIAccessibility.post(notification: .layoutChanged, argument: amountView)
    }
    
    func hideAmountView() {
        guard amountView != nil else {
            return
        }
        amountView?.removeFromSuperview()
        amountView = nil
    }
    
    func setupCameraView(_ cameraView: UIView) {
        let session = AVCaptureSession()
        self.session = session
        DispatchQueue.global(qos: .userInitiated).async {
            guard let device = AVCaptureDevice.default(for: .video) else { return }
            do {
                let input = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(input) {
                    session.addInput(input)
                }
                DispatchQueue.main.async {
                    cameraView.layoutIfNeeded()
                    let previewLayer = AVCaptureVideoPreviewLayer(session: session)
                    previewLayer.videoGravity = .resizeAspectFill
                    previewLayer.frame = cameraView.bounds
                    previewLayer.connection?.videoOrientation = .portrait
                    self.previewLayer = previewLayer
                    cameraView.layer.addSublayer(previewLayer)
                }
                session.startRunning()
            } catch {}
        }
    }
}
