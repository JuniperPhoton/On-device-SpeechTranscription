//
//  Locale.swift
//  SpeechTranscription26
//
//  Created by juniperphoton on 8/27/25.
//
import Speech

enum AppLocale: String, CaseIterable {
    static func getSupportedLocales() async -> [AppLocale] {
        // TODO: Build the settings page download the language models if not present.
        await SpeechTranscriber.supportedLocales.compactMap { localeIdentifier in
            Self.allCases.first { $0.identifier == localeIdentifier.identifier }
        }
    }
    
    case japaenese = "Japanese"
    case english = "English"
    case simplifiedChinese = "Simplified Chinese"
    case traditionalChinese = "Traditional Chinese"
    
    nonisolated var identifier: String {
        switch self {
        case .japaenese:
            "ja_JP"
        case .english:
            "en_US"
        case .simplifiedChinese:
            "zh_CN"
        case .traditionalChinese:
            "zh_HK"
        }
    }
}
