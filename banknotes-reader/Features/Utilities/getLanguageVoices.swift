//
//  getLanguageVoices.swift
//  banknotes-reader
//
//  Created by wanlok on 20/12/2025.
//

import AVFoundation

func getLanguageVoices(_ defaults: UserDefaults) -> [(language: String, voices: [AVSpeechSynthesisVoice])] {
    var voices: [String: [AVSpeechSynthesisVoice]] = [:]
    let language = languages[defaults.integer(forKey: "language")]
    for voice in AVSpeechSynthesisVoice.speechVoices().filter({ $0.language.hasPrefix(language.voice)}) {
        let key = voice.language
        if voices[key] == nil {
            voices[key] = []
        }
        voices[key]?.append(voice)
    }
    for key in voices.keys {
        voices[key]?.sort { $0.name < $1.name }
    }
    return voices.map { (language: $0.key, voices: $0.value) }.sorted { $0.language < $1.language }
}
