import SwiftUI

struct SettingsView: View {
    @AppStorage("autoRefreshInterval") private var autoRefreshInterval = 5
    @AppStorage("showTimePosted") private var showTimePosted = true
    @AppStorage("showAuthor") private var showAuthor = true
    @AppStorage("showUpvotes") private var showUpvotes = true

    let refreshIntervals = [1, 5, 10, 15, 30, 60]

    var body: some View {
        Form {
            Section(header: Text("General")) {
                Picker("Auto Refresh Interval", selection: $autoRefreshInterval) {
                    ForEach(refreshIntervals, id: \.self) { interval in
                        Text("\(interval) min").tag(interval)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }

            Section(header: Text("Display Options")) {
                Toggle("Show Author", isOn: $showAuthor)
                Toggle("Show Upvotes", isOn: $showUpvotes)
                Toggle("Show Time Posted", isOn: $showTimePosted)
            }
        }
        .padding()
        .frame(width: 350, height: 200)
    }
}
