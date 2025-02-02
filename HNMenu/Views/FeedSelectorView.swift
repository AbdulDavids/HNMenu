//
//  FeedSelectorView.swift
//  HNMenu
//
//  Created by Abdul Baari Davids on 2025/02/02.
//

import SwiftUI

struct FeedSelectorView: View {
    @Binding var selectedFeed: HNFeedType

    var body: some View {
        Picker("", selection: $selectedFeed) {
            ForEach(HNFeedType.allCases, id: \.self) { feed in
                Text(feed.displayName)
            }
        }
        .pickerStyle(SegmentedPickerStyle()) // ✅ Native macOS segment style
        .padding(.horizontal, 8) // ✅ Slightly wider horizontal padding for balance
        .padding(.top, 6) // ✅ Added spacing above for better alignment
        .padding(.bottom, 4) // ✅ Keeps it visually balanced
    }
}
