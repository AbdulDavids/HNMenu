//
//  AppDelegate.swift
//  HNMenu
//
//  Created by Abdul Baari Davids on 2025/02/02.
//

import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBarController: StatusBarController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBarController = StatusBarController()
    }
}
