//
//  OnboardingView.swift
//  Factlet
//
//  Onboarding flow for first-time users
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var manager = FactletManager.shared
    @State private var currentStep = 0
    @State private var selectedCategories: Set<FactletCategory> = []
    @State private var categoryLevels: [String: Set<FactletLevel>] = [:]
    @State private var refreshInterval: RefreshInterval = .hourly
    @State private var notificationFrequency: NotificationFrequency = .off
    @State private var showNotificationPermission = false
    
    private let totalSteps = 4
    
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.97, blue: 0.95)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<totalSteps, id: \.self) { index in
                        Rectangle()
                            .fill(index <= currentStep ? Color.black.opacity(0.3) : Color.black.opacity(0.1))
                            .frame(height: 2)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 60)
                .padding(.bottom, 40)
                
                // Content
                Group {
                    switch currentStep {
                    case 0:
                        CategoriesOnboardingStep(selectedCategories: $selectedCategories, categoryLevels: $categoryLevels)
                    case 1:
                        LevelsOnboardingStep(selectedCategories: selectedCategories, categoryLevels: $categoryLevels)
                    case 2:
                        RefreshIntervalOnboardingStep(refreshInterval: $refreshInterval)
                    case 3:
                        NotificationsOnboardingStep(notificationFrequency: $notificationFrequency, showPermission: $showNotificationPermission)
                    default:
                        CategoriesOnboardingStep(selectedCategories: $selectedCategories, categoryLevels: $categoryLevels)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Navigation buttons
                HStack(spacing: 20) {
                    if currentStep > 0 {
                        Button(action: {
                            withAnimation {
                                currentStep -= 1
                            }
                        }) {
                            Text("Back")
                                .font(.custom("TimesNewRomanPSMT", size: 16))
                                .foregroundColor(.black.opacity(0.6))
                                .padding(.vertical, 14)
                                .padding(.horizontal, 32)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 0)
                                        .stroke(Color.black.opacity(0.15), lineWidth: 1)
                                )
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if currentStep < totalSteps - 1 {
                            withAnimation {
                                currentStep += 1
                            }
                        } else {
                            completeOnboarding()
                        }
                    }) {
                        Text(currentStep < totalSteps - 1 ? "Next" : "Get Started")
                            .font(.custom("TimesNewRomanPSMT", size: 16))
                            .foregroundColor(currentStep < totalSteps - 1 ? .black.opacity(0.85) : .black.opacity(0.9))
                            .padding(.vertical, 14)
                            .padding(.horizontal, 32)
                            .background(
                                currentStep < totalSteps - 1 
                                    ? Color.black.opacity(0.1)
                                    : Color.black.opacity(0.15)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 0)
                                    .stroke(
                                        currentStep < totalSteps - 1 
                                            ? Color.black.opacity(0.2)
                                            : Color.black.opacity(0.3),
                                        lineWidth: currentStep < totalSteps - 1 ? 1 : 1.5
                                    )
                            )
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
    }
    
    private func completeOnboarding() {
        // Apply selected categories
        if selectedCategories.isEmpty {
            manager.selectedCategories = [.all]
        } else {
            manager.selectedCategories = selectedCategories
        }
        
        // Apply category levels
        if categoryLevels.isEmpty {
            // Default: all levels for all categories
            var defaultLevels: [String: Set<FactletLevel>] = [:]
            let categoriesToSet = selectedCategories.isEmpty ? 
                Set(FactletCategory.allCases.filter { $0 != .all }) : selectedCategories
            for category in categoriesToSet {
                defaultLevels[category.rawValue] = Set(FactletLevel.allCases)
            }
            manager.categoryLevels = defaultLevels
        } else {
            manager.categoryLevels = categoryLevels
        }
        
        // Apply refresh interval
        manager.setRefreshInterval(refreshInterval)
        
        // Handle notifications
        if notificationFrequency != .off {
            manager.requestNotificationPermission { granted in
                if granted {
                    manager.setNotificationFrequency(notificationFrequency)
                }
                manager.completeOnboarding()
            }
        } else {
            manager.completeOnboarding()
        }
    }
}

// MARK: - Step 1: Categories
struct CategoriesOnboardingStep: View {
    @Binding var selectedCategories: Set<FactletCategory>
    @Binding var categoryLevels: [String: Set<FactletLevel>]
    
