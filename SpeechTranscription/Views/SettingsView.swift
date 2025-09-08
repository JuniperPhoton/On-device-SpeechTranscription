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
                AboutView()
            }
        }
    }
}

struct AboutView: View {
    @Environment(\.openURL) private var openURL
    
    var body: some View {
        VStack {
            Spacer()
            
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .frame(width: 100, height: 100)
            
            Text("Speech Transcription")
                .font(.title.bold())
            
            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                .font(.subheadline)
            
            Spacer()
            Spacer()
            
            Button {
                openURL(URL(string: "https://github.com/JuniperPhoton/On-device-SpeechTranscription")!)
            } label: {
                LinkButtonLabel(
                    name: "GitHub",
                    systemImage: "arrow.up.right",
                    foregroundStyle: .white,
                    backgroundTint: .black
                )
            }.buttonStyle(.plain)
        }.padding().multilineTextAlignment(.center)
    }
}

private struct LinkButtonLabel<ForegroundStyle: ShapeStyle>: View {
    var name: String
    var systemImage: String
    var foregroundStyle: ForegroundStyle
    var backgroundTint: Color
    
    var body: some View {
        Label(name, systemImage: systemImage)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .foregroundStyle(foregroundStyle)
            .glassEffect(.regular.interactive().tint(backgroundTint))
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

#Preview {
    AboutView().frame(width: 400, height: 400)
}
