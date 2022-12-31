//
//  fake_location_appApp.swift
//  fake-location-app
//
//  Created by Masayuki Saito on 2022/11/26.
//

import CoreLocation
import Firebase
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    @Published var locationManager = CLLocationManager()
    //    @Published var locationViewModel: LocationViewModel

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {

        #if DEBUG
            let providerFactory = AppCheckDebugProviderFactory()
            AppCheck.setAppCheckProviderFactory(providerFactory)
        #endif

        FirebaseApp.configure()
        Auth.auth().signInAnonymously()
        //        locationViewModel = LocationViewModel()
        if launchOptions?[.location] != nil {
            locationManager.startMonitoringSignificantLocationChanges()
        }
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // バックグラウンドに入る前
        locationManager.startMonitoringSignificantLocationChanges()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // フォアグランド
        locationManager.startMonitoringSignificantLocationChanges()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // アプリが終了（キル）される前
        locationManager.startMonitoringSignificantLocationChanges()
    }
}

@main
struct fake_location_appApp: App {
    // register app delegate for Firebase setup
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
