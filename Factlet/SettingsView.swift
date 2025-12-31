//
//  SettingsView.swift
//  Factlet
//
//  Settings for refresh interval and widget appearance
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var manager = FactletManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.98, green: 0.97, blue: 0.95)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 40) {
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
                        .padding(.top, 20)
                        
                        // Refresh Interval Section
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("REFRESH INTERVAL")
                                    .font(.custom("TimesNewRomanPS-BoldMT", size: 11))
                                    .kerning(2.5)
                                    .foregroundColor(.black.opacity(0.4))
                                
                                Text("Choose how often the factlet changes.")
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
                        
                        Spacer(minLength: 60)
                        
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
