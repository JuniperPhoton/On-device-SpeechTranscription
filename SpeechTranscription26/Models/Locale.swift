//
//  Locale.swift
//  SpeechTranscription26
//
//  Created by juniperphoton on 8/27/25.
//

enum Locale: String, CaseIterable {
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
