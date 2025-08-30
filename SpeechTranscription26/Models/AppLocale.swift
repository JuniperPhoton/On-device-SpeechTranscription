//
//  Locale.swift
//  SpeechTranscription26
//
//  Created by juniperphoton on 8/27/25.
//
import Speech

enum AppLocale: String, CaseIterable {
    /// Currently supported reported by macOS 26:
    /// fr_CA"
    /// fr_CH"
    /// fr_FR"
    /// fr_BE"
    /// ko_KR"
    /// pt_BR"
    /// de_AT"
    /// de_CH"
    /// de_DE"
    /// it_CH"
    /// "it_IT"
    /// "zh_CN"
    /// "zh_TW"
    /// "es_CL"
    /// "es_MX"
    /// "es_ES"
    /// "es_US"
    /// "en_CA"
    /// "en_SG"
    /// "en_GB"
    /// "en_ZA"
    /// "en_AU"
    /// "en_US"
    /// "en_IE"
    /// "en_NZ"
    /// "en_IN"
    /// "yue_CN"
    /// "zh_HK"
    /// "ar_SA"
    /// "ja_JP"
    static func getSupportedLocales() async -> [AppLocale] {
        let supported = await SpeechTranscriber.supportedLocales
        return Self.allCases.filter { locale in
            supported.contains(where: { $0.identifier == locale.identifier })
        }
    }
    
    static func getInstalledLocales() async -> [AppLocale] {
        let installedLocales = await SpeechTranscriber.installedLocales
        return Self.allCases.filter { locale in
            installedLocales.contains(where: { $0.identifier == locale.identifier })
        }
    }
    
    case japanese = "Japanese"
    case english = "English (US)"
    case cantonese = "Cantonese"
    case simplifiedChinese = "Simplified Chinese"
    case traditionalChinese = "Traditional Chinese"
    
    nonisolated var identifier: String {
        switch self {
        case .cantonese:
            "yue_CN"
        case .japanese:
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
