//
//  HackerNewsItem.swift
//  HNMenu
//
//  Created by Abdul Baari Davids on 2025/02/02.
//


import Foundation

struct HackerNewsItem: Identifiable, Codable {
    let id: Int
    let title: String
    let url: String?
    let by: String?
    let score: Int?
    let time: Int?
}
