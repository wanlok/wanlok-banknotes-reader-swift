//
//  getSelectedVoice.swift
//  banknotes-reader
//
//  Created by wanlok on 20/12/2025.
//

import AVFoundation

func getSelectedVoice(_ defaults: UserDefaults) -> AVSpeechSynthesisVoice? {
    var selectedVoice: AVSpeechSynthesisVoice? = nil
    let voiceIdentifier = defaults.string(forKey: "voiceIdentifier")
    let languageVoices = getLanguageVoices(defaults)
    for languageVoice in languageVoices {
        for voice in languageVoice.voices {
            if voice.identifier == voiceIdentifier {
                selectedVoice = voice
                break
            }
        }
        if selectedVoice != nil {
            break
        }
    }
    if selectedVoice == nil && languageVoices.count > 0 && languageVoices[0].voices.count > 0 {
        selectedVoice = languageVoices[0].voices[0]
    }
    return selectedVoice
}

func getSelectedRate(_ defaults: UserDefaults) -> Float {
    let selectedRate: Float
    if defaults.object(forKey: "rate") == nil {
        selectedRate = AVSpeechUtteranceDefaultSpeechRate
    } else {
        selectedRate = defaults.float(forKey: "rate")
    }
    return selectedRate
}

func getSelectedPitch(_ defaults: UserDefaults) -> Float {
    let selectedPitch: Float
    if defaults.object(forKey: "pitch") == nil {
        selectedPitch = 1.0
    } else {
        selectedPitch = defaults.float(forKey: "pitch")
    }
    return selectedPitch
}
