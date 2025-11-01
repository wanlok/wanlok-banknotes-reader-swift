//
//  VuforiaHelper.swift
//  banknotes-reader
//
//  Created by Robert Wan on 1/11/2025.
//
let mTarget: Int32 = 0

private let errorCallback: @convention(c) (UnsafeMutableRawPointer?, UnsafePointer<Int8>?) -> Void = { observer, errorString in
}

private let initDoneCallback: @convention(c) (UnsafeMutableRawPointer?) -> Void = { observer in
    guard let observer = observer else { return }
    let instance = Unmanaged<DummyViewController>.fromOpaque(observer).takeUnretainedValue()
    DispatchQueue.main.async {
        instance.mVuforiaView.mVuforiaStarted = startAR()
    }
}

func startVuforia(viewController: UIViewController, orientation: UIInterfaceOrientation) {
    DispatchQueue.global(qos: .background).async {
        var initConfig: VuforiaInitConfig = VuforiaInitConfig()
        initConfig.classPtr = UnsafeMutableRawPointer(Unmanaged.passUnretained(viewController).toOpaque())
        initConfig.errorCallback = errorCallback
        initConfig.initDoneCallback = initDoneCallback
        initConfig.vbRenderBackend = VuRenderVBBackendType(VU_RENDER_VB_BACKEND_METAL)
        initConfig.interfaceOrientation = orientation
        initAR(initConfig, mTarget)
    }
}


