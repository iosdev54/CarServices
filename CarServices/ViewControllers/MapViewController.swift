//
//  MapViewController.swift
//  CarServices
//
//  Created by Dmytro Grytsenko on 28.11.2022.
//

import UIKit
import MapKit
import CoreLocation

//MARK: - Protocol MapViewControllerDelegate
protocol MapViewControllerDelegate {
    func getAddress(_ address: String? )
}

class MapViewController: UIViewController {
    
    //MARK: - Private constants
    private let segueIdentifierShowService = "showService"
    private let annotationIdentifier = "annotationIdentifier"

    private let mapManager = MapManager()
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var service = Service()
    
    var incomeSegueIdentifier = ""
    
    private var previousLocation: CLLocation? {
        didSet {
            mapManager.startTrackingUserLocation(for: mapView, and: previousLocation) { [weak self] currentLocation in
                guard let `self` = self else { return }
                self.previousLocation = currentLocation
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                    guard let `self` = self else { return }
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
            }
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var mapPinImage: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeIntervalLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addressLabel.text = ""
        distanceLabel.text = ""
        timeIntervalLabel.text = ""
        setupMapView()
        mapView.delegate = self
    }
    
    @IBAction func centerViewInUserLocation() {
        
        mapManager.showUserLocation(mapView: mapView)
    }
    
    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }
    
    @IBAction func goButtonPressed() {
    
        mapManager.getDirections(for: mapView) { [weak self] location in
            guard let `self` = self else { return }
            self.previousLocation = location
        } completion: { distance, timeInterval in
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                self.distanceLabel.text = "Distance to service - \(distance) km"
                self.timeIntervalLabel.text = "Travel time - \(timeInterval) min"
            }
        }
        
    }
    
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    private func setupMapView() {
        
        goButton.isHidden = true
        distanceLabel.isHidden = true
        timeIntervalLabel.isHidden = true
        doneButton.isEnabled = false
        
        mapManager.checkLocationServises(mapView: mapView, segueIdentifier: incomeSegueIdentifier) {
            mapManager.locationManager.delegate = self
        }
        
        if incomeSegueIdentifier == segueIdentifierShowService {
            mapManager.setupPlaceMark(place: service, mapView: mapView)
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
            distanceLabel.isHidden = false
            timeIntervalLabel.isHidden = false
        }
    }
}

//MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        if let imageData = service.imageData {
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            
            imageView.image = UIImage(data: imageData)
            annotationView?.rightCalloutAccessoryView = imageView
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        let center = mapManager.getCenterLocation(for: mapView)
        
        let geocoder = CLGeocoder()
        
        if incomeSegueIdentifier == segueIdentifierShowService && previousLocation != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                guard let `self` = self else { return }
                self.mapManager.showUserLocation(mapView: mapView)
            }
        }
        geocoder.cancelGeocode()
        
        geocoder.reverseGeocodeLocation(center) { [weak self] placemarks, error in
            guard let `self` = self else { return }
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            let cityName = placemark?.locality
            let streetName = placemark?.thoroughfare
            let buildNumber = placemark?.subThoroughfare
            
            DispatchQueue.main.async { [weak self] in
                guard let `self` = self else { return }
                if cityName != nil, streetName != nil, buildNumber != nil {
                    self.addressLabel.text = "\(cityName!), \(streetName!), \(buildNumber!)"
                    self.doneButton.isEnabled = true
                } else if cityName != nil, streetName != nil {
                    self.addressLabel.text = "\(cityName!), \(streetName!)"
                    self.doneButton.isEnabled = true
                } else {
                    self.addressLabel.text = ""
                    self.doneButton.isEnabled = false
                }
            }
        }
    }
    
    // Для отображения маршрута на карте
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .systemBlue
        
        return renderer
    }
}

//MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        mapManager.checkLocationAuthorization(mapView: mapView, segueIdentifier: incomeSegueIdentifier, manager: manager)
    }
    
}
