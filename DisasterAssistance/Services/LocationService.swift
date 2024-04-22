//
//  LocationService.swift
//  DisasterAssistance
//
//  Created by Иоанн Ураков on 22.04.2024.
//

import CoreLocation

protocol LocationServiceProtocol {
    func getCurrentLocation() -> CLLocation?
}

class LocationService: NSObject, CLLocationManagerDelegate, LocationServiceProtocol {
    
    private let locationManager = CLLocationManager()
    private var currentLocation: CLLocation?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func getCurrentLocation() -> CLLocation? {
        return currentLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error.localizedDescription)")
    }
}
