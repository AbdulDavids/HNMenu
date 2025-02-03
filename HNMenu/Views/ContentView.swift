//
//  ContentView.swift
//  HNMenu
//
//  Created by Abdul Baari Davids on 2025/02/02.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel = HackerNewsViewModel()
    
    // funny loading messages
    // TODO: use AI to generate these (just kidding... unless...)
    private let loadingMessages = [
        "Fetching the spiciest tech takes...",
        "Summoning the Hacker Gods...",
        "Bribing the API with upvotes...",
        "Waiting for the front page drama...",
        "Parsing nerdy discussions...",
        "Loading... because we can't afford AI yet.",
        "Compiling bad opinions...",
        "Decrypting Elon’s latest tweet...",
        "Convincing the server we're human...",
        "DDoS’ing my own brain...",
        "Stealing upvotes from Reddit...",
        "Searching for a Y Combinator internship...",
        "Optimizing for 10x engineers...",
        "Extracting wisdom from comment threads...",
        "Mining karma like it’s crypto...",
        "Asking ChatGPT to summarize for us...",
        "Refactoring your attention span...",
        "Checking if dark mode is enabled...",
        "Adding unnecessary animations...",
        "Telling you to ‘just Google it’...",
        "AI will replace us, but not today...",
        "Finding the last known use of PHP...",
        "Configuring Vim… oh wait, stuck now.",
        "Reverse engineering my own existence...",
        "Hacking the mainframe (whatever that is)...",
        "Follow me on Twitter: @abdulbdavids!"
    ]
    
    @State private var currentMessage: String = "Loading..."
    @State private var timer: Timer? = nil

    var body: some View {
        VStack(spacing: 0) {
            FeedSelectorView(selectedFeed: $viewModel.selectedFeed)

            if viewModel.isLoading || (viewModel.articles[viewModel.selectedFeed]?.isEmpty ?? true) {
                VStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())

                    Text(currentMessage)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.top, 6)
                        .transition(.opacity)

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    startMessageRotation()
                }
                .onDisappear {
                    stopMessageRotation()
                }
            } else {
                ScrollView {
                    Spacer()
                    VStack(spacing: 10) {
                        ForEach(viewModel.articles[viewModel.selectedFeed] ?? []) { article in
                            HackerNewsItemView(article: article)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(width: 300, height: 400)
                .scrollIndicators(.never)
            }
        }
    }

    private func startMessageRotation() {
        currentMessage = loadingMessages.randomElement() ?? "Loading..."
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            currentMessage = loadingMessages.randomElement() ?? "Loading..."
        }
    }

    private func stopMessageRotation() {
        timer?.invalidate()
        timer = nil
    }
}
