//
//  LocalePicker.swift
//  SpeechTranscription26
//
//  Created by juniperphoton on 8/28/25.
//
import SwiftUI

struct LocalePicker: View {
    @Environment(AppLocalesModel.self) private var localesModel
    @Environment(\.openSettings) private var openSettings
    
    @AppStorage(AppStorageKeys.locale.rawValue)
    private var locale: AppLocale = .english
    
    var body: some View {
        Menu {
            ForEach(localesModel.localeItems.map { $0.locale }, id: \.self) { locale in
                Button {
                    withAnimation {
                        self.locale = locale
                    }
                } label: {
                    Text(locale.rawValue)
                    if locale == self.locale {
                        Image(systemName: "checkmark")
                    }
                }
            }
            
            Divider()
            
            manageLocalesButton
        } label: {
            Label("\(locale.rawValue)", systemImage: "globe")
                .labelStyle(.titleAndIcon)
                .contentShape(Rectangle())
                .glassEffect(.regular)
                .fixedSize(horizontal: true, vertical: false)
        }.menuOrder(.fixed)
    }
    
    private var manageLocalesButton: some View {
        Button {
            openSettings()
        } label: {
            Label("Manage Locales", systemImage: "arrow.down.circle")
        }
    }
}
