import SwiftUI
import Combine

class HackerNewsViewModel: ObservableObject {
    @Published var articles: [HNFeedType: [HackerNewsItem]] = [:]
    @Published var selectedFeed: HNFeedType = .top
    @Published var isRefreshing: Bool = false
    @Published var isLoading: Bool = true // ✅ Track initial load state

    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    
    @AppStorage("autoRefreshInterval") private var refreshInterval: Int = 5 // ✅ Auto-updates when changed

    init() {
        preloadStories()
        startAutoRefresh()
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefreshNotification), name: NSNotification.Name("RefreshNews"), object: nil)
    }

    @objc private func handleRefreshNotification() {
        preloadStories()
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
        timer?.invalidate() // ✅ Stop any existing timer before starting a new one
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(refreshInterval * 60), repeats: true) { _ in
            self.preloadStories()
        }

        print("🔄 Auto-refresh set to every \(refreshInterval) minutes")
    }
}
