//
//  UIMapAddressGetView.swift
//  fake-location
//
//  Created by psytwo1 on 2022/11/16.
//

import MapKit
import SwiftUI

struct UIMapAddressGetView: UIViewRepresentable {
    @State var mapView = MKMapView()
    @Binding var userTrackingMode: MKUserTrackingMode
    @Binding var locationButton: String
    @ObservedObject var locationViewModel: LocationViewModel

    init(
        mapView: MKMapView = MKMapView(), userTrackingMode: Binding<MKUserTrackingMode>,
        locationButton: Binding<String>, locationViewModel: LocationViewModel
    ) {
        self.mapView = mapView
        _userTrackingMode = userTrackingMode
        _locationButton = locationButton
        self.locationViewModel = locationViewModel
    }

    func makeUIView(context: Self.Context) -> MKMapView {
        let longPressGesture = UILongPressGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.longTapped)
        )
        longPressGesture.delegate = context.coordinator
        mapView.addGestureRecognizer(longPressGesture)

        let panGesture = UIPanGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handlePanGesture)
        )
        panGesture.delegate = context.coordinator
        mapView.addGestureRecognizer(panGesture)

        guard let currentLocation = locationViewModel.getRealLocation() else {
            return mapView
        }
        mapView.setCenter(currentLocation.coordinate, animated: true)

        guard let coordinate = locationViewModel.userProfile.fakeLocation?.coordinate else {
            return mapView
        }

        context.coordinator.addAnotation(coordinate: coordinate)

        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Self.Context) {
        mapView.setUserTrackingMode(userTrackingMode, animated: true)
        switch userTrackingMode {
        case .follow:
            mapView.camera.heading = 0
            mapView.setCenter(mapView.userLocation.coordinate, animated: true)
            break
        case .followWithHeading:
            mapView.setCenter(mapView.userLocation.coordinate, animated: true)
            break
        case .none:
            break
        default:
            break

        }

    }
    func makeCoordinator() -> Coordinator {
        Coordinator(
            self, mapView: $mapView, userTrackingMode: $userTrackingMode,
            locationButton: $locationButton,
            locationViewModel: locationViewModel)
    }
}
extension UIMapAddressGetView {
    class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var control: UIMapAddressGetView

        @Binding var mapView: MKMapView
        @Binding var userTrackingMode: MKUserTrackingMode
        @Binding var locationButton: String
        @ObservedObject var locationViewModel: LocationViewModel

        init(
            _ control: UIMapAddressGetView, mapView: Binding<MKMapView>,
            userTrackingMode: Binding<MKUserTrackingMode>, locationButton: Binding<String>,
            locationViewModel: LocationViewModel
        ) {
            self.control = control
            _mapView = mapView
            _userTrackingMode = userTrackingMode
            _locationButton = locationButton
            self.locationViewModel = locationViewModel
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            return true
        }

        func addAnotation(coordinate: CLLocationCoordinate2D) {
            let mapCoordinate: CLLocationCoordinate2D = coordinate
            let tapAnotation = MKPointAnnotation()
            tapAnotation.coordinate = mapCoordinate
            tapAnotation.title = "偽装ポイント"

            if !mapView.annotations.isEmpty {
                mapView.removeAnnotations(mapView.annotations)
                locationViewModel.userProfile.fakeLocation = nil
            }
            // MapViewにピンを追加.
            mapView.addAnnotation(tapAnotation)

            locationViewModel.userProfile.fakeLocation = CLLocation(
                latitude: mapCoordinate.latitude, longitude: mapCoordinate.longitude)

        }

        @objc func longTapped(gesture: UILongPressGestureRecognizer) {

            let viewPoint = gesture.location(in: mapView)
            let mapCoordinate: CLLocationCoordinate2D = mapView.convert(
                viewPoint, toCoordinateFrom: mapView)
            addAnotation(coordinate: mapCoordinate)
        }

        @objc func handlePanGesture(gesture: UIPanGestureRecognizer) {
            userTrackingMode = .none
            locationButton = "location"

        }
    }
}
