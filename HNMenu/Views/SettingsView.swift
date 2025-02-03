//
//  SettingsView.swift
//  HNMenu
//
//  Created by Abdul Baari Davids on 2025/02/02.
//
import SwiftUI

struct SettingsView: View {
    @AppStorage("autoRefreshInterval") private var autoRefreshInterval = 5
    @AppStorage("showTimePosted") private var showTimePosted = true
    @AppStorage("showAuthor") private var showAuthor = true
    @AppStorage("showUpvotes") private var showUpvotes = true
    
    private let refreshIntervals = [1, 5, 10, 15, 30, 60]
    private let appVersion = "1.0.1"
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Auto Refresh Interval")
                    .foregroundStyle(.secondary)
                Spacer()
                Picker("", selection: $autoRefreshInterval) {
                    ForEach(refreshIntervals, id: \.self) { interval in
                        Text("\(interval) min").tag(interval)
                    }
                }
                .frame(width: 80)
                .pickerStyle(.menu)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text("Display Options")
                    .foregroundStyle(.secondary)
                    .font(.headline)
                
                VStack(spacing: 4) {
                    SettingsToggleRow(title: "Author", isOn: $showAuthor)
                    SettingsToggleRow(title: "Updoots", isOn: $showUpvotes)
                    SettingsToggleRow(title: "Time Posted", isOn: $showTimePosted)
                }
            }
            
            
            HStack {
                Text("Version")
                    .foregroundStyle(.secondary)
                Spacer()
                Text("HNMenu v\(appVersion)")
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            
            Text("Made with ☕️ by Abdul Davids")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .onTapGesture {
                    NSWorkspace.shared.open(URL(string: "https://github.com/abduldavids")!)
                }
            
            Button("Close HNMenu") {
                NSApp.terminate(nil)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
            .frame(maxWidth: .infinity)
        }
        .padding(16)
        .frame(width: 280)
        .frame(minHeight: 280)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

struct SettingsToggleRow: View {
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer()
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
    }
}

#Preview {
    SettingsView()
}
