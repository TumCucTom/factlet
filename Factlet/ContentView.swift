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
    
    private var categories: [FactletCategory] {
        FactletCategory.allCases
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.98, green: 0.97, blue: 0.95)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 40) {
                        // Levels Section
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("DIFFICULTY LEVEL")
                                    .font(.custom("TimesNewRomanPS-BoldMT", size: 11))
                                    .kerning(2.5)
                                    .foregroundColor(.black.opacity(0.4))
                                
                                Text("Choose which difficulty levels to include.")
                                    .font(.custom("TimesNewRomanPSMT", size: 15))
                                    .foregroundColor(.black.opacity(0.6))
                                    .lineSpacing(4)
                            }
                            .padding(.horizontal, 28)
                            
                            // Level Buttons
                            HStack(spacing: 12) {
                                ForEach(FactletLevel.allCases, id: \.self) { level in
                                    LevelButton(
                                        level: level,
                                        isSelected: manager.isLevelSelected(level),
                                        count: countForLevel(level)
                                    ) {
                                        manager.toggleLevel(level)
                                    }
                                }
                            }
                            .padding(.horizontal, 28)
                        }
                        .padding(.top, 20)
                        
                        // Topics Section
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("FILTER BY TOPIC")
                                    .font(.custom("TimesNewRomanPS-BoldMT", size: 11))
                                    .kerning(2.5)
                                    .foregroundColor(.black.opacity(0.4))
                                
                                Text("Choose which topics appear in the app and widget.")
                                    .font(.custom("TimesNewRomanPSMT", size: 15))
                                    .foregroundColor(.black.opacity(0.6))
                                    .lineSpacing(4)
                            }
                            .padding(.horizontal, 28)
                            
                            // Category Grid
                            LazyVGrid(columns: [
                                GridItem(.flexible(), spacing: 12),
                                GridItem(.flexible(), spacing: 12)
                            ], spacing: 12) {
                                ForEach(categories, id: \.self) { category in
                                    TopicButton(
                                        category: category,
                                        isSelected: manager.isCategorySelected(category),
                                        count: countForCategory(category)
                                    ) {
                                        manager.toggleCategory(category)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Topics")
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
            return FactletCollection.all.filter { manager.selectedLevels.contains($0.level) }.count
        }
        return FactletCollection.all.filter { 
            $0.category == category.rawValue && manager.selectedLevels.contains($0.level)
        }.count
    }
    
    private func countForLevel(_ level: FactletLevel) -> Int {
        if manager.selectedCategories.contains(.all) {
            return FactletCollection.all.filter { $0.level == level }.count
        }
        return FactletCollection.all.filter { factlet in
            factlet.level == level && manager.selectedCategories.contains { category in
                category.rawValue == factlet.category
            }
        }.count
    }
}

// MARK: - Level Button
struct LevelButton: View {
    let level: FactletLevel
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(level.displayName)
                    .font(.custom("TimesNewRomanPSMT", size: 16))
                    .foregroundColor(.black.opacity(isSelected ? 0.9 : 0.5))
                
                Text("\(count)")
                    .font(.custom("TimesNewRomanPSMT", size: 12))
                    .foregroundColor(.black.opacity(0.35))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isSelected ? Color.black.opacity(0.05) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.black.opacity(isSelected ? 0.15 : 0.08), lineWidth: 1)
            )
        }
    }
}

// MARK: - Topic Button
struct TopicButton: View {
    let category: FactletCategory
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(category.displayName)
                        .font(.custom("TimesNewRomanPSMT", size: 16))
                        .foregroundColor(.black.opacity(isSelected ? 0.9 : 0.5))
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black.opacity(0.6))
                    }
                }
                
                Text("\(count) factlets")
                    .font(.custom("TimesNewRomanPSMT", size: 12))
                    .foregroundColor(.black.opacity(0.35))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isSelected ? Color.black.opacity(0.05) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.black.opacity(isSelected ? 0.15 : 0.08), lineWidth: 1)
            )
        }
    }
}

#Preview {
    ContentView()
}
