//
//  VuforiaWorker.swift
//  banknotes-reader
//
//  Created by Robert Wan on 1/11/2025.
//

class VuforiaWorker {
    private var viewController: UIViewController
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func start() {
        let fileName = "banknotesReader"
        convert(fileName: fileName, targetNames: getXMLAttributeValues(fileName: fileName, elementName: "ImageTarget", attributeName: "name")) { cFileName, cTargetNames, pointer, count in
            DispatchQueue.global(qos: .background).async {
                var config = VuforiaInitConfig()
                config.classPtr = UnsafeMutableRawPointer(Unmanaged.passUnretained(self.viewController).toOpaque())
                config.errorCallback = self.errorCallback
                config.initDoneCallback = self.initDoneCallback
                config.vbRenderBackend = VuRenderVBBackendType(VU_RENDER_VB_BACKEND_METAL)
                config.interfaceOrientation = getOrientation()
                initAR(config, 0, self.detectionCallback, cFileName, pointer, count)
                self.initDone(cFileName, cTargetNames);
            }
        }
    }
    
    private let initDoneCallback: @convention(c) (UnsafeMutableRawPointer?) -> Void = { observer in
        guard let observer = observer else { return }
        let instance = Unmanaged<DummyViewController>.fromOpaque(observer).takeUnretainedValue()
        DispatchQueue.main.async {
            instance.mVuforiaView.mVuforiaStarted = startAR()
        }
    }

    private let errorCallback: @convention(c) (UnsafeMutableRawPointer?, UnsafePointer<Int8>?) -> Void = { observer, errorString in
        
    }

    private func convert(fileName: String, targetNames: [String], callback: (_ cFileName: UnsafeMutablePointer<CChar>?, _ cTargetNames: [UnsafeMutablePointer<CChar>?], _ pointer: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?, _ count: Int32) -> Void) {
        let cFileName = strdup(fileName)
        let cTargetNames = targetNames.map { strdup($0) }
        cTargetNames.withUnsafeBufferPointer { buffer2 in
            callback(cFileName, cTargetNames, UnsafeMutablePointer(mutating: buffer2.baseAddress), Int32(buffer2.count))
        }
    }

    private func initDone(_ cFileName: UnsafeMutablePointer<CChar>?, _ cTargetNames: [UnsafeMutablePointer<CChar>?]) {
        free(cFileName)
        for cTargetName in cTargetNames {
            free(cTargetName)
        }
    }

    private let detectionCallback: @convention(c) (UnsafePointer<CChar>?) -> Void = { targetName in
        if let targetName = targetName {
            print("Found: \(String(cString: targetName))")
        }
    }
}
