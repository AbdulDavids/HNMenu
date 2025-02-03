import SwiftUI

struct HackerNewsItemView: View {
    let article: HackerNewsItem

    @AppStorage("showTimePosted") private var showTimePosted = true
    @AppStorage("showAuthor") private var showAuthor = true
    @AppStorage("showUpvotes") private var showUpvotes = true

    @State private var isHovered = false
    @State private var titleHovered = false

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

    var articleURL: URL? {
        if let urlString = article.url, let url = URL(string: urlString) {
            return url
        }
        return nil
    }

    var hnPostURL: URL {
        URL(string: "https://news.ycombinator.com/item?id=\(article.id)")!
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.windowBackgroundColor))
                .shadow(radius: isHovered ? 8 : 3)
                .opacity(isHovered ? 0.95 : 1.0)
                .animation(.easeInOut(duration: 0.3), value: isHovered)
                .onTapGesture {
                    NSWorkspace.shared.open(hnPostURL)
                }

            VStack(spacing: 6) {
                if let url = articleURL {
                    Text(article.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 260, alignment: .center)
                        .lineLimit(3)
                        .padding(.top, 10)
                        .scaleEffect(titleHovered ? 1.01 : 1.0) // Smooth pop effect
                        .shadow(color: titleHovered ? Color.white.opacity(0.5) : Color.clear, radius: 2) // Glows when hovered
                        .animation(.easeInOut(duration: 0.2), value: titleHovered)
                        .onTapGesture {
                            NSWorkspace.shared.open(url)
                        }
                        .onHover { hovering in
                            titleHovered = hovering
                        }
                } else {
                    Text(article.title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 260, alignment: .center)
                        .lineLimit(3)
                        .padding(.top, 10)
                        .onTapGesture {
                            NSWorkspace.shared.open(hnPostURL)
                        }
                }

                if let info = infoText {
                    Text(info)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 10)
                }
            }
            .padding()
        }
        .frame(width: 280)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
    }
}
