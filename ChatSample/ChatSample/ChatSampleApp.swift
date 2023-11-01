//
//  ChatSampleApp.swift
//  ChatSample
//
//  Created by 緒方亮平 on 2023/10/27.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import CallKit

@main
struct ChatSampleApp: App {
  
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  
    var body: some Scene {
        WindowGroup {
         RootVeiw()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}
