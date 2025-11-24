//
//  SyncViewController.swift
//  banknotes-reader
//
//  Created by wanlok on 8/11/2025.
//

import UIKit

class SyncViewController: APIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        get("https://wanlok.github.io/#/api/banknotes") { result in
            print(result)
        }
    }
}
