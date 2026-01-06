//
//  FactletManager.swift
//  Factlet
//
//  Manages factlet selection, storage, and refresh intervals
//

import Foundation
import WidgetKit
import UserNotifications

// MARK: - Refresh Interval
enum RefreshInterval: String, CaseIterable, Codable {
    case hourly = "Every Hour"
    case halfDay = "Half Day"
    case daily = "Daily"
    
    var timeInterval: TimeInterval {
        switch self {
        case .hourly: return 60 * 60
        case .halfDay: return 12 * 60 * 60
        case .daily: return 24 * 60 * 60
        }
    }
    
    var displayName: String {
        return rawValue
    }
}

// MARK: - Notification Frequency
enum NotificationFrequency: String, CaseIterable, Codable {
    case off = "Off"
    case hourly = "Hourly"
    case everyThreeHours = "Every 3 Hours"
    case everySixHours = "Every 6 Hours"
    case twiceDaily = "Twice Daily"
    case daily = "Daily"
    
    var timeInterval: TimeInterval? {
        switch self {
        case .off: return nil
        case .hourly: return 60 * 60
        case .everyThreeHours: return 3 * 60 * 60
        case .everySixHours: return 6 * 60 * 60
        case .twiceDaily: return 12 * 60 * 60
        case .daily: return 24 * 60 * 60
        }
    }
    
    var displayName: String {
        return rawValue
    }
}

// MARK: - Text Color Option
enum WidgetTextColor: String, CaseIterable, Codable {
    case light = "Light"
    case dark = "Dark"
    
    var displayName: String {
        return rawValue
    }
    
    var primaryColor: Double {
        switch self {
        case .light: return 1.0
        case .dark: return 0.0
        }
    }
}

// MARK: - Category
enum FactletCategory: String, CaseIterable, Codable {
    case all = "All"
    case science = "Science"
    case history = "History"
    case nature = "Nature"
    case language = "Language"
    case culture = "Culture"
    case humanBody = "The Body"
    case geography = "Geography"
    case technology = "Technology"
    
    var displayName: String {
        return rawValue
    }
}

// MARK: - Factlet Manager
class FactletManager: ObservableObject {
    static let shared = FactletManager()
    
