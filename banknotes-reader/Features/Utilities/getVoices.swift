//
//  getVoices.swift
//  banknotes-reader
//
//  Created by wanlok on 20/12/2025.
//

import AVFoundation

func getVoices(_ defaults: UserDefaults) -> [AVSpeechSynthesisVoice] {
    let language = languages[defaults.integer(forKey: "language")]
    return AVSpeechSynthesisVoice.speechVoices().filter { $0.language.hasPrefix(language.voice)}
}
