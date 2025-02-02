//
//  StatusBarController.swift
//  HNMenu
//
//  Created by Abdul Baari Davids on 2025/02/02.
//


import SwiftUI
import AppKit

class StatusBarController: NSObject, ObservableObject, NSMenuDelegate {
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    private var settingsWindowController: NSWindowController?

    override init() {
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.popover = NSPopover()
        self.popover.contentSize = NSSize(width: 320, height: 420)
        self.popover.behavior = .transient
        self.popover.contentViewController = NSHostingController(rootView: ContentView())

        super.init()

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "newspaper", accessibilityDescription: "HackerNews")
            button.action = #selector(togglePopover(_:))
            button.target = self

            button.menu = createRightClickMenu()
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        if let event = NSApp.currentEvent {
            if event.type == .rightMouseUp {
                statusItem.menu = createRightClickMenu()
                statusItem.button?.performClick(nil)
                statusItem.menu = nil
            } else {
                // Left click: Show popover
                if popover.isShown {
                    popover.performClose(sender)
                } else if let button = statusItem.button {
                    popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                    popover.contentViewController?.view.window?.makeKey()
                }
            }
        }
    }

    private func createRightClickMenu() -> NSMenu {
        let menu = NSMenu()
        
        let refreshItem = NSMenuItem(title: "Refresh", action: #selector(refreshNews), keyEquivalent: "")
        refreshItem.target = self
        menu.addItem(refreshItem)

        let openHNItem = NSMenuItem(title: "Open HN", action: #selector(openHackerNews), keyEquivalent: "")
        openHNItem.target = self
        menu.addItem(openHNItem)

        menu.addItem(NSMenuItem.separator())

        let settingsItem = NSMenuItem(title: "Settings", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        menu.delegate = self
        return menu
    }

    @objc private func refreshNews() {
        NotificationCenter.default.post(name: NSNotification.Name("RefreshNews"), object: nil)
    }

    @objc private func openHackerNews() {
        if let url = URL(string: "https://news.ycombinator.com/") {
            NSWorkspace.shared.open(url)
        }
    }
    
    @objc private func openSettings() {
        if settingsWindowController == nil {
            let settingsView = SettingsView()
            let hostingController = NSHostingController(rootView: settingsView)

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 400, height: 300),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.contentViewController = hostingController
            window.center()
            window.isReleasedWhenClosed = false
            window.standardWindowButton(.miniaturizeButton)?.isHidden = true
            window.standardWindowButton(.zoomButton)?.isHidden = true

            settingsWindowController = NSWindowController(window: window)
        }

        settingsWindowController?.showWindow(nil)
        settingsWindowController?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true) 
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
}
