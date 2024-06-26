//
//  UserProfile.swift
//  fake-location
//
//  Created by psytwo1 on 2022/11/25.
//

import CoreLocation
import Foundation

class UserProfile: ObservableObject {
    @Published var isFake: Bool {
        didSet {
            UserDefaults.standard.set(isFake, forKey: "isFake")
        }
    }

    @Published var fakeLocation: CLLocation? {
        didSet {
            guard let loc = fakeLocation else {
                UserDefaults.standard.removeObject(forKey: "fakeLocation")
                return
            }
            guard
                let location = try? NSKeyedArchiver.archivedData(
                    withRootObject: loc, requiringSecureCoding: true
                )
            else {
                UserDefaults.standard.removeObject(forKey: "fakeLocation")
                return
            }
            UserDefaults.standard.set(location, forKey: "fakeLocation")
        }
    }

    init() {
        isFake = UserDefaults.standard.bool(forKey: "isFake")
        if let data: Data = UserDefaults.standard.object(forKey: "fakeLocation") as? Data {
            if let location =
                (try? NSKeyedUnarchiver.unarchivedObject(ofClass: CLLocation.self, from: data))
            {
                fakeLocation = location
            } else {
                fakeLocation = nil
            }
        } else {
            fakeLocation = nil
        }
    }
}
