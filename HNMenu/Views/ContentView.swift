//
//  ContentView.swift
//  HNMenu
//
//  Created by Abdul Baari Davids on 2025/02/02.
//


import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = HackerNewsViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            FeedSelectorView(selectedFeed: $viewModel.selectedFeed)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.articles[viewModel.selectedFeed] ?? []) { article in
                        HackerNewsItemView(article: article)
                    }
                }
                .padding()
            }
            .frame(width: 320, height: 420)
        }
        .background(VisualEffectView(material: .underWindowBackground, blendingMode: .behindWindow))
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}
