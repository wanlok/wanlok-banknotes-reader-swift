//
//  Localization.swift
//  banknotes-reader
//
//  Created by wanlok on 20/12/2025.
//

final class Localization {
    static let shared = Localization()
    
    let defaults = UserDefaults.standard
    
    private(set) var bundle: Bundle = .main

    func update() {
        let code = languages[defaults.integer(forKey: "language")].code
        if let path = Bundle.main.path(forResource: code, ofType: "lproj"), let bundle = Bundle(path: path) {
            self.bundle = bundle
        } else {
            self.bundle = .main
        }
    }

    func get(_ key: String) -> String {
        bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}
