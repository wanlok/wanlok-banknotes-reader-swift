//
//  DummyViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 26/10/2025.
//

import UIKit
import MetalKit

private let errorCallback: @convention(c) (UnsafeMutableRawPointer?, UnsafePointer<Int8>?) -> Void = { observer, errorString in
    // You can log or handle error here
}

private let initDoneCallback: @convention(c) (UnsafeMutableRawPointer?) -> Void = { observer in
    guard let observer = observer else { return }
    let instance = Unmanaged<DummyViewController>.fromOpaque(observer).takeUnretainedValue()
    DispatchQueue.main.async {
        instance.mVuforiaView.mVuforiaStarted = startAR()
    }
}

class DummyViewController: UIViewController {

    @IBOutlet var mVuforiaView: VuforiaView!
    var mTarget: Int32 = -1
    
    func initVuforiaAsync(orientation: UIInterfaceOrientation) {
        DispatchQueue.global(qos: .background).async {
            
            var initConfig: VuforiaInitConfig = VuforiaInitConfig()
            initConfig.classPtr = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
            initConfig.errorCallback = errorCallback
            initConfig.initDoneCallback = initDoneCallback
            initConfig.vbRenderBackend = VuRenderVBBackendType(VU_RENDER_VB_BACKEND_METAL)
            initConfig.interfaceOrientation = orientation
            
            initAR(initConfig, self.mTarget)
        }

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initVuforiaAsync(orientation: getOrientation())
        
        
    }
    
}
