//
//  VuforiaDatasetViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 29/11/2025.
//

import UIKit

class VuforiaDatasetViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Sync",
            style: .plain,
            target: self,
            action: #selector(onSyncButtonClicked)
        )
        
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let xmlFile = documents.appendingPathComponent("banknotesReader.xml")
        let datFile = documents.appendingPathComponent("banknotesReader.dat")
        
        if FileManager.default.fileExists(atPath: xmlFile.path),
           FileManager.default.fileExists(atPath: datFile.path) {
            
        } else {
            
        }
    }
    
    @objc private func onSyncButtonClicked() {
        print("onSyncButtonClicked")
        downloadVuforiaDatabase() { savedXML, savedDAT in
            print(savedXML, savedDAT)
        }
    }
    
    func downloadVuforiaDatabase(completion: @escaping (URL?, URL?) -> Void) {
        let xmlURL = URL(string: "https://wanlok.github.io/banknotesReader.xml")!
        let datURL = URL(string: "https://wanlok.github.io/banknotesReader.dat")!
        
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!

        let xmlFile = documents.appendingPathComponent("banknotesReader.xml")
        let datFile = documents.appendingPathComponent("banknotesReader.dat")
        
        let group = DispatchGroup()
        
        var savedXML: URL? = nil
        var savedDAT: URL? = nil
        
        func download(_ from: URL, to: URL, assign: @escaping (URL)->Void) {
            group.enter()
            URLSession.shared.downloadTask(with: from) { tmp, _, _ in
                if let tmp = tmp {
                    try? FileManager.default.removeItem(at: to)
                    try? FileManager.default.moveItem(at: tmp, to: to)
                    assign(to)
                }
                group.leave()
            }.resume()
        }
        
        download(xmlURL, to: xmlFile) { savedXML = $0 }
        download(datURL, to: datFile) { savedDAT = $0 }
        
        group.notify(queue: .main) {
            completion(savedXML, savedDAT)
        }
    }
}
