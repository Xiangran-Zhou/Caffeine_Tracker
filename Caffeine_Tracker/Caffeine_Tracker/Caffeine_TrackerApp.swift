//
//  Caffeine_TrackerApp.swift
//  Caffeine_Tracker
//
//  Created by kevin zhou on 2/24/26.
//

import SwiftUI
import AppKit

@main
struct Caffeine_TrackerApp: App {
    init() {
        if let dockIcon = makeDockIcon() {
            NSApplication.shared.applicationIconImage = dockIcon
        }
    }

    var body: some Scene {
        MenuBarExtra("Caffeine Tracker", systemImage: "cup.and.saucer.fill") {
            ContentView()
        }
        .menuBarExtraStyle(.window)
    }

    private func makeDockIcon() -> NSImage? {
        let canvasSize = NSSize(width: 512, height: 512)
        let image = NSImage(size: canvasSize)

        image.lockFocus()
        defer { image.unlockFocus() }

        let bounds = NSRect(origin: .zero, size: canvasSize)

        // Blue rounded square background for better contrast in dark Dock.
        let backgroundRect = bounds.insetBy(dx: 36, dy: 36)
        let backgroundPath = NSBezierPath(roundedRect: backgroundRect, xRadius: 96, yRadius: 96)
        NSColor(calibratedRed: 0.14, green: 0.52, blue: 0.98, alpha: 1.0).setFill()
        backgroundPath.fill()

        guard let symbolImage = NSImage(
            systemSymbolName: "cup.and.saucer.fill",
            accessibilityDescription: "Caffeine Tracker"
        ) else {
            return nil
        }

        let symbolConfig = NSImage.SymbolConfiguration(pointSize: 250, weight: .regular)
        let configured = symbolImage.withSymbolConfiguration(symbolConfig) ?? symbolImage
        let symbolRect = NSRect(x: 116, y: 120, width: 280, height: 280)
        let tintedSymbol = tintedImage(configured, color: .white)
        tintedSymbol.draw(in: symbolRect)

        return image
    }

    private func tintedImage(_ source: NSImage, color: NSColor) -> NSImage {
        let tinted = NSImage(size: source.size)
        tinted.lockFocus()
        defer { tinted.unlockFocus() }

        let rect = NSRect(origin: .zero, size: source.size)
        source.draw(in: rect)
        let context = NSGraphicsContext.current
        let previousOperation = context?.compositingOperation
        context?.compositingOperation = .sourceAtop
        color.setFill()
        NSBezierPath(rect: rect).fill()
        context?.compositingOperation = previousOperation ?? .sourceOver

        return tinted
    }
}
