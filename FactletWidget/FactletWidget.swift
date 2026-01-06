//
//  FactletWidget.swift
//  FactletWidget
//
//  Widget displaying factlets on home screen and lock screen
//

import WidgetKit
import SwiftUI
import AppIntents

// MARK: - Timeline Entry
struct FactletEntry: TimelineEntry {
    let date: Date
    let factlet: Factlet
    let textColor: WidgetTextColor
}

// MARK: - Timeline Provider
struct FactletTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> FactletEntry {
        FactletEntry(
            date: Date(),
            factlet: Factlet(fact: "Honey never spoils. Archaeologists have found 3,000-year-old honey in Egyptian tombs.", category: "Science", level: .level1),
            textColor: .dark
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (FactletEntry) -> Void) {
        let entry = FactletEntry(
            date: Date(),
            factlet: FactletManager.getCurrentFactlet(),
            textColor: FactletManager.getTextColor()
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<FactletEntry>) -> Void) {
        let currentDate = Date()
        let refreshInterval = FactletManager.getRefreshInterval()
        let suiteName = "group.com.factlet.app"
        let userDefaults = UserDefaults(suiteName: suiteName)
        
        // Check if a refresh is needed
        let lastUpdateKey = "lastUpdate"
        var shouldRefresh = false
        if let lastUpdate = userDefaults?.object(forKey: lastUpdateKey) as? Date {
            shouldRefresh = currentDate.timeIntervalSince(lastUpdate) >= refreshInterval.timeInterval
        } else {
            shouldRefresh = true
        }
        
        // Get or refresh the factlet
        var factlet: Factlet
        if shouldRefresh {
            // Refresh needed - get a new random factlet
            // Note: This uses a simple random selection. For filtered factlets,
            // the app should refresh when opened, but this ensures the widget
            // updates on schedule even if the app isn't running
            factlet = FactletCollection.random()
            
            // Save the new factlet to UserDefaults
            if let data = try? JSONEncoder().encode(factlet) {
                userDefaults?.set(data, forKey: "currentFactlet")
            }
            userDefaults?.set(currentDate, forKey: lastUpdateKey)
        } else {
            // No refresh needed - use existing factlet
            factlet = FactletManager.getCurrentFactlet()
        }
        
        let textColor = FactletManager.getTextColor()
        
        // Calculate next refresh time
        let nextRefresh = currentDate.addingTimeInterval(refreshInterval.timeInterval)
        
        // Create entry for immediate display
        let entry = FactletEntry(
            date: currentDate,
            factlet: factlet,
            textColor: textColor
        )
        
        // For lockscreen widgets, use .atEnd with a future entry to trigger reload
        // This is more reliable than .after() for accessory widgets
        // Create a placeholder entry at refresh time to trigger timeline reload
        let refreshTriggerEntry = FactletEntry(
            date: nextRefresh,
            factlet: factlet,
            textColor: textColor
        )
        
        // Use .atEnd so timeline reloads when refreshTriggerEntry date passes
        // This ensures lockscreen widgets update at the scheduled time
        // When it reloads, shouldRefresh will be true and a new factlet will be selected
        let timeline = Timeline(entries: [entry, refreshTriggerEntry], policy: .atEnd)
        completion(timeline)
    }
}

// MARK: - Widget Views
struct FactletWidgetEntryView: View {
    var entry: FactletEntry
    @Environment(\.widgetFamily) var family
    
    private var backgroundColor: Color {
        entry.textColor == .light ? .black : .clear
    }
    
    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SmallWidgetView(factlet: entry.factlet, textColor: entry.textColor)
            case .systemMedium:
                MediumWidgetView(factlet: entry.factlet, textColor: entry.textColor)
            case .systemLarge:
                LargeWidgetView(factlet: entry.factlet, textColor: entry.textColor)
            case .accessoryCircular:
                CircularLockScreenView(factlet: entry.factlet)
            case .accessoryRectangular:
                RectangularLockScreenView(factlet: entry.factlet)
            case .accessoryInline:
                InlineLockScreenView(factlet: entry.factlet)
            default:
                MediumWidgetView(factlet: entry.factlet, textColor: entry.textColor)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
    }
}

// MARK: - Small Widget
struct SmallWidgetView: View {
    let factlet: Factlet
    let textColor: WidgetTextColor
    
    private var primaryColor: Color {
        textColor == .light ? .white : .black
    }
    
    private var backgroundColor: Color {
        textColor == .light ? .black : .clear
    }
    
