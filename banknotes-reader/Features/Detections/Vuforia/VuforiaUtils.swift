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

private func convert(targetNames: [String], callback: (_ strings: [UnsafeMutablePointer<CChar>?], _ pointer: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?, _ count: Int32) -> Void) {
    let strings = targetNames.map { strdup($0) }
    strings.withUnsafeBufferPointer { buffer in
        callback(strings, UnsafeMutablePointer(mutating: buffer.baseAddress), Int32(buffer.count))
    }
}

private func finish(_ strings: [UnsafeMutablePointer<CChar>?]) {
    for string in strings {
        free(string)
    }
}

func startVuforia(_ viewController: UIViewController) {
    convert(targetNames: getXMLAttributeValues(fileName: "banknotesReader", elementName: "ImageTarget", attributeName: "name")) { strings, pointer, count in
        DispatchQueue.global(qos: .background).async {
            var initConfig = VuforiaInitConfig()
            initConfig.classPtr = UnsafeMutableRawPointer(Unmanaged.passUnretained(viewController).toOpaque())
            initConfig.errorCallback = errorCallback
            initConfig.initDoneCallback = initDoneCallback
            initConfig.vbRenderBackend = VuRenderVBBackendType(VU_RENDER_VB_BACKEND_METAL)
            initConfig.interfaceOrientation = getOrientation()
            initAR(initConfig, mTarget, pointer, count)
            finish(strings);
        }
    }
}
