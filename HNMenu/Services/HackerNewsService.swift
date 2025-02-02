//
//  HackerNewsService.swift
//  HNMenu
//
//  Created by Abdul Baari Davids on 2025/02/02.
//


import Foundation
import Combine

class HackerNewsService {
    static let shared = HackerNewsService()
    
    private init() {}

    func fetchStories(for feed: HNFeedType) -> AnyPublisher<[HackerNewsItem], Never> {
        let url = URL(string: "https://hacker-news.firebaseio.com/v0/\(feed.rawValue).json")!
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Int].self, decoder: JSONDecoder())
            .map { Array($0.prefix(50)) }
            .flatMap { ids in
                Publishers.MergeMany(ids.map { id in
                    self.fetchStory(id: id)
                })
                .collect()
            }
            .receive(on: DispatchQueue.main)
            .catch { _ in Just([]) }
            .eraseToAnyPublisher()
    }

    private func fetchStory(id: Int) -> AnyPublisher<HackerNewsItem, Never> {
        let url = URL(string: "https://hacker-news.firebaseio.com/v0/item/\(id).json")!
        return URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: HackerNewsItem.self, decoder: JSONDecoder())
            .catch { _ in Just(HackerNewsItem(id: id, title: "Error loading", url: nil, by: "Unknown", score: 0, time: 0)) }.eraseToAnyPublisher()
    }
}
