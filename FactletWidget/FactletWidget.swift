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
        
        // Create an entry for now
        let entry = FactletEntry(
            date: currentDate,
            factlet: FactletManager.getCurrentFactlet(),
            textColor: FactletManager.getTextColor()
        )
        
        // Next refresh time
        let nextRefresh = currentDate.addingTimeInterval(refreshInterval.timeInterval)
        
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }
}

// MARK: - Widget Views
struct FactletWidgetEntryView: View {
    var entry: FactletEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
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
}

// MARK: - Small Widget
struct SmallWidgetView: View {
    let factlet: Factlet
    let textColor: WidgetTextColor
    
    private var primaryColor: Color {
        textColor == .light ? .white : .black
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(factlet.category.uppercased())
                .font(.custom("TimesNewRomanPS-BoldMT", size: 8))
                .kerning(1.5)
                .foregroundColor(primaryColor.opacity(0.5))
            
            Text(factlet.fact)
                .font(.custom("TimesNewRomanPSMT", size: 13))
                .lineSpacing(3)
                .foregroundColor(primaryColor.opacity(0.95))
                .lineLimit(6)
        }
        .padding(14)
    }
}

// MARK: - Medium Widget
struct MediumWidgetView: View {
    let factlet: Factlet
    let textColor: WidgetTextColor
    
    private var primaryColor: Color {
        textColor == .light ? .white : .black
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Left accent line
            Rectangle()
                .fill(primaryColor.opacity(0.25))
                .frame(width: 1)
                .padding(.vertical, 12)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(factlet.category.uppercased())
                    .font(.custom("TimesNewRomanPS-BoldMT", size: 9))
                    .kerning(2)
                    .foregroundColor(primaryColor.opacity(0.5))
                
                Text(factlet.fact)
                    .font(.custom("TimesNewRomanPSMT", size: 15))
                    .lineSpacing(5)
                    .foregroundColor(primaryColor.opacity(0.95))
                    .lineLimit(4)
                
                Spacer()
            }
            .padding(.vertical, 12)
            
            Spacer()
        }
        .padding(.leading, 16)
    }
}

// MARK: - Large Widget
struct LargeWidgetView: View {
    let factlet: Factlet
    let textColor: WidgetTextColor
    
    private var primaryColor: Color {
        textColor == .light ? .white : .black
    }
    
    var body: some View {
        VStack(spacing: 20) {
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
            
            Rectangle()
                .fill(primaryColor.opacity(0.25))
                .frame(width: 30, height: 1)
            
            Spacer()
            
            // Branding
            Text("Factlet")
                .font(.custom("TimesNewRomanPS-ItalicMT", size: 12))
                .foregroundColor(primaryColor.opacity(0.35))
                .padding(.bottom, 12)
        }
        .padding(16)
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
                .containerBackground(.clear, for: .widget)
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
