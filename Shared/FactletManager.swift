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
    case fifteenMinutes = "15 Minutes"
    case thirtyMinutes = "30 Minutes"
    case hourly = "Hourly"
    case daily = "Daily"
    
    var timeInterval: TimeInterval {
        switch self {
        case .fifteenMinutes: return 15 * 60
        case .thirtyMinutes: return 30 * 60
        case .hourly: return 60 * 60
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
    case humanBody = "Human Body"
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
    @Published var selectedLevels: Set<FactletLevel>
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
            self.refreshInterval = .hourly
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
        
        // Load selected levels
        if let savedLevelsData = defaults?.data(forKey: "selectedLevels"),
           let savedLevels = try? JSONDecoder().decode(Set<FactletLevel>.self, from: savedLevelsData) {
            self.selectedLevels = savedLevels
        } else {
            self.selectedLevels = Set(FactletLevel.allCases) // All levels by default
        }
        
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
        
        if let levelsData = try? JSONEncoder().encode(selectedLevels) {
            userDefaults.set(levelsData, forKey: selectedLevelsKey)
        }
        
        userDefaults.set(Date(), forKey: lastUpdateKey)
    }
    
    func getFilteredFactlets() -> [Factlet] {
        var filtered = FactletCollection.all
        
        // Filter by category
        if !selectedCategories.contains(.all) {
            filtered = filtered.filter { factlet in
                selectedCategories.contains { category in
                    category.rawValue == factlet.category
                }
            }
        }
        
        // Filter by level
        filtered = filtered.filter { factlet in
            selectedLevels.contains(factlet.level)
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
        WidgetCenter.shared.reloadAllTimelines()
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
    
    func toggleLevel(_ level: FactletLevel) {
        if selectedLevels.contains(level) {
            selectedLevels.remove(level)
            // Ensure at least one level is selected
            if selectedLevels.isEmpty {
                selectedLevels.insert(.level1)
            }
        } else {
            selectedLevels.insert(level)
        }
        save()
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func isLevelSelected(_ level: FactletLevel) -> Bool {
        return selectedLevels.contains(level)
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
