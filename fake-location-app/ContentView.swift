//
//  ContentView.swift
//  fake-location
//
//  Created by psytwo1 on 2022/11/15.
//

import MapKit
import SwiftUI

struct ContentView: View {
    //    @ObservedObject var userProfile = UserProfile()
    @State var userTrackingMode = MKUserTrackingMode.follow
    @State var locationButton = "location"
    //    @State var isFake = false
    @EnvironmentObject var appDelegate: AppDelegate
    //    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @ObservedObject var locationViewModel = LocationViewModel()

    var body: some View {
        VStack {
            ZStack(alignment: .topTrailing) {
                UIMapAddressGetView(
                    userTrackingMode: $userTrackingMode, locationButton: $locationButton,
                    locationViewModel: LocationViewModel(
                        locationManager: appDelegate.locationManager)
                )
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        Button(action: {
                            switch userTrackingMode {
                            case .follow:
                                userTrackingMode = .followWithHeading
                                locationButton = "location.north.line.fill"
                            case .none:
                                userTrackingMode = .follow
                                locationButton = "location.fill"
                            case .followWithHeading:
                                userTrackingMode = .follow
                                locationButton = "location.fill"
                            default:
                                break
                            }
                        }) {
                            Image(systemName: locationButton)
                                .padding(15)
                                .background(Color(UIColor.systemBackground))
                                .foregroundColor(Color(UIColor.systemBlue))
                                .cornerRadius(10)
                        }
                    }
                    .padding(EdgeInsets(top: 60.0, leading: 10, bottom: 10, trailing: 5))
                }
            }
            Spacer()
            VStack(alignment: .center) {
                GroupBox {
                    Toggle("偽装", isOn: $locationViewModel.userProfile.isFake)
                        .padding()
                        .background(Color(UIColor.systemBackground))
                        .cornerRadius(10)
                        .onChange(of: locationViewModel.userProfile.isFake) { value in
                            locationViewModel.userProfile.isFake = value
                            if value {
                                guard let location = locationViewModel.userProfile.fakeLocation
                                else {
                                    return
                                }
                                locationViewModel.locationSender.sendLocation(
                                    location: location, timestamp: Date())
                            } else {
                                guard let location = locationViewModel.getRealLocation() else {
                                    return
                                }
                                locationViewModel.locationSender.sendLocation(location: location)
                            }
                        }
                }
            }
        }
        .background(Color(UIColor.systemGray6))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
