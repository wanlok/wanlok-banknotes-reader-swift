//
//  VuforiaWorker.swift
//  banknotes-reader
//
//  Created by Robert Wan on 1/11/2025.
//

private func convert(fileName: String, targetNames: [String], callback: (_ cFileName: UnsafeMutablePointer<CChar>?, _ cTargetNames: [UnsafeMutablePointer<CChar>?], _ pointer: UnsafeMutablePointer<UnsafeMutablePointer<CChar>?>?, _ count: Int32) -> Void) {
    let cFileName = strdup(fileName)
    let cTargetNames = targetNames.map { strdup($0) }
    cTargetNames.withUnsafeBufferPointer { pointer in
        callback(cFileName, cTargetNames, UnsafeMutablePointer(mutating: pointer.baseAddress), Int32(pointer.count))
    }
}

class VuforiaWorker {
    private let vuforiaView: VuforiaView
    private let callback: (String?) -> Void
    
    init(vuforiaView: VuforiaView, callback: @escaping (String?) -> Void) {
        self.vuforiaView = vuforiaView
        self.callback = callback
    }

    func start() {
        let (filePath, _) = getVuforiaDatasetFilePaths()
        let targetNames = getXMLAttributeValues(filePath: filePath, elementName: "ImageTarget", attributeName: "name")
        convert(fileName: vuforiaDatasetFileName, targetNames: targetNames) { cFileName, cTargetNames, pointer, count in
            DispatchQueue.global(qos: .background).async {
                var config = VuforiaInitConfig()
                config.classPtr = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
                config.errorCallback = self.errorCallback
                config.initDoneCallback = self.initDoneCallback
                config.detectionCallback = self.detectionCallback
                config.vbRenderBackend = VuRenderVBBackendType(VU_RENDER_VB_BACKEND_METAL)
                config.interfaceOrientation = getOrientation()
                
                initAR(config, 0, cFileName, pointer, count)
                
                self.initDone(cFileName, cTargetNames)
            }
        }
    }
    
    func stop() {
        vuforiaView.finish()
        stopAR()
        deinitAR()
    }
    
    private func initDone(_ cFileName: UnsafeMutablePointer<CChar>?, _ cTargetNames: [UnsafeMutablePointer<CChar>?]) {
        free(cFileName)
        for cTargetName in cTargetNames {
            free(cTargetName)
        }
    }
    
    private let initDoneCallback: @convention(c) (UnsafeMutableRawPointer?) -> Void = { observer in
        guard let observer = observer else {
            return
        }
        let instance = Unmanaged<VuforiaWorker>.fromOpaque(observer).takeUnretainedValue()
        DispatchQueue.main.async {
            instance.vuforiaView.mVuforiaStarted = startAR()
        }
    }

    private let errorCallback: @convention(c) (UnsafeMutableRawPointer?, UnsafePointer<Int8>?) -> Void = { observer, errorString in
        
    }

    private let detectionCallback: @convention(c) (UnsafeMutableRawPointer?, UnsafePointer<CChar>?) -> Void = { observer, targetName in
        guard let observer = observer else {
            return
        }
        let instance = Unmanaged<VuforiaWorker>.fromOpaque(observer).takeUnretainedValue()
        if let targetName = targetName {
            DispatchQueue.main.async {
                instance.callback(String(cString: targetName))
            }
        } else {
            DispatchQueue.main.async {
                instance.callback(nil)
            }
        }
    }
}