    private var categories: [FactletCategory] {
        FactletCategory.allCases.filter { $0 != .all }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                VStack(spacing: 16) {
                    Text("Choose Your Topics")
                        .font(.custom("TimesNewRomanPSMT", size: 32))
                        .foregroundColor(.black.opacity(0.85))
                        .multilineTextAlignment(.center)
                    
                    Text("Select the categories you'd like to explore. You can change this later in settings.")
                        .font(.custom("TimesNewRomanPSMT", size: 16))
                        .foregroundColor(.black.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 40)
                
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12)
                ], spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            OnboardingCategoryButton(
                                category: category,
                                isSelected: selectedCategories.contains(category),
                                count: countForCategory(category)
                            ) {
                                if selectedCategories.contains(category) {
                                    selectedCategories.remove(category)
                                    categoryLevels.removeValue(forKey: category.rawValue)
                                } else {
                                    selectedCategories.insert(category)
                                    // Initialize with all levels if not already set
                                    if categoryLevels[category.rawValue] == nil {
                                        categoryLevels[category.rawValue] = Set(FactletLevel.allCases)
                                    }
                                }
                            }
                        }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func countForCategory(_ category: FactletCategory) -> Int {
        FactletCollection.all.filter { $0.category == category.rawValue }.count
    }
}

// MARK: - Step 2: Levels
struct LevelsOnboardingStep: View {
    let selectedCategories: Set<FactletCategory>
    @Binding var categoryLevels: [String: Set<FactletLevel>]
    
    private var categories: [FactletCategory] {
        if selectedCategories.isEmpty {
            return FactletCategory.allCases.filter { $0 != .all }
        }
        return Array(selectedCategories).sorted { $0.displayName < $1.displayName }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                VStack(spacing: 16) {
                    Text("Choose Difficulty Levels")
                        .font(.custom("TimesNewRomanPSMT", size: 32))
                        .foregroundColor(.black.opacity(0.85))
                        .multilineTextAlignment(.center)
                    
                    Text("Select difficulty levels for each topic. You can choose different levels for different topics.")
                        .font(.custom("TimesNewRomanPSMT", size: 16))
                        .foregroundColor(.black.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 40)
                
                VStack(spacing: 16) {
                    ForEach(categories, id: \.self) { category in
                        OnboardingCategoryLevelCard(
                            category: category,
                            selectedLevels: getLevelsForCategory(category),
                            count: countForCategory(category)
                        ) { level in
                            toggleLevel(level, for: category)
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
            }
        }
    }
    
    private func getLevelsForCategory(_ category: FactletCategory) -> Set<FactletLevel> {
        categoryLevels[category.rawValue] ?? Set(FactletLevel.allCases)
    }
    
    private func toggleLevel(_ level: FactletLevel, for category: FactletCategory) {
        var levels = categoryLevels[category.rawValue] ?? Set(FactletLevel.allCases)
        
        if levels.contains(level) {
            levels.remove(level)
            if levels.isEmpty {
                levels.insert(.level1)
            }
        } else {
            levels.insert(level)
        }
        
        categoryLevels[category.rawValue] = levels
    }
    
    private func countForCategory(_ category: FactletCategory) -> Int {
        let levels = getLevelsForCategory(category)
        return FactletCollection.all.filter { 
            $0.category == category.rawValue && levels.contains($0.level)
        }.count
    }
}

// MARK: - Step 3: Refresh Interval
struct RefreshIntervalOnboardingStep: View {
    @Binding var refreshInterval: RefreshInterval
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 16) {
                Text("Widget Refresh")
                    .font(.custom("TimesNewRomanPSMT", size: 32))
                    .foregroundColor(.black.opacity(0.85))
                    .multilineTextAlignment(.center)
                
                Text("How often would you like the widget to update with a new factlet?")
                    .font(.custom("TimesNewRomanPSMT", size: 16))
                    .foregroundColor(.black.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
            }
            .padding(.top, 60)
            
            VStack(spacing: 0) {
                ForEach(RefreshInterval.allCases, id: \.self) { interval in
                    Button(action: {
                        refreshInterval = interval
                    }) {
                        HStack {
                            Text(interval.displayName)
                                .font(.custom("TimesNewRomanPSMT", size: 20))
                                .foregroundColor(.black.opacity(0.85))
                            
                            Spacer()
                            
                            if refreshInterval == interval {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black.opacity(0.6))
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.vertical, 20)
                        .background(
                            refreshInterval == interval
                                ? Color.black.opacity(0.05)
                                : Color.clear
                        )
                    }
                    
                    if interval != RefreshInterval.allCases.last {
                        Rectangle()
                            .fill(Color.black.opacity(0.08))
                            .frame(height: 1)
                            .padding(.horizontal, 40)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
}

// MARK: - Step 4: Notifications
struct NotificationsOnboardingStep: View {
    @Binding var notificationFrequency: NotificationFrequency
    @Binding var showPermission: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            VStack(spacing: 16) {
                Text("Notifications")
                    .font(.custom("TimesNewRomanPSMT", size: 32))
                    .foregroundColor(.black.opacity(0.85))
                    .multilineTextAlignment(.center)
                
                Text("Would you like to receive factlets as notifications? You can change this later.")
                    .font(.custom("TimesNewRomanPSMT", size: 16))
                    .foregroundColor(.black.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
            }
            .padding(.top, 60)
            
            VStack(spacing: 0) {
                ForEach(NotificationFrequency.allCases, id: \.self) { frequency in
                    Button(action: {
                        notificationFrequency = frequency
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(frequency.displayName)
                                    .font(.custom("TimesNewRomanPSMT", size: 20))
                                    .foregroundColor(.black.opacity(0.85))
                                
                                if frequency != .off {
                                    Text(frequencyDescription(frequency))
                                        .font(.custom("TimesNewRomanPSMT", size: 14))
                                        .foregroundColor(.black.opacity(0.4))
                                }
                            }
                            
                            Spacer()
                            
                            if notificationFrequency == frequency {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.black.opacity(0.6))
                            }
                        }
                        .padding(.horizontal, 40)
                        .padding(.vertical, 20)
                        .background(
                            notificationFrequency == frequency
                                ? Color.black.opacity(0.05)
                                : Color.clear
                        )
                    }
                    
                    if frequency != NotificationFrequency.allCases.last {
                        Rectangle()
                            .fill(Color.black.opacity(0.08))
                            .frame(height: 1)
                            .padding(.horizontal, 40)
                    }
                }
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
    }
    
    private func frequencyDescription(_ frequency: NotificationFrequency) -> String {
        switch frequency {
        case .off: return ""
        case .hourly: return "~24 factlets per day"
        case .everyThreeHours: return "~8 factlets per day"
        case .everySixHours: return "~4 factlets per day"
        case .twiceDaily: return "Morning & evening"
        case .daily: return "Once per day"
        }
    }
}

// MARK: - Onboarding Buttons
struct OnboardingCategoryButton: View {
    let category: FactletCategory
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(category.displayName)
                        .font(.custom("TimesNewRomanPSMT", size: 18))
                        .foregroundColor(.black.opacity(isSelected ? 0.9 : 0.5))
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.black.opacity(0.6))
                    }
                }
                
                Text("\(count) factlets")
                    .font(.custom("TimesNewRomanPSMT", size: 13))
                    .foregroundColor(.black.opacity(0.35))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isSelected ? Color.black.opacity(0.08) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.black.opacity(isSelected ? 0.2 : 0.1), lineWidth: 1)
            )
        }
    }
}

