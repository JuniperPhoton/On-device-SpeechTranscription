//
//  AppLocaleItemStatus.swift
//  SpeechTranscription
//
//  Created by juniperphoton on 8/30/25.
//
import Foundation

enum AppLocaleItemStatus: Hashable {
    case pending
    case installed
    case downloading(progress: CGFloat)
}
