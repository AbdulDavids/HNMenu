//
//  TimeFormatter.swift
//  HNMenu
//
//  Created by Abdul Baari Davids on 2025/02/02.
//

import Foundation

struct TimeFormatter {
    static func timeAgo(from unixTime: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(unixTime))
        let now = Date()
        let diff = Int(now.timeIntervalSince(date))

        if diff < 60 {
            return "\(diff) sec ago"
        } else if diff < 3600 {
            let minutes = diff / 60
            return "\(minutes) \(minutes == 1 ? "min" : "mins") ago"
        } else if diff < 86400 {
            let hours = diff / 3600
            return "\(hours) \(hours == 1 ? "hour" : "hours") ago"
        } else if diff < 604800 {
            let days = diff / 86400
            return "\(days) \(days == 1 ? "day" : "days") ago"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            return formatter.string(from: date)
        }
    }
}
