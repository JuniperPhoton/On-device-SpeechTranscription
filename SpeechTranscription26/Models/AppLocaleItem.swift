//
//  AppLocaleItem.swift
//  SpeechTranscription26
//
//  Created by juniperphoton on 8/30/25.
//
import SwiftUI

@Observable
class AppLocaleItem: Identifiable {
    var status: AppLocaleItemStatus = .pending
    let locale: AppLocale
    
    var id: String {
        locale.identifier
    }
    
    init(locale: AppLocale) {
        self.locale = locale
    }
}
