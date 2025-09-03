//
//  NSTextViewBridge.swift
//  SpeechTranscription
//
//  Created by juniperphoton on 9/3/25.
//
import SwiftUI
import AppKit

public typealias PlatformFont = NSFont

public extension NSTextViewBridge {
    struct Style {
        public struct FontStyle {
            public var font: PlatformFont?
            public var foregroundColorName: String?
            public var lineSpacing: CGFloat
            
            public init(
                font: PlatformFont? = nil,
                foregroundColorName: String? = nil,
                lineSpacing: CGFloat = 6.0
            ) {
                self.font = font
                self.foregroundColorName = foregroundColorName
                self.lineSpacing = lineSpacing
            }
        }
        
        public struct LayoutStyle {
            public var contentInsets: EdgeInsets?
            public init(contentInsets: EdgeInsets? = nil) {
                self.contentInsets = contentInsets
            }
        }
        
        public struct BehaviorStyle {
            public var autoScrollToBottom: Bool
            public init(autoScrollToBottom: Bool) {
                self.autoScrollToBottom = autoScrollToBottom
            }
        }
        
        public var fontStyle: FontStyle
        public var layoutStyle: LayoutStyle
        public var behaviorStyle: BehaviorStyle
        
        public init(
            fontStyle: FontStyle = .init(),
            layoutStyle: LayoutStyle = .init(),
            behaviorStyle: BehaviorStyle = .init(autoScrollToBottom: true)
        ) {
            self.fontStyle = fontStyle
            self.layoutStyle = layoutStyle
            self.behaviorStyle = behaviorStyle
        }
    }
}

public struct NSTextViewBridge: NSViewRepresentable {
    public static func dismantleNSView(_ nsView: NSScrollView, coordinator: TextViewCoordinator) {
        coordinator.unregister()
    }
    
    public class TextViewCoordinator: NSObject {
        fileprivate var autoScrollToBottom = true
        
        func unregister() {
            NotificationCenter.default.removeObserver(self)
        }
        
        func register() {
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(onScroll),
                name: NSScrollView.willStartLiveScrollNotification,
                object: nil
            )
        }
        
        @objc
        func onScroll() {
            self.autoScrollToBottom = false
        }
    }
    
    public let text: NSAttributedString
    public let foregroundColorName: String?
    public let contentInsets: EdgeInsets?
    public let autoScrollToBottom: Bool
    
    public let style: Style
    
    public init(text: String, style: Style) {
        self.init(text: NSAttributedString(string: text), style: style)
    }
    
    public init(text: NSAttributedString, style: Style) {
        self.text = text
        self.foregroundColorName = style.fontStyle.foregroundColorName
        self.contentInsets = style.layoutStyle.contentInsets
        self.autoScrollToBottom = style.behaviorStyle.autoScrollToBottom
        self.style = style
    }
    
    public func makeNSView(context: Context) -> NSScrollView {
        let textView = NSTextView()
        textView.drawsBackground = false
        textView.isEditable = false
        textView.autoresizingMask = [.width, .height]

        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.documentView = textView
        scrollView.drawsBackground = false
        
        if let insets = self.style.layoutStyle.contentInsets {
            scrollView.automaticallyAdjustsContentInsets = false
            scrollView.contentInsets = NSEdgeInsets(
                top: insets.top,
                left: insets.leading,
                bottom: insets.bottom,
                right: insets.trailing
            )
        }
        
        if self.style.behaviorStyle.autoScrollToBottom {
            context.coordinator.register()
        }
        
        return scrollView
    }
    
    public func makeCoordinator() -> TextViewCoordinator {
        let coordinator = TextViewCoordinator()
        coordinator.autoScrollToBottom = autoScrollToBottom
        return coordinator
    }
    
    public func updateNSView(_ nsView: NSScrollView, context: Context) {
        let scrollView = nsView
        
        guard let textView = scrollView.documentView as? NSTextView else {
            return
        }
        
        let selectedRange = textView.selectedRange()
        
        textView.textStorage?.setAttributedString(self.text)
        setStyles(for: textView)
        
        if selectedRange.lowerBound >= 0 && selectedRange.upperBound <= self.text.length {
            textView.setSelectedRange(selectedRange)
        }
        
        if context.coordinator.autoScrollToBottom {
            scrollView.documentView?.scroll(.init(x: 0, y: textView.bounds.height))
        }
    }
    
    private func setStyles(for textView: NSTextView) {
        // Get the text storage and the full range of text
        guard let textStorage = textView.textStorage else { return }
        let fullRange = NSRange(location: 0, length: textStorage.length)
        
        // Create a mutable paragraph style with the desired line spacing
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = self.style.fontStyle.lineSpacing
        
        // Apply the paragraph style to the text storage
        textStorage.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)
        
        if let colorName = self.style.fontStyle.foregroundColorName,
           let color = NSColor(named: colorName) {
            textStorage.foregroundColor = color
        } else {
            textStorage.foregroundColor = NSColor.textColor
        }
        
        if let font = style.fontStyle.font {
            textStorage.font = font
        } else {
            textView.font = NSFont.systemFont(ofSize: NSFont.systemFontSize)
        }
    }
}
