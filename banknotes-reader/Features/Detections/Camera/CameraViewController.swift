//
//  CameraViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 26/10/2025.
//

import UIKit
import AVFoundation

protocol ImageCapture {
    func imageCaptured(_ image: UIImage)
}

class CameraViewController: UIViewController, ImageCapture {

    private var session: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var frameDelegate: FrameCaptureDelegate?

    var image: UIImage?
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var imageView: UIImageView?

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

    func setupCameraView(_ cameraView: UIView) {
        let session = AVCaptureSession()
        self.session = session
        session.sessionPreset = .photo

        let frameDelegate = FrameCaptureDelegate()
        frameDelegate.onFrameCaptured = { [weak self] image in
            Task { @MainActor in
                self?.imageCaptured(image)
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
    
    func imageCaptured(_ image: UIImage) {
        imageView?.image = image
    }
}
