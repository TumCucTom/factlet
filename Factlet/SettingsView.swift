//
//  SettingsView.swift
//  Factlet
//
//  Settings for refresh interval, widget appearance, and notifications
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var manager = FactletManager.shared
    @State private var showNotificationAlert = false
    @State private var notificationPermissionGranted = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.98, green: 0.97, blue: 0.95)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 36) {
                        // Notifications Section
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("NOTIFICATIONS")
                                    .font(.custom("TimesNewRomanPS-BoldMT", size: 11))
                                    .kerning(2.5)
                                    .foregroundColor(.black.opacity(0.4))
                                
                                Text("Receive factlets as notifications. Also updates the widget.")
                                    .font(.custom("TimesNewRomanPSMT", size: 15))
                                    .foregroundColor(.black.opacity(0.6))
                                    .lineSpacing(4)
                            }
                            .padding(.horizontal, 28)
                            
                            // Notification Frequency Options
                            VStack(spacing: 0) {
                                ForEach(NotificationFrequency.allCases, id: \.self) { frequency in
                                    Button(action: {
                                        handleNotificationFrequencyChange(frequency)
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(frequency.displayName)
                                                    .font(.custom("TimesNewRomanPSMT", size: 18))
                                                    .foregroundColor(.black.opacity(0.85))
                                                
                                                if frequency != .off {
                                                    Text(frequencyDescription(frequency))
                                                        .font(.custom("TimesNewRomanPSMT", size: 12))
                                                        .foregroundColor(.black.opacity(0.4))
                                                }
                                            }
                                            
                                            Spacer()
                                            
                                            if manager.notificationFrequency == frequency {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(.black.opacity(0.6))
                                            }
                                        }
                                        .padding(.horizontal, 28)
                                        .padding(.vertical, 16)
                                        .background(
                                            manager.notificationFrequency == frequency
                                                ? Color.black.opacity(0.03)
                                                : Color.clear
                                        )
                                    }
                                    
                                    if frequency != NotificationFrequency.allCases.last {
                                        Rectangle()
                                            .fill(Color.black.opacity(0.08))
                                            .frame(height: 1)
                                            .padding(.horizontal, 28)
                                    }
                                }
                            }
                        }
                        .padding(.top, 20)
                        
                        // Widget Text Color Section
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("WIDGET TEXT COLOR")
                                    .font(.custom("TimesNewRomanPS-BoldMT", size: 11))
                                    .kerning(2.5)
                                    .foregroundColor(.black.opacity(0.4))
                                
                                Text("Choose text color based on your wallpaper.")
                                    .font(.custom("TimesNewRomanPSMT", size: 15))
                                    .foregroundColor(.black.opacity(0.6))
                                    .lineSpacing(4)
                            }
                            .padding(.horizontal, 28)
                            
                            // Color Options
                            HStack(spacing: 16) {
                                TextColorOption(
                                    color: .dark,
                                    isSelected: manager.textColor == .dark
                                ) {
                                    manager.setTextColor(.dark)
                                }
                                
                                TextColorOption(
                                    color: .light,
                                    isSelected: manager.textColor == .light
                                ) {
                                    manager.setTextColor(.light)
                                }
                            }
                            .padding(.horizontal, 28)
                        }
                        
                        // Widget Refresh Interval Section
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("WIDGET REFRESH")
                                    .font(.custom("TimesNewRomanPS-BoldMT", size: 11))
                                    .kerning(2.5)
                                    .foregroundColor(.black.opacity(0.4))
                                
                                Text("How often the widget refreshes automatically.")
                                    .font(.custom("TimesNewRomanPSMT", size: 15))
                                    .foregroundColor(.black.opacity(0.6))
                                    .lineSpacing(4)
                            }
                            .padding(.horizontal, 28)
                            
                            // Options
                            VStack(spacing: 0) {
                                ForEach(RefreshInterval.allCases, id: \.self) { interval in
                                    Button(action: {
                                        manager.setRefreshInterval(interval)
                                    }) {
                                        HStack {
                                            Text(interval.displayName)
                                                .font(.custom("TimesNewRomanPSMT", size: 18))
                                                .foregroundColor(.black.opacity(0.85))
                                            
                                            Spacer()
                                            
                                            if manager.refreshInterval == interval {
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 14, weight: .medium))
                                                    .foregroundColor(.black.opacity(0.6))
                                            }
                                        }
                                        .padding(.horizontal, 28)
                                        .padding(.vertical, 18)
                                        .background(
                                            manager.refreshInterval == interval
                                                ? Color.black.opacity(0.03)
                                                : Color.clear
                                        )
                                    }
                                    
                                    if interval != RefreshInterval.allCases.last {
                                        Rectangle()
                                            .fill(Color.black.opacity(0.08))
                                            .frame(height: 1)
                                            .padding(.horizontal, 28)
                                    }
                                }
                            }
                        }
                        
                        Spacer(minLength: 40)
                        
                        // About
                        VStack(spacing: 8) {
                            Text("Factlet")
                                .font(.custom("TimesNewRomanPS-ItalicMT", size: 16))
                                .foregroundColor(.black.opacity(0.4))
                            
                            Text("A small piece of knowledge,\ndelivered beautifully.")
                                .font(.custom("TimesNewRomanPSMT", size: 13))
                                .foregroundColor(.black.opacity(0.3))
                                .multilineTextAlignment(.center)
                                .lineSpacing(3)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Settings")
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
            .alert("Enable Notifications", isPresented: $showNotificationAlert) {
                Button("Open Settings") {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
                Button("Cancel", role: .cancel) {
                    manager.setNotificationFrequency(.off)
                }
            } message: {
                Text("Please enable notifications in Settings to receive factlets.")
            }
            .onAppear {
                checkNotificationStatus()
            }
        }
    }
    
    private func handleNotificationFrequencyChange(_ frequency: NotificationFrequency) {
        if frequency == .off {
            manager.setNotificationFrequency(.off)
        } else {
            // Check if we have permission
            manager.checkNotificationPermission { granted in
                if granted {
                    manager.setNotificationFrequency(frequency)
                } else {
                    // Request permission
                    manager.requestNotificationPermission { granted in
                        if granted {
                            manager.setNotificationFrequency(frequency)
                        } else {
                            showNotificationAlert = true
                        }
                    }
                }
            }
        }
    }
    
    private func checkNotificationStatus() {
        manager.checkNotificationPermission { granted in
            notificationPermissionGranted = granted
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

// MARK: - Text Color Option
struct TextColorOption: View {
    let color: WidgetTextColor
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Preview
                ZStack {
                    if color == .dark {
                        // Light background preview
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.95, green: 0.92, blue: 0.88),
                                        Color(red: 0.90, green: 0.87, blue: 0.82)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SCIENCE")
                                .font(.custom("TimesNewRomanPS-BoldMT", size: 6))
                                .kerning(1)
                                .foregroundColor(.black.opacity(0.4))
                            
                            Text("Honey never spoils...")
                                .font(.custom("TimesNewRomanPSMT", size: 9))
                                .foregroundColor(.black.opacity(0.85))
                                .lineLimit(2)
                        }
                        .padding(10)
                    } else {
                        // Dark background preview
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.15, green: 0.18, blue: 0.22),
                                        Color(red: 0.10, green: 0.12, blue: 0.15)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SCIENCE")
                                .font(.custom("TimesNewRomanPS-BoldMT", size: 6))
                                .kerning(1)
                                .foregroundColor(.white.opacity(0.5))
                            
                            Text("Honey never spoils...")
                                .font(.custom("TimesNewRomanPSMT", size: 9))
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(2)
                        }
                        .padding(10)
                    }
                }
                .frame(height: 70)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isSelected ? Color.black.opacity(0.4) : Color.black.opacity(0.1), lineWidth: isSelected ? 2 : 1)
                )
                
                // Label
                HStack(spacing: 6) {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.black.opacity(0.6))
                    }
                    
                    Text(color == .dark ? "Dark Text" : "Light Text")
                        .font(.custom("TimesNewRomanPSMT", size: 14))
                        .foregroundColor(.black.opacity(isSelected ? 0.85 : 0.5))
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SettingsView()
}
