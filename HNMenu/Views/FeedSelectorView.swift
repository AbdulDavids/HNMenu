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
        .pickerStyle(SegmentedPickerStyle())
        .padding(.horizontal, 8)
        .padding(.top, 6)
        .padding(.bottom, 6) 
    }
}
