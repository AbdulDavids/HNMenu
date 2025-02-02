import SwiftUI

struct HackerNewsItemView: View {
    let article: HackerNewsItem

    @AppStorage("showTimePosted") private var showTimePosted = true
    @AppStorage("showAuthor") private var showAuthor = true
    @AppStorage("showUpvotes") private var showUpvotes = true

    var formattedTime: String {
        TimeFormatter.timeAgo(from: article.time ?? 0)
    }

    var infoText: String? {
        var elements: [String] = []

        if showUpvotes {
            elements.append("▲ \(article.score ?? 0)")
        }

        if showAuthor {
            elements.append(article.by ?? "Unknown")
        }

        if showTimePosted {
            elements.append(formattedTime)
        }

        return elements.isEmpty ? nil : elements.joined(separator: " • ")
    }

    var body: some View {
        VStack(spacing: 5) {
            if let link = URL(string: "https://news.ycombinator.com/item?id=\(article.id)") {
                Link(article.title, destination: link)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 260, alignment: .center)
                    .lineLimit(3)
            }

            if let info = infoText {
                HStack(spacing: 5) {
                    Text(info)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .padding()
        .background(VisualEffectView(material: .windowBackground, blendingMode: .behindWindow))
        .cornerRadius(10)
        .shadow(radius: 4)
        .scaleEffect(1.05)
        .opacity(0.95)
        .animation(.easeInOut(duration: 0.2), value: true)
        .onHover { hovering in
            withAnimation {
                _ = hovering
            }
        }
    }
}
