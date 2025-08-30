//
//  AppLocalesModel.swift
//  SpeechTranscription26
//
//  Created by juniperphoton on 8/30/25.
//
import SwiftUI
import Speech

@MainActor
@Observable
class AppLocalesModel {
    private(set) var localeItems = [AppLocaleItem]()
    
    var loading = false
    var installedItems: [AppLocaleItem] {
        localeItems.filter { $0.status == .installed }
    }
    
    init() {
        Task {
            await loadItems()
        }
    }
    
    func loadItems() async {
        loading = true
        defer {
            loading = false
        }
        
        let localeItems = await AppLocale.getSupportedLocales().map { locale in
            AppLocaleItem(locale: locale)
        }
        
        let installed = await SpeechTranscriber.installedLocales
        for item in localeItems {
            // TODO: Try monitor the downloading status when the app re-open while the model is downloading by the
            // system in the background.
            refresh(for: item, installedLocales: installed)
        }
        
        self.localeItems = localeItems
    }
    
    func requestDownload(for item: AppLocaleItem) {
        Task {
            let transcriber = SpeechTranscriber(
                locale: Locale(identifier: item.locale.identifier),
                transcriptionOptions: [],
                reportingOptions: [.volatileResults],
                attributeOptions: []
            )
            
            if let downloader = try await AssetInventory.assetInstallationRequest(supporting: [transcriber]) {
                let progressTask = Task {
                    while true {
                        try await Task.sleep(for: .seconds(1))
                        item.status = .downloading(progress: downloader.progress.fractionCompleted)
                    }
                }
                try await downloader.downloadAndInstall()
                progressTask.cancel()
            } else {
                item.status = .installed
            }
            
            await refresh(for: item)
        }
    }
    
    private func refresh(for item: AppLocaleItem) async {
        let installed = await SpeechTranscriber.installedLocales
        refresh(for: item, installedLocales: installed)
    }
    
    private func refresh(for item: AppLocaleItem, installedLocales: [Locale]) {
        let installed = installedLocales.contains { locale in
            locale.identifier == item.locale.identifier
        }
        if installed {
            item.status = .installed
        } else {
            item.status = .pending
        }
    }
}
