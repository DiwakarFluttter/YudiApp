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
        locationService.requestLocationAuthorization()
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
    }
    func configureGoogleMaps() {
        
        gMapView = GMSMapView(frame: self.view.frame)
        self.view.addSubview(gMapView)
        gMapView.isMyLocationEnabled = true
        gMapView.settings.myLocationButton = true
        
        
        
    }
    func updateCameraPosition(location: MyLocation) {
        
        // Creates a marker in the center of the map.
        guard let coordinate = location.coordinate else {return}
        let marker = GMSMarker()
        marker.position = coordinate
        marker.title = location.title
        marker.snippet = location.description
        marker.appearAnimation = GMSMarkerAnimation.pop
        
        marker.map = gMapView
    }
    
    
}
