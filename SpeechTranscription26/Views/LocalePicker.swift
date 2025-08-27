//
//  LocalePicker.swift
//  SpeechTranscription26
//
//  Created by juniperphoton on 8/28/25.
//
import SwiftUI

struct LocalePicker: View {
    @AppStorage(AppStorageKeys.locale.rawValue)
    private var locale: Locale = .english
    
    var body: some View {
        Picker("Locale", selection: $locale) {
            ForEach(Locale.allCases, id: \.self) { locale in
                Text(locale.rawValue)
                    .tag(locale)
            }
        }
    }
}
