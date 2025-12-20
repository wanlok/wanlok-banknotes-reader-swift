//
//  getSelectedVoice.swift
//  banknotes-reader
//
//  Created by wanlok on 20/12/2025.
//

import AVFoundation

func getSelectedVoice(_ defaults: UserDefaults) -> AVSpeechSynthesisVoice? {
    var target: AVSpeechSynthesisVoice? = nil
    let voiceIdentifier = defaults.string(forKey: "voiceIdentifier")
    let languageVoices = getLanguageVoices(defaults)
    for languageVoice in languageVoices {
        for voice in languageVoice.voices {
            if voice.identifier == voiceIdentifier {
                target = voice
                break
            }
        }
        if target != nil {
            break
        }
    }
    if target == nil && languageVoices.count > 0 && languageVoices[0].voices.count > 0 {
        target = languageVoices[0].voices[0]
    }
    return target
}
