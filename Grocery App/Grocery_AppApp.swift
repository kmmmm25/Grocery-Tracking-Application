//
//  Grocery_AppApp.swift
//  Grocery App
//
//  Created by Ikezaki Kumataka on 2026/05/03.
//
import SwiftUI
import Firebase
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    // 1. Firebaseの初期化
    FirebaseApp.configure()
    
    // 2. 起動時にプッシュ通知の許可ポップアップを出す
    NotificationManager.shared.requestAuthorization()
    
    return true
  }
}

@main
struct Grocery_AppApp: App {
  // Firebaseと通知の初期化を行うDelegateを登録
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
        ContentView()
    }
  }
}

