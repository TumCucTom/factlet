//
//  FactletApp.swift
//  Factlet
//
//  A minimalistic app displaying general knowledge factlets
//

import SwiftUI
import UserNotifications

@main
struct FactletApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var manager = FactletManager.shared
    
    var body: some Scene {
        WindowGroup {
            if manager.onboardingCompleted {
                ContentView()
            } else {
                OnboardingView()
            }
        }
    }
}

// MARK: - App Delegate for Notifications
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // Handle notification when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }
    
    // Handle notification tap
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Update the factlet when notification is tapped
        FactletManager.shared.handleNotificationReceived()
        completionHandler()
    }
}
