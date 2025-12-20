//
//  VoiceViewController.swift
//  banknotes-reader
//
//  Created by wanlok on 20/12/2025.
//

import UIKit
import AVFoundation

class VoiceViewController: SettingViewController {
    override var sections: [(title: String, rows: [SettingRow])] {
        let voiceIdentifier = defaults.string(forKey: "voiceIdentifier")
        return [
            (title: Localization.shared.get("voice_title"), rows: getVoices(defaults).enumerated().map { index, voice in
                return (
                    title: "\(voice.name) \(voice.language)",
                    subtitle: nil,
                    accessoryType: (voiceIdentifier == nil && index == 0) || voice.identifier == voiceIdentifier ? .checkmark : nil
                )
            })
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = Localization.shared.get("voice_title")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defaults.setValue(getVoices(defaults)[indexPath.row].identifier, forKey: "voiceIdentifier")
        tableView.reloadData()
    }
}