    private let suiteName = "group.com.factlet.app"
    private let currentFactletKey = "currentFactlet"
    private let lastUpdateKey = "lastUpdate"
    private let refreshIntervalKey = "refreshInterval"
    private let textColorKey = "textColor"
    private let selectedCategoriesKey = "selectedCategories"
    private let selectedLevelsKey = "selectedLevels"
    private let categoryLevelsKey = "categoryLevels"
    private let notificationFrequencyKey = "notificationFrequency"
    private let notificationsEnabledKey = "notificationsEnabled"
    private let onboardingCompletedKey = "onboardingCompleted"
    
    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }
    
    @Published var currentFactlet: Factlet
    @Published var refreshInterval: RefreshInterval
    @Published var textColor: WidgetTextColor
    @Published var selectedCategories: Set<FactletCategory>
    @Published var selectedLevels: Set<FactletLevel> // Legacy - kept for migration
    @Published var categoryLevels: [String: Set<FactletLevel>] // Category -> Levels mapping
    @Published var notificationFrequency: NotificationFrequency
    @Published var notificationsEnabled: Bool
    @Published var onboardingCompleted: Bool
    
    private init() {
        let defaults = UserDefaults(suiteName: "group.com.factlet.app")
        
        // Load saved interval or default to hourly
        if let savedIntervalString = defaults?.string(forKey: "refreshInterval"),
           let savedInterval = RefreshInterval(rawValue: savedIntervalString) {
            self.refreshInterval = savedInterval
        } else {
            // Migrate old values
            if let oldInterval = defaults?.string(forKey: "refreshInterval") {
                if oldInterval == "15 Minutes" || oldInterval == "30 Minutes" {
                    self.refreshInterval = .hourly
                } else {
                    self.refreshInterval = .hourly
                }
            } else {
                self.refreshInterval = .hourly
            }
        }
        
        // Load text color
        if let savedColorString = defaults?.string(forKey: "textColor"),
           let savedColor = WidgetTextColor(rawValue: savedColorString) {
            self.textColor = savedColor
        } else {
            self.textColor = .dark
        }
        
        // Load selected categories
        if let savedCategoriesData = defaults?.data(forKey: "selectedCategories"),
           let savedCategories = try? JSONDecoder().decode(Set<FactletCategory>.self, from: savedCategoriesData) {
            self.selectedCategories = savedCategories
        } else {
            self.selectedCategories = [.all]
        }
        
        // Load category levels (per-category level selection)
        if let savedCategoryLevelsData = defaults?.data(forKey: "categoryLevels"),
           let savedCategoryLevels = try? JSONDecoder().decode([String: Set<FactletLevel>].self, from: savedCategoryLevelsData) {
            self.categoryLevels = savedCategoryLevels
        } else {
            // Migrate from old selectedLevels if exists
            if let savedLevelsData = defaults?.data(forKey: "selectedLevels"),
               let savedLevels = try? JSONDecoder().decode(Set<FactletLevel>.self, from: savedLevelsData) {
                // Migrate: apply same levels to all categories
                var migratedLevels: [String: Set<FactletLevel>] = [:]
                for category in FactletCategory.allCases where category != .all {
                    migratedLevels[category.rawValue] = savedLevels
                }
                self.categoryLevels = migratedLevels
            } else {
                // Default: all levels for all categories
                var defaultLevels: [String: Set<FactletLevel>] = [:]
                for category in FactletCategory.allCases where category != .all {
                    defaultLevels[category.rawValue] = Set(FactletLevel.allCases)
                }
                self.categoryLevels = defaultLevels
            }
        }
        
        // Legacy support
        self.selectedLevels = Set(FactletLevel.allCases)
        
        // Load notification frequency
        if let savedFrequencyString = defaults?.string(forKey: "notificationFrequency"),
           let savedFrequency = NotificationFrequency(rawValue: savedFrequencyString) {
            self.notificationFrequency = savedFrequency
        } else {
            self.notificationFrequency = .off
        }
        
        // Load notifications enabled state
        self.notificationsEnabled = defaults?.bool(forKey: "notificationsEnabled") ?? false
        
        // Load onboarding completion
        self.onboardingCompleted = defaults?.bool(forKey: onboardingCompletedKey) ?? false
        
        // Load saved factlet or get a new one
        if let data = defaults?.data(forKey: "currentFactlet"),
           let factlet = try? JSONDecoder().decode(Factlet.self, from: data) {
            self.currentFactlet = factlet
        } else {
            self.currentFactlet = FactletCollection.random()
            self.save()
        }
    }
    
    func save() {
        guard let userDefaults = userDefaults else { return }
        
        if let data = try? JSONEncoder().encode(currentFactlet) {
            userDefaults.set(data, forKey: currentFactletKey)
        }
        userDefaults.set(refreshInterval.rawValue, forKey: refreshIntervalKey)
        userDefaults.set(textColor.rawValue, forKey: textColorKey)
        userDefaults.set(notificationFrequency.rawValue, forKey: notificationFrequencyKey)
        userDefaults.set(notificationsEnabled, forKey: notificationsEnabledKey)
        
        if let categoriesData = try? JSONEncoder().encode(selectedCategories) {
            userDefaults.set(categoriesData, forKey: selectedCategoriesKey)
        }
        
        if let categoryLevelsData = try? JSONEncoder().encode(categoryLevels) {
            userDefaults.set(categoryLevelsData, forKey: categoryLevelsKey)
        }
        
        userDefaults.set(Date(), forKey: lastUpdateKey)
    }
    
    func getFilteredFactlets() -> [Factlet] {
        var filtered = FactletCollection.all
        
        // Filter by category
        let categoriesToCheck: Set<FactletCategory>
        if selectedCategories.contains(.all) {
            categoriesToCheck = Set(FactletCategory.allCases.filter { $0 != .all })
        } else {
            categoriesToCheck = selectedCategories
        }
        
        filtered = filtered.filter { factlet in
            // Check if category is selected
            let categoryMatches = categoriesToCheck.contains { category in
                category.rawValue == factlet.category
            }
            
            guard categoryMatches else { return false }
            
            // Check if level is selected for this category
            let levelsForCategory = categoryLevels[factlet.category] ?? Set(FactletLevel.allCases)
            return levelsForCategory.contains(factlet.level)
        }
        
        return filtered
    }
    
    func getRandomFilteredFactlet() -> Factlet {
        let filtered = getFilteredFactlets()
        if filtered.isEmpty {
            return FactletCollection.random()
        } else if filtered.count == 1 {
            return filtered[0]
        } else {
            var newFactlet = filtered.randomElement() ?? FactletCollection.random()
            while newFactlet.id == currentFactlet.id && filtered.count > 1 {
                newFactlet = filtered.randomElement() ?? FactletCollection.random()
            }
            return newFactlet
        }
    }
    
    func refreshFactlet() {
        currentFactlet = getRandomFilteredFactlet()
        save()
        // Reload timelines after a brief delay to ensure UserDefaults sync completes
        // This helps lockscreen widgets get the updated data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    func setRefreshInterval(_ interval: RefreshInterval) {
        refreshInterval = interval
        save()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func setTextColor(_ color: WidgetTextColor) {
        textColor = color
        save()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func toggleCategory(_ category: FactletCategory) {
        if category == .all {
            selectedCategories = [.all]
        } else {
            selectedCategories.remove(.all)
            if selectedCategories.contains(category) {
                selectedCategories.remove(category)
                if selectedCategories.isEmpty {
                    selectedCategories = [.all]
                }
            } else {
                selectedCategories.insert(category)
            }
        }
        save()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func isCategorySelected(_ category: FactletCategory) -> Bool {
        return selectedCategories.contains(category)
    }
    
    func toggleLevel(_ level: FactletLevel, for category: FactletCategory) {
        guard category != .all else { return }
        
        var levels = categoryLevels[category.rawValue] ?? Set(FactletLevel.allCases)
        
        if levels.contains(level) {
            levels.remove(level)
            // Ensure at least one level is selected
            if levels.isEmpty {
                levels.insert(.level1)
            }
        } else {
            levels.insert(level)
        }
        
        categoryLevels[category.rawValue] = levels
        save()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func isLevelSelected(_ level: FactletLevel, for category: FactletCategory) -> Bool {
        guard category != .all else { return false }
        let levels = categoryLevels[category.rawValue] ?? Set(FactletLevel.allCases)
        return levels.contains(level)
    }
    
    func getLevelsForCategory(_ category: FactletCategory) -> Set<FactletLevel> {
        guard category != .all else { return Set(FactletLevel.allCases) }
        return categoryLevels[category.rawValue] ?? Set(FactletLevel.allCases)
    }
    
    // Legacy methods for backward compatibility
    func toggleLevel(_ level: FactletLevel) {
        // Apply to all selected categories
        let categoriesToUpdate = selectedCategories.contains(.all) ?
            Set(FactletCategory.allCases.filter { $0 != .all }) : selectedCategories
        
        for category in categoriesToUpdate {
            toggleLevel(level, for: category)
        }
    }
    
    func isLevelSelected(_ level: FactletLevel) -> Bool {
        // Check if level is selected in any selected category
        let categoriesToCheck = selectedCategories.contains(.all) ?
            Set(FactletCategory.allCases.filter { $0 != .all }) : selectedCategories
        
        return categoriesToCheck.contains { category in
            isLevelSelected(level, for: category)
        }
    }
    
    func shouldRefresh() -> Bool {
        guard let lastUpdate = userDefaults?.object(forKey: lastUpdateKey) as? Date else {
            return true
        }
        return Date().timeIntervalSince(lastUpdate) >= refreshInterval.timeInterval
    }
    
    func checkAndRefreshIfNeeded() {
        if shouldRefresh() {
            refreshFactlet()
        }
    }
    
    // MARK: - Notification Methods
    
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                self.notificationsEnabled = granted
                self.save()
                if granted {
                    self.scheduleNotifications()
                }
                completion(granted)
            }
        }
    }
    
    func checkNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                let isAuthorized = settings.authorizationStatus == .authorized
                completion(isAuthorized)
            }
        }
    }
    
    func setNotificationFrequency(_ frequency: NotificationFrequency) {
        notificationFrequency = frequency
        save()
        
        if frequency == .off {
            cancelAllNotifications()
        } else {
            scheduleNotifications()
        }
    }
    
    func scheduleNotifications() {
        // Cancel existing notifications first
        cancelAllNotifications()
        
        guard notificationFrequency != .off,
              let interval = notificationFrequency.timeInterval else {
            return
        }
        
        // Schedule multiple notifications in advance (iOS limits to 64)
        let maxNotifications = 60
        let filteredFactlets = getFilteredFactlets()
        
        for i in 0..<maxNotifications {
            let factlet = filteredFactlets.randomElement() ?? FactletCollection.random()
            let triggerDate = Date().addingTimeInterval(interval * Double(i + 1))
            
            let content = UNMutableNotificationContent()
            content.title = factlet.category
            content.body = factlet.fact
            content.sound = .default
            content.userInfo = ["factletId": factlet.id.uuidString]
            
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: interval * Double(i + 1),
                repeats: false
            )
            
            let request = UNNotificationRequest(
                identifier: "factlet-\(i)",
                content: content,
                trigger: trigger
            )
            
            UNUserNotificationCenter.current().add(request)
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func handleNotificationReceived() {
        // When notification is tapped, refresh the factlet and widget
        refreshFactlet()
    }
    
    func completeOnboarding() {
        guard let userDefaults = userDefaults else { return }
        onboardingCompleted = true
        userDefaults.set(true, forKey: onboardingCompletedKey)
        save()
    }
    
    // MARK: - Static methods for widget use
    static func getCurrentFactlet() -> Factlet {
        let suiteName = "group.com.factlet.app"
        if let data = UserDefaults(suiteName: suiteName)?.data(forKey: "currentFactlet"),
           let factlet = try? JSONDecoder().decode(Factlet.self, from: data) {
            return factlet
        }
        return FactletCollection.random()
    }
    
    static func getRefreshInterval() -> RefreshInterval {
        let suiteName = "group.com.factlet.app"
        if let savedIntervalString = UserDefaults(suiteName: suiteName)?.string(forKey: "refreshInterval"),
           let savedInterval = RefreshInterval(rawValue: savedIntervalString) {
            return savedInterval
        }
        return .hourly
    }
    
    static func getTextColor() -> WidgetTextColor {
        let suiteName = "group.com.factlet.app"
        if let savedColorString = UserDefaults(suiteName: suiteName)?.string(forKey: "textColor"),
           let savedColor = WidgetTextColor(rawValue: savedColorString) {
            return savedColor
        }
        return .dark
    }
    
    static func getSelectedCategories() -> Set<FactletCategory> {
        let suiteName = "group.com.factlet.app"
        if let savedCategoriesData = UserDefaults(suiteName: suiteName)?.data(forKey: "selectedCategories"),
           let savedCategories = try? JSONDecoder().decode(Set<FactletCategory>.self, from: savedCategoriesData) {
            return savedCategories
        }
        return [.all]
    }
}