struct OnboardingLevelButton: View {
    let level: FactletLevel
    let isSelected: Bool
    let count: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(level.displayName)
                        .font(.custom("TimesNewRomanPSMT", size: 20))
                        .foregroundColor(.black.opacity(isSelected ? 0.9 : 0.5))
                    
                    Text("\(count) factlets")
                        .font(.custom("TimesNewRomanPSMT", size: 14))
                        .foregroundColor(.black.opacity(0.35))
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black.opacity(0.6))
                }
            }
            .padding(.horizontal, 28)
            .padding(.vertical, 20)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isSelected ? Color.black.opacity(0.08) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.black.opacity(isSelected ? 0.2 : 0.1), lineWidth: 1)
            )
        }
    }
}

// MARK: - Onboarding Category Level Card
struct OnboardingCategoryLevelCard: View {
    let category: FactletCategory
    let selectedLevels: Set<FactletLevel>
    let count: Int
    let onLevelToggle: (FactletLevel) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(category.displayName)
                .font(.custom("TimesNewRomanPSMT", size: 18))
                .foregroundColor(.black.opacity(0.85))
            
            Text("\(count) factlets")
                .font(.custom("TimesNewRomanPSMT", size: 13))
                .foregroundColor(.black.opacity(0.35))
            
            HStack(spacing: 12) {
                ForEach(FactletLevel.allCases, id: \.self) { level in
                    Button(action: {
                        onLevelToggle(level)
                    }) {
                        Text(level.displayName)
                            .font(.custom("TimesNewRomanPSMT", size: 14))
                            .foregroundColor(.black.opacity(selectedLevels.contains(level) ? 0.85 : 0.4))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(selectedLevels.contains(level) ? Color.black.opacity(0.08) : Color.clear)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.black.opacity(selectedLevels.contains(level) ? 0.2 : 0.1), lineWidth: 1)
                            )
                    }
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.black.opacity(0.02))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.black.opacity(0.1), lineWidth: 1)
        )
    }
}

#Preview {
    OnboardingView()
}

