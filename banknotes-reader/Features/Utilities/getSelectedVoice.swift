//
//  getSelectedVoice.swift
//  banknotes-reader
//
//  Created by wanlok on 20/12/2025.
//

import AVFoundation

func getSelectedVoice(_ defaults: UserDefaults) -> AVSpeechSynthesisVoice? {
    let voiceIdentifier = defaults.string(forKey: "voiceIdentifier")
    let voices = getVoices(defaults)
    return voices.first(where: { $0.identifier == voiceIdentifier }) ?? voices.first
}
