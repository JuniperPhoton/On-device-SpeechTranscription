//
//  SettingsView.swift
//  SpeechTranscription
//
//  Created by juniperphoton on 8/30/25.
//
import SwiftUI
import Speech

struct SettingsView: View {
    var body: some View {
        TabView {
            Tab("Locales", systemImage: "globe") {
                LocaleSettingsView()
            }
            Tab("About", systemImage: "info.circle") {
                Text("Under construction")
            }
        }
    }
}

struct LocaleManageItemView: View {
    @Environment(AppLocalesModel.self) private var localesModel

    var localeItem: AppLocaleItem
    
    var body: some View {
        HStack {
            Text("\(localeItem.locale.rawValue)")
            Spacer()
            Group {
                switch localeItem.status {
                case .installed:
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.accent)
                        .imageScale(.large)
                case .downloading(let progress):
                    ProgressView(value: progress)
                        .progressViewStyle(.circular)
                        .controlSize(.small)
                case .pending:
                    Button {
                        localesModel.requestDownload(for: localeItem)
                    } label: {
                        Label("Download", systemImage: "arrow.down.circle")
                            .labelStyle(.titleAndIcon)
                    }
                }
            }.frame(height: 30)
        }.padding(.vertical, 4)
            .animation(.default, value: localeItem.status)
    }
}

struct LocaleSettingsView: View {
    @Environment(AppLocalesModel.self) private var localesModel

    var body: some View {
        NavigationStack {
            List {
                ForEach(localesModel.localeItems) { item in
                    LocaleManageItemView(localeItem: item)
                }
            }.padding()
        }
    }
}