    var body: some View {
        VStack(spacing: 8) {
            Text(factlet.category.uppercased())
                .font(.custom("TimesNewRomanPS-BoldMT", size: 8))
                .kerning(1.5)
                .foregroundColor(primaryColor.opacity(0.5))
            
            Text(factlet.fact)
                .font(.custom("TimesNewRomanPSMT", size: 13))
                .lineSpacing(3)
                .multilineTextAlignment(.center)
                .foregroundColor(primaryColor.opacity(0.95))
                .lineLimit(6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(14)
        .background(backgroundColor)
    }
}

// MARK: - Medium Widget
struct MediumWidgetView: View {
    let factlet: Factlet
    let textColor: WidgetTextColor
    
    private var primaryColor: Color {
        textColor == .light ? .white : .black
    }
    
    private var backgroundColor: Color {
        textColor == .light ? .black : .clear
    }
    
    var body: some View {
        VStack(spacing: 10) {
            Text(factlet.category.uppercased())
                .font(.custom("TimesNewRomanPS-BoldMT", size: 9))
                .kerning(2)
                .foregroundColor(primaryColor.opacity(0.5))
            
            Text(factlet.fact)
                .font(.custom("TimesNewRomanPSMT", size: 15))
                .lineSpacing(5)
                .multilineTextAlignment(.center)
                .foregroundColor(primaryColor.opacity(0.95))
                .lineLimit(4)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
        .background(backgroundColor)
    }
}

// MARK: - Large Widget
struct LargeWidgetView: View {
    let factlet: Factlet
    let textColor: WidgetTextColor
    
    private var primaryColor: Color {
        textColor == .light ? .white : .black
    }
    
    private var backgroundColor: Color {
        textColor == .light ? .black : .clear
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Text(factlet.category.uppercased())
                .font(.custom("TimesNewRomanPS-BoldMT", size: 10))
                .kerning(2.5)
                .foregroundColor(primaryColor.opacity(0.5))
            
            Text(factlet.fact)
                .font(.custom("TimesNewRomanPSMT", size: 20))
                .lineSpacing(8)
                .multilineTextAlignment(.center)
                .foregroundColor(primaryColor.opacity(0.95))
                .padding(.horizontal, 20)
            
            Spacer()
            
            // Branding
            Text("Factlet")
                .font(.custom("TimesNewRomanPS-ItalicMT", size: 12))
                .foregroundColor(primaryColor.opacity(0.35))
                .padding(.bottom, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
        .background(backgroundColor)
    }
}

// MARK: - Lock Screen Widgets
struct CircularLockScreenView: View {
    let factlet: Factlet
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            Text("F")
                .font(.custom("TimesNewRomanPS-BoldMT", size: 24))
        }
    }
}

struct RectangularLockScreenView: View {
    let factlet: Factlet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(factlet.category.uppercased())
                .font(.custom("TimesNewRomanPS-BoldMT", size: 9))
                .opacity(0.6)
            
            Text(factlet.fact)
                .font(.custom("TimesNewRomanPSMT", size: 12))
                .lineLimit(2)
        }
    }
}

struct InlineLockScreenView: View {
    let factlet: Factlet
    
    var body: some View {
        Text(factlet.fact)
            .font(.custom("TimesNewRomanPSMT", size: 12))
    }
}

// MARK: - Widget Configuration
@main
struct FactletWidget: Widget {
    let kind: String = "FactletWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FactletTimelineProvider()) { entry in
            FactletWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    entry.textColor == .light ? Color.black : Color.clear
                }
        }
        .configurationDisplayName("Factlet")
        .description("A small piece of knowledge, beautifully presented.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
        .contentMarginsDisabled()
    }
}

// MARK: - Previews
#Preview(as: .systemSmall) {
    FactletWidget()
} timeline: {
    FactletEntry(date: .now, factlet: FactletCollection.all[0], textColor: .dark)
    FactletEntry(date: .now, factlet: FactletCollection.all[0], textColor: .light)
}

#Preview(as: .systemMedium) {
    FactletWidget()
} timeline: {
    FactletEntry(date: .now, factlet: FactletCollection.all[0], textColor: .dark)
    FactletEntry(date: .now, factlet: FactletCollection.all[0], textColor: .light)
}

#Preview(as: .systemLarge) {
    FactletWidget()
} timeline: {
    FactletEntry(date: .now, factlet: FactletCollection.all[0], textColor: .dark)
    FactletEntry(date: .now, factlet: FactletCollection.all[0], textColor: .light)
}
