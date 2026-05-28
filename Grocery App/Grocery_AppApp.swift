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
    FirebaseApp.configure()
    NotificationManager.shared.requestAuthorization()
    return true
  }
}

@main
struct Grocery_AppApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  // 🚀 現在ログインしている家族IDを管理する状態（UserDefaultsから自動で前回分を読み込む）
  @State private var currentFamilyID: String? = UserDefaults.standard.string(forKey: "savedFamilyID")

  var body: some Scene {
    WindowGroup {
        // 🚀 ログインしている家族IDがあるかどうかで画面を切り替える
        if let familyID = currentFamilyID {
            ContentView()
                // 今後ContentView側でログアウト処理等ができるように環境変数に家族IDを渡しておく
                .environment(\.currentFamilyID, familyID)
        } else {
            FamilyAuthView(currentFamilyID: $currentFamilyID)
        }
    }
  }
}

// 🚀 家族IDを簡単に各画面へ共有するためのお助けコード
struct FamilyIDKey: EnvironmentKey {
    static let defaultValue: String = ""
}
extension EnvironmentValues {
    var currentFamilyID: String {
        get { self[FamilyIDKey.self] }
        set { self[FamilyIDKey.self] = newValue }
    }
}
