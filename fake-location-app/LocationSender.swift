//
//  LocationSender.swift
//  fake-location
//
//  Created by psytwo1 on 2022/11/24.
//

import CoreLocation
import Firebase
import Foundation
import UIKit

class LocationSender {
    let id: String
    init() {
        id = Auth.auth().currentUser?.uid ?? UUID().uuidString
    }

    func sendLocation(location: CLLocation, timestamp: Date? = nil) {
        let dataStore = Firestore.firestore()
        let vTimestamp = timestamp ?? location.timestamp

        dataStore.collection("locations").document(id).setData([
            "timestamp": vTimestamp,
            "coordinate": [
                "latitude": location.coordinate.latitude,
                "longitude": location.coordinate.longitude,
            ],
        ]) { err in
            DispatchQueue.main.async {
                if let err = err {
                    print("Error writing document: \(err)")
                }
            }
        }
    }
}
