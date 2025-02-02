//
//  HNFeedType.swift
//  HNMenu
//
//  Created by Abdul Baari Davids on 2025/02/02.
//


import Foundation

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