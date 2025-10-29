//
//  FrameCaptureDelegate.swift
//  banknotes-reader
//
//  Created by Robert Wan on 29/10/2025.
//

import UIKit
import AVFoundation

class FrameCaptureDelegate: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    var onFrameCaptured: ((UIImage) -> Void)?
    private var lastCaptureTime = Date()
    private let captureInterval: TimeInterval = 1

    func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        let now = Date()
        guard now.timeIntervalSince(lastCaptureTime) >= captureInterval else { return }
        lastCaptureTime = now

        guard let image = imageFromSampleBuffer(sampleBuffer) else { return }
        onFrameCaptured?(image)
    }

    private func imageFromSampleBuffer(_ sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
            return UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: .right)
        }
        return nil
    }
}

