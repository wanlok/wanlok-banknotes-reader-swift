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
    private var frameDelegate: FrameCaptureDelegate?

    private let spacing: CGFloat = 32

    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imageView: UIImageView!

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
        guard amountView == nil else { return }

        let amountView = AmountView()
        amountView.translatesAutoresizingMaskIntoConstraints = false
        amountView.isAccessibilityElement = true
        amountView.currencyLabel.text = currency
        amountView.amountLabel.text = amount
        amountView.accessibilityLabel = "\(currency) \(amount)"
        self.amountView = amountView
        view.addSubview(amountView)

        NSLayoutConstraint.activate([
            amountView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: spacing),
            amountView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -spacing),
            amountView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            amountView.heightAnchor.constraint(equalTo: amountView.widthAnchor)
        ])

        UIAccessibility.post(notification: .layoutChanged, argument: amountView)
    }

    func hideAmountView() {
        guard amountView != nil else { return }
        amountView?.removeFromSuperview()
        amountView = nil
    }

    func setupCameraView(_ cameraView: UIView) {
        let session = AVCaptureSession()
        self.session = session
        session.sessionPreset = .photo

        let frameDelegate = FrameCaptureDelegate()
        frameDelegate.onFrameCaptured = { [weak self] image in
            Task { @MainActor in
                self?.imageView.image = image
            }
        }
        self.frameDelegate = frameDelegate

        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device)
        else { return }

        if session.canAddInput(input) {
            session.addInput(input)
        }

        let output = AVCaptureVideoDataOutput()
        output.alwaysDiscardsLateVideoFrames = true
        output.videoSettings = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
        ]
        output.setSampleBufferDelegate(frameDelegate, queue: DispatchQueue(label: "camera.frame.queue"))

        if session.canAddOutput(output) {
            session.addOutput(output)
        }

        Task { @MainActor in
            cameraView.layoutIfNeeded()
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = .resizeAspectFill
            previewLayer.frame = cameraView.bounds
            previewLayer.connection?.videoOrientation = .portrait
            cameraView.layer.addSublayer(previewLayer)
            self.previewLayer = previewLayer
        }

        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
    }
}
