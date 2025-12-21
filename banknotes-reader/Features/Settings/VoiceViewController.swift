//
//  VoiceViewController.swift
//  banknotes-reader
//
//  Created by wanlok on 20/12/2025.
//

import UIKit
import AVFoundation

class VoiceViewController: SettingViewController {
    var languageVoices: [(language: String, voices: [AVSpeechSynthesisVoice])] = []
    
    override var sections: [(title: String, rows: [SettingRow])] {
        let voiceIdentifier = defaults.string(forKey: "voiceIdentifier")
        return languageVoices.enumerated().map { i, languageVoice in
            return (
                title: getCountryName(languageVoice.language),
                rows: languageVoice.voices.enumerated().map { j, voice in
                    return (
                        title: voice.name,
                        subtitle: "\(voice.gender.rawValue)",
                        accessoryType: (voiceIdentifier == nil && i == 0 && j == 0) || voice.identifier == voiceIdentifier ? .checkmark : nil
                    )
                }
            )
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = Localization.shared.get("voice_title")
        languageVoices = getLanguageVoices(defaults)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let voiceIdentifier = languageVoices[indexPath.section].voices[indexPath.row].identifier
        defaults.setValue(voiceIdentifier, forKey: "voiceIdentifier")
        tableView.reloadData()
    }
    
    func getCountryName(_ language: String) -> String {
        let locale = Locale(identifier: language)
        let translateLocale = Locale(identifier: languages[defaults.integer(forKey: "language")].code)
        guard let regionCode = locale.regionCode, let countryName = translateLocale.localizedString(forRegionCode: regionCode) else {
            return language
        }
        return countryName
    }
}
