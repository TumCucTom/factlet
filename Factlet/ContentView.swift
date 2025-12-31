//
//  ContentView.swift
//  Factlet
//
//  Main view displaying the current factlet
//

import SwiftUI

struct ContentView: View {
    @StateObject private var manager = FactletManager.shared
    @State private var showSettings = false
    @State private var showTopics = false
    @State private var isAnimating = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color(red: 0.98, green: 0.97, blue: 0.95)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        // Topics filter button
                        Button(action: { showTopics = true }) {
                            HStack(spacing: 6) {
                                Image(systemName: "line.3.horizontal.decrease")
                                    .font(.system(size: 14, weight: .light))
                                Text(topicsButtonLabel)
                                    .font(.custom("TimesNewRomanPSMT", size: 14))
                            }
                            .foregroundColor(.black.opacity(0.6))
                        }
                        
                        Spacer()
                        
                        Button(action: { showSettings = true }) {
                            Image(systemName: "gearshape")
                                .font(.system(size: 20, weight: .light))
                                .foregroundColor(.black.opacity(0.6))
                        }
                    }
                    .padding(.horizontal, 28)
                    .padding(.top, 16)
                    
                    Spacer()
                    
                    // Main Content
                    VStack(spacing: 40) {
                        // Category
                        Text(manager.currentFactlet.category.uppercased())
                            .font(.custom("TimesNewRomanPS-BoldMT", size: 11))
                            .kerning(2.5)
                            .foregroundColor(.black.opacity(0.4))
                        
                        // Factlet
                        Text(manager.currentFactlet.fact)
                            .font(.custom("TimesNewRomanPSMT", size: 24))
                            .lineSpacing(10)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black.opacity(0.85))
                            .padding(.horizontal, 36)
                            .opacity(isAnimating ? 0 : 1)
                        
                        // Divider
                        Rectangle()
                            .fill(Color.black.opacity(0.15))
                            .frame(width: 40, height: 1)
                    }
                    .frame(maxWidth: min(geometry.size.width, 500))
                    
                    Spacer()
                    
                    // Refresh Button
                    Button(action: {
                        withAnimation(.easeOut(duration: 0.15)) {
                            isAnimating = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                            manager.refreshFactlet()
                            withAnimation(.easeIn(duration: 0.25)) {
                                isAnimating = false
                            }
                        }
                    }) {
                        Text("New Factlet")
                            .font(.custom("TimesNewRomanPSMT", size: 15))
                            .kerning(0.5)
                            .foregroundColor(.black.opacity(0.5))
                            .padding(.vertical, 14)
                            .padding(.horizontal, 32)
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(Color.black.opacity(0.15), lineWidth: 1)
                            )
                    }
                    .padding(.bottom, 60)
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showTopics) {
            TopicsView()
        }
        .onAppear {
            manager.checkAndRefreshIfNeeded()
        }
    }
    
    private var topicsButtonLabel: String {
        if manager.selectedCategories.contains(.all) {
            return "All Topics"
        } else if manager.selectedCategories.count == 1 {
            return manager.selectedCategories.first?.displayName ?? "Topics"
        } else {
            return "\(manager.selectedCategories.count) Topics"
        }
    }
}

// MARK: - Topics View
struct TopicsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var manager = FactletManager.shared
    @State private var expandedCategory: FactletCategory? = nil
    
    private var categories: [FactletCategory] {
        FactletCategory.allCases
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.98, green: 0.97, blue: 0.95)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 32) {
                        // Section Header
                        VStack(alignment: .leading, spacing: 12) {
                            Text("FILTER BY TOPIC")
                                .font(.custom("TimesNewRomanPS-BoldMT", size: 11))
                                .kerning(2.5)
                                .foregroundColor(.black.opacity(0.4))
                            
                            Text("Choose topics and set difficulty levels for each.")
                                .font(.custom("TimesNewRomanPSMT", size: 15))
                                .foregroundColor(.black.opacity(0.6))
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 28)
                        .padding(.top, 20)
                        
                        // Category List with Levels
                        VStack(spacing: 12) {
                            ForEach(categories, id: \.self) { category in
                                CategoryLevelCard(
                                    category: category,
                                    isSelected: manager.isCategorySelected(category),
                                    selectedLevels: manager.getLevelsForCategory(category),
                                    isExpanded: expandedCategory == category,
                                    count: countForCategory(category)
                                ) {
                                    manager.toggleCategory(category)
                                } onLevelToggle: { level in
                                    manager.toggleLevel(level, for: category)
                                } onExpandToggle: {
                                    withAnimation {
                                        expandedCategory = expandedCategory == category ? nil : category
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Topics & Levels")
                        .font(.custom("TimesNewRomanPSMT", size: 17))
                        .foregroundColor(.black.opacity(0.85))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(.custom("TimesNewRomanPSMT", size: 16))
                    .foregroundColor(.black.opacity(0.6))
                }
            }
        }
    }
    
    private func countForCategory(_ category: FactletCategory) -> Int {
        if category == .all {
            return FactletCollection.all.count
        }
        let levels = manager.getLevelsForCategory(category)
        return FactletCollection.all.filter { 
            $0.category == category.rawValue && levels.contains($0.level)
        }.count
    }
}

// MARK: - Category Level Card
struct CategoryLevelCard: View {
    let category: FactletCategory
    let isSelected: Bool
    let selectedLevels: Set<FactletLevel>
    let isExpanded: Bool
    let count: Int
    let onToggle: () -> Void
    let onLevelToggle: (FactletLevel) -> Void
    let onExpandToggle: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Category Header
            Button(action: {
                if category != .all {
                    onToggle()
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(category.displayName)
                            .font(.custom("TimesNewRomanPSMT", size: 18))
                            .foregroundColor(.black.opacity(isSelected ? 0.9 : 0.5))
                        
                        Text("\(count) factlets")
                            .font(.custom("TimesNewRomanPSMT", size: 13))
                            .foregroundColor(.black.opacity(0.35))
                    }
                    
                    Spacer()
                    
                    if category != .all {
                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.black.opacity(0.6))
                        }
                        
                        Button(action: onExpandToggle) {
                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.black.opacity(0.4))
                        }
                        .padding(.leading, 8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(isSelected ? Color.black.opacity(0.05) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(Color.black.opacity(isSelected ? 0.15 : 0.08), lineWidth: 1)
                )
            }
            .disabled(category == .all)
            
            // Levels (expanded view)
            if isExpanded && category != .all {
                VStack(spacing: 0) {
                    Rectangle()
                        .fill(Color.black.opacity(0.08))
                        .frame(height: 1)
                        .padding(.horizontal, 20)
                    
                    VStack(spacing: 0) {
                        ForEach(FactletLevel.allCases, id: \.self) { level in
                            Button(action: {
                                onLevelToggle(level)
                            }) {
                                HStack {
                                    Text(level.displayName)
                                        .font(.custom("TimesNewRomanPSMT", size: 16))
                                        .foregroundColor(.black.opacity(selectedLevels.contains(level) ? 0.85 : 0.4))
                                    
                                    Spacer()
                                    
                                    if selectedLevels.contains(level) {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(.black.opacity(0.6))
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(
                                    selectedLevels.contains(level) ? Color.black.opacity(0.03) : Color.clear
                                )
                            }
                            
                            if level != FactletLevel.allCases.last {
                                Rectangle()
                                    .fill(Color.black.opacity(0.05))
                                    .frame(height: 1)
                                    .padding(.horizontal, 20)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.black.opacity(0.02))
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
