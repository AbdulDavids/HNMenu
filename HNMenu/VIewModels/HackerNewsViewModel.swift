//
//  HackerNewsViewModel.swift
//  HNMenu
//
//  Created by Abdul Baari Davids on 2025/02/02.
//

import SwiftUI
import Combine

class HackerNewsViewModel: ObservableObject {
    @Published var articles: [HNFeedType: [HackerNewsItem]] = [:]
    @Published var selectedFeed: HNFeedType = .top
    @Published var isRefreshing: Bool = false
    @Published var isLoading: Bool = true

    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?

    @AppStorage("autoRefreshInterval") private var refreshInterval: Int = 5

    init() {
        print("🔄 ViewModel initialized. Fetching initial stories...")
        preloadStories()
        startAutoRefresh()

        NotificationCenter.default.addObserver(self, selector: #selector(handleRefreshNotification), name: NSNotification.Name("RefreshNews"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshIntervalChanged), name: UserDefaults.didChangeNotification, object: nil)
    }

    @objc private func handleRefreshNotification() {
        preloadStories()
    }

    @objc private func refreshIntervalChanged() {
        print("🕒 Auto-refresh interval changed to \(refreshInterval) minutes. Restarting timer...")
        startAutoRefresh()
    }

    func preloadStories() {
        isLoading = true
        isRefreshing = true

        let publishers = HNFeedType.allCases.map { feed in
            HackerNewsService.shared.fetchStories(for: feed)
                .handleEvents(receiveOutput: { [weak self] articles in
                    DispatchQueue.main.async {
                        self?.articles[feed] = articles
                    }
                })
                .map { _ in () }
        }

        Publishers.MergeMany(publishers)
            .collect()
            .sink(receiveCompletion: { _ in
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.isRefreshing = false
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }

    func startAutoRefresh() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(refreshInterval * 60), repeats: true) { _ in
            self.preloadStories()
        }

        print("🔄 Auto-refresh set to every \(refreshInterval) minutes")
    }
}
