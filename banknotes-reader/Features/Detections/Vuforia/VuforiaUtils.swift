//
//  VuforiaUtils.swift
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

private func convert(fileName: String, targetNames: [String], callback: (_ cFileName: UnsafeMutablePointer<CChar>?, _ cTargetNames: [UnsafeMutablePointer<CChar>?], _ pointer: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?, _ count: Int32) -> Void) {
    let cFileName = strdup(fileName)
    let cTargetNames = targetNames.map { strdup($0) }
    cTargetNames.withUnsafeBufferPointer { buffer2 in
        callback(cFileName, cTargetNames, UnsafeMutablePointer(mutating: buffer2.baseAddress), Int32(buffer2.count))
    }
}

private func finish(_ cFileName: UnsafeMutablePointer<CChar>?, _ cTargetNames: [UnsafeMutablePointer<CChar>?]) {
    free(cFileName)
    for cTargetName in cTargetNames {
        free(cTargetName)
    }
}

func startVuforia(_ viewController: UIViewController) {
    let fileName = "banknotesReader"
    convert(fileName: fileName, targetNames: getXMLAttributeValues(fileName: fileName, elementName: "ImageTarget", attributeName: "name")) { cFileName, cTargetNames, pointer, count in
        DispatchQueue.global(qos: .background).async {
            var initConfig = VuforiaInitConfig()
            initConfig.classPtr = UnsafeMutableRawPointer(Unmanaged.passUnretained(viewController).toOpaque())
            initConfig.errorCallback = errorCallback
            initConfig.initDoneCallback = initDoneCallback
            initConfig.vbRenderBackend = VuRenderVBBackendType(VU_RENDER_VB_BACKEND_METAL)
            initConfig.interfaceOrientation = getOrientation()
            initAR(initConfig, mTarget, cFileName, pointer, count)
            finish(cFileName, cTargetNames);
        }
    }
}
