import Foundation
import CoreLocation

enum Result<T> {
    case success(T)
    case failure(Error)
}
final class LocationService: NSObject {
    private var manager: CLLocationManager
    init(manager: CLLocationManager = .init()) {
        self.manager = manager
        super.init()
        manager.delegate = self
    }
    var newLocation: ((Result<Address>) -> Void)?
    var permissionForLocationDenied: (() -> Void)?

    var didChangeStatus: ((Bool) -> Void)?
    var status: CLAuthorizationStatus {
        return manager.authorizationStatus
    }
    
    func  requestLocationAuthorization() {
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            manager.startUpdatingLocation()
        }
    }
    func getLocation() {
        manager.requestLocation()
    }
    deinit {
        manager.stopUpdatingLocation()
    }
    func translateLocationIntoAddress(location: CLLocation) {
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            if error != nil {
                print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                return
            }
            guard let placemark = placemarks?.first else {
                return
            }
            
            let outputString = [placemark.locality,
                                placemark.subLocality,
                                placemark.thoroughfare,
                                placemark.postalCode,
                                placemark.subThoroughfare,
                                placemark.country].compactMap { $0 }.joined(separator: ", ")
            print(outputString)
            let location =  Address(title: placemark.locality , description: outputString, coordinate: placemark.location?.coordinate)
            self.newLocation?(.success(location))
        })
    }
    
}
extension LocationService: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            print("Authorized")
            manager.requestLocation()
        case .denied:
            permissionForLocationDenied?()
            print("Denied")
        default:
            manager.requestWhenInUseAuthorization()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.sorted(by: {$0.timestamp > $1.timestamp}).first {
            //            newLocation?(.success(location))
            translateLocationIntoAddress(location: location)
        }
        manager.stopUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        newLocation?(.failure(error))
        manager.stopUpdatingLocation()
    }
    
}

struct Address {
    var title: String?, description: String, coordinate: CLLocationCoordinate2D?
}
