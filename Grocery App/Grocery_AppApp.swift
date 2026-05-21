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
    return true
  }
}

@main
struct Grocery_AppApp: App {
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
        ContentView()
    }
  }
}

