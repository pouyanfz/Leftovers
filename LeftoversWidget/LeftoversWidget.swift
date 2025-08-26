//
//  LeftoversWidget.swift
//  LeftoversWidget
//
//  Created by Pouyan on 2025-08-19.
//
import WidgetKit
import SwiftUI
import AppIntents   // needed for Button(intent:)
import os

private let widgetLog = Logger(subsystem: "com.your.bundleid.leftovers", category: "Widget")


struct LeftoversEntry: TimelineEntry {
    let date: Date
    let favorite: Item?
    let all: [Item]
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> LeftoversEntry {
        LeftoversEntry(date: Date(), favorite: nil, all: [])
    }
    func getSnapshot(in context: Context, completion: @escaping (LeftoversEntry) -> Void) {
        completion(makeEntry())
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<LeftoversEntry>) -> Void) {
        completion(Timeline(entries: [makeEntry()], policy: .after(Date().addingTimeInterval(60))))
    }
    
    private func makeEntry() -> LeftoversEntry {
        let items = SharedStore.loadItems()
        let fav = SharedStore.favoriteId().flatMap { id in items.first { $0.id == id } } ?? items.first
        widgetLog.info("Widget loaded items count: \(items.count), favorite set: \(fav != nil)")
        return LeftoversEntry(date: Date(), favorite: fav, all: items)
    }
}

// Small widget view
struct SmallWidgetView: View {
    let item: Item
    var body: some View {
        let tone = SharedTheme.progressColor(percent: item.percentageLeft)
        VStack(spacing: 10) {
            Text(item.name).font(.headline).lineLimit(1).foregroundColor(.blue)
            Text("\(item.count)\(item.unit.map { " \($0)" } ?? "")")
                .font(.title2).bold().foregroundStyle(tone)
            ProgressView(value: item.percentageLeft)
                .tint(tone)
            // interactive button in widget
            Spacer()
            Button(intent: DecrementItemIntent(itemId: item.id.uuidString)) {
                Label("Use one", systemImage: "minus.circle.fill")
            }
            .buttonStyle(.plain)
        }
        .padding(8)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// Large widget view
struct LargeWidgetView: View {
    let items: [Item]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("My List")
                .font(.headline)

            Divider()

            if items.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("No items found").font(.subheadline)
                    Text("Open the app and add items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else {
                ForEach(items) { it in
                    let tone = SharedTheme.progressColor(percent: it.percentageLeft)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(it.name)
                                .lineLimit(1)
                            Spacer()
                            VStack(alignment: .trailing, spacing: 1) {
                                Text("\(it.count)")
                                    .bold()
                                    .monospacedDigit()
                                if let u = it.unit, !u.isEmpty {
                                    Text(u)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        ProgressView(value: it.percentageLeft)
                            .tint(tone)
                    }
                }
            }

            Spacer(minLength: 0) // keeps content at the top
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct MediumWidgetView: View {
    var body: some View {
        Text("Medium widget 🚧")
    }
}

// A wrapper that decides which view to show based on family
struct RootWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: LeftoversEntry
    
    var body: some View {
        switch family {
        case .systemSmall:
            if let fav = entry.favorite { SmallWidgetView(item: fav) }
            else { Text("Pick a favorite").padding().containerBackground(.fill.tertiary, for: .widget) }
//        case .systemMedium:
//            MediumWidgetView() // reuse large layout, or make a MediumWidgetView
        default:
            LargeWidgetView(items: entry.all)
        }
    }
}

struct LeftoversWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "LeftoversWidget", provider: Provider()) { entry in
            RootWidgetView(entry: entry)
        }
        .configurationDisplayName("Leftovers")
        .description("Quick view and quick use.")
        .supportedFamilies([.systemSmall, .systemLarge])
    }
}


