import SwiftUI
import Combine
import AppKit

enum HNFeedType: String, CaseIterable {
    case top = "topstories"
    case new = "newstories"
    case jobs = "jobstories"
    case show = "showstories"
    
    var displayName: String {
        switch self {
        case .top: return "Top"
        case .new: return "New"
        case .jobs: return "Jobs"
        case .show: return "Show"
        }
    }
}

struct VisualEffectView: NSViewRepresentable {
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}

struct HackerNewsItem: Identifiable, Codable {
    let id: Int
    let title: String
    let url: String?
    let by: String?
    let score: Int?
}

class HackerNewsViewModel: ObservableObject {
    @Published var articles: [HNFeedType: [HackerNewsItem]] = [:]
    @Published var selectedFeed: HNFeedType = .top
    @Published var isRefreshing: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer?
    
    init() {
        preloadStories()
        startAutoRefresh()
    }
    
    func preloadStories() {
        isRefreshing = true
        let publishers = HNFeedType.allCases.map { fetchStories(for: $0) }
        
        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in
                self.isRefreshing = false
            })
            .store(in: &cancellables)
    }
    
    func fetchStories(for feed: HNFeedType) -> AnyPublisher<Void, Never> {
        let url = URL(string: "https://hacker-news.firebaseio.com/v0/\(feed.rawValue).json")!
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Int].self, decoder: JSONDecoder())
            .map { Array($0.prefix(50)) }
            .flatMap { ids in
                Publishers.MergeMany(ids.map { id in
                    URLSession.shared.dataTaskPublisher(for: URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json")!)
                        .map { $0.data }
                        .decode(type: HackerNewsItem.self, decoder: JSONDecoder())
                        .catch { _ in Just(HackerNewsItem(id: id, title: "Error loading", url: nil, by: "Unknown", score: 0)) }
                        .setFailureType(to: Never.self)
                })
                .collect()
            }
            .receive(on: DispatchQueue.main)
            .handleEvents(receiveOutput: { [weak self] articles in
                self?.articles[feed] = articles
            })
            .map { _ in () }
            .catch { _ in Just(()) }
            .eraseToAnyPublisher()
    }
    
    func startAutoRefresh() {
        timer = Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { _ in
            self.preloadStories()
        }
    }
}


struct ContentView: View {
    @ObservedObject var viewModel = HackerNewsViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Picker("", selection: $viewModel.selectedFeed) {
                    ForEach(HNFeedType.allCases, id: \.self) { feed in
                        Text(feed.displayName)
                            .font(.system(size: 14, weight: .semibold))
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            .background(VisualEffectView(material: .headerView, blendingMode: .behindWindow)) // 🔥 Native macOS header

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(viewModel.articles[viewModel.selectedFeed] ?? []) { article in
                        VStack(spacing: 5) {
                            
                            // 🔥 Title remains centered, now using system color
                            if let link = URL(string: "https://news.ycombinator.com/item?id=\(article.id)") {
                                Link(article.title, destination: link)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary) // 🔥 Uses system default color
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: 260, alignment: .center)
                                    .lineLimit(3)
                            } else {
                                Text(article.title)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.primary) // 🔥 Uses system default color
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: 260, alignment: .center)
                                    .lineLimit(3)
                            }

                            // 🔥 Combined Upvotes + Author in one text field
                            if let author = article.by, let score = article.score {
                                Text("▲ \(score)  |  \(author)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary) // 🔥 Uses system secondary color
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else if let author = article.by {
                                Text(author)
                                    .font(.system(size: 12))
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else if let score = article.score {
                                Text("▲ \(score)")
                                    .font(.system(size: 12))
                                    .foregroundColor(.green)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            }

                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .background(VisualEffectView(material: .windowBackground, blendingMode: .behindWindow)) // 🔥 Native macOS background
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    }
                }
                .padding()
            }
            .frame(width: 320, height: 420)
        }
        .background(VisualEffectView(material: .underWindowBackground, blendingMode: .behindWindow)) // 🔥 Uses system default window background
        .cornerRadius(12)
        .shadow(radius: 5)
    }
}

@main
struct HackerNewsMenuBarApp: App {
    @StateObject private var statusBarController = StatusBarController()
    

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class StatusBarController: ObservableObject {
    private var statusItem: NSStatusItem
    private var popover: NSPopover
    
    init() {
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        self.popover = NSPopover()
        self.popover.contentSize = NSSize(width: 320, height: 420)
        self.popover.behavior = .transient // 🔥 Auto-closes when clicking outside
        self.popover.contentViewController = NSHostingController(rootView: ContentView())
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "newspaper.fill", accessibilityDescription: "HackerNews")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if popover.isShown {
            popover.performClose(sender)
        } else if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover.contentViewController?.view.window?.makeKey() // 🔥 Ensures it closes when clicking away
        }
    }
}
