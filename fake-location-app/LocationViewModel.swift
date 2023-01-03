//
//  LocationViewModel.swift
//  fake-location
//
//  Created by psytwo1 on 2022/11/16.
//

import CoreLocation

class LocationViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var lastSeenLocation: CLLocation?
    @Published var userProfile = UserProfile()
    //    var fakeLocation :CLLocation?
    //    var isFake = false
    let locationSender = LocationSender()

    private var locationManager: CLLocationManager

    init(locationManager: CLLocationManager = CLLocationManager()) {
        self.locationManager = locationManager
        authorizationStatus = locationManager.authorizationStatus
        super.init()

        //        locationManager = appDelegate.locationManager

        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 100
        self.locationManager.allowsBackgroundLocationUpdates = true  // バックグラウンド実行中も座標取得する場合、trueにする
        self.locationManager.pausesLocationUpdatesAutomatically = false
        switch authorizationStatus {
        case .notDetermined:
            requestPermission()
        case .authorizedWhenInUse, .authorizedAlways:
            self.locationManager.startUpdatingLocation()
        default:
            break
        }
    }

    func requestPermission() {
        //        locationManager.requestWhenInUseAuthorization()
        locationManager.requestAlwaysAuthorization()  // バックグラウンド実行中も座標取得する場合はこちら
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        var tmpLocation: CLLocation?

        if userProfile.isFake {
            tmpLocation = userProfile.fakeLocation ?? locations.first
        } else {
            tmpLocation = locations.first
        }

        if lastSeenLocation?.coordinate.latitude == tmpLocation?.coordinate.latitude
            && lastSeenLocation?.coordinate.longitude == tmpLocation?.coordinate.longitude
        {
            return
        }

        lastSeenLocation = tmpLocation

        guard let location = lastSeenLocation else {
            return
        }

        locationSender.sendLocation(location: location)

        print("緯度: ", location.coordinate.latitude, "経度: ", location.coordinate.longitude)
    }

    func getRealLocation() -> CLLocation? {
        return locationManager.location
    }

}
