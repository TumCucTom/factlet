//
//  FactletManager.swift
//  Factlet
//
//  Manages factlet selection, storage, and refresh intervals
//

import Foundation
import WidgetKit

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
    
    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: suiteName)
    }
    
    @Published var currentFactlet: Factlet
    @Published var refreshInterval: RefreshInterval
    @Published var textColor: WidgetTextColor
    @Published var selectedCategories: Set<FactletCategory>
    
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
        
        if let categoriesData = try? JSONEncoder().encode(selectedCategories) {
            userDefaults.set(categoriesData, forKey: selectedCategoriesKey)
        }
        
        userDefaults.set(Date(), forKey: lastUpdateKey)
    }
    
    func getFilteredFactlets() -> [Factlet] {
        if selectedCategories.contains(.all) {
            return FactletCollection.all
        }
        return FactletCollection.all.filter { factlet in
            selectedCategories.contains { category in
                category.rawValue == factlet.category
            }
        }
    }
    
    func refreshFactlet() {
        let filtered = getFilteredFactlets()
        if filtered.isEmpty {
            currentFactlet = FactletCollection.random()
        } else if filtered.count == 1 {
            currentFactlet = filtered[0]
        } else {
            var newFactlet = filtered.randomElement() ?? FactletCollection.random()
            while newFactlet.id == currentFactlet.id && filtered.count > 1 {
                newFactlet = filtered.randomElement() ?? FactletCollection.random()
            }
            currentFactlet = newFactlet
        }
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
