import UIKit
import MapKit
import GoogleMaps

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    let locationService = LocationService()
    var gMapView: GMSMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.isHidden = true
        configureGoogleMaps()
        getCurrentLocationCoordinates()
        
    }
    func getCurrentLocationCoordinates() {
        locationService.newLocation = { [weak self] result in
            switch result {
            case .success(let location):
                self?.updateCameraPosition(location: location)
            case .failure(let error):
                print(error)
                
            }
        }
        locationService.permissionForLocationDenied = {[weak self ]in
            self?.showPopup("Permission Alert", actionTitle: "Settings",action: { (action) in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
                }
            })
        }
    }
    func configureGoogleMaps() {
        
        gMapView = GMSMapView(frame: self.view.frame)
        self.view.addSubview(gMapView)
        gMapView.isMyLocationEnabled = true
        gMapView.settings.myLocationButton = true
        
        
        
    }
    func updateCameraPosition(location: Address) {
        
        // Creates a marker in the center of the map.
        guard let coordinate = location.coordinate else {return}
        let marker = GMSMarker()
        marker.position = coordinate
        marker.title = location.title
        marker.snippet = location.description
        marker.appearAnimation = GMSMarkerAnimation.pop
//        centerInMarker(marker: marker)
        marker.map = gMapView
        let camera =  GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 14.0)
           DispatchQueue.main.async {
               CATransaction.begin()
               CATransaction.setValue(1, forKey: kCATransactionAnimationDuration)
                   marker.position = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
            marker.map?.animate(to: camera)
               CATransaction.commit()
           }
    }
    
    //method for center camera based in your own code
    func centerInMarker(marker: GMSMarker) {
        var bounds = GMSCoordinateBounds()
        bounds = bounds.includingCoordinate((marker as AnyObject).position)
        let update = GMSCameraUpdate.fit(bounds, with: UIEdgeInsets(top: (self.mapView?.frame.height)!/2 - 33, left: (self.mapView?.frame.width)!/2 - 81, bottom: 0, right: 0))
        gMapView?.moveCamera(update)
    }
}

extension UIViewController {
    func showPopup(_ title: String, message: String = "Please go to Settings and turn on the permissions",actionTitle:String, action: @escaping (UIAlertAction)-> Void) {
        // initialise a pop up for using later
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title:actionTitle, style: .default, handler: action)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
}
