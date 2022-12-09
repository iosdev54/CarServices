//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Dmytro Grytsenko on 28.11.2022.
//

import UIKit
import MapKit
import CoreLocation

protocol MapViewControllerDelegate {
    func getAddress(_ address: String? )
}

class MapViewController: UIViewController {
    
    //MARK: - Private constants
    private let segueIdentifierShowPlace = "showPlace"
    private let annotationIdentifier = "annotationIdentifier"

    private let mapManager = MapManager()
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Service()
    
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
                self.distanceLabel.text = "Растояние до места - \(distance) км"
                self.timeIntervalLabel.text = "Время в пути - \(timeInterval) мин"
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
        
        mapManager.checkLocationServises(mapView: mapView, segueIdentifier: incomeSegueIdentifier) {
            mapManager.locationManager.delegate = self
        }
        
        if incomeSegueIdentifier == segueIdentifierShowPlace {
            mapManager.setupPlaceMark(place: place, mapView: mapView)
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
            distanceLabel.isHidden = false
            timeIntervalLabel.isHidden = false
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKMarkerAnnotationView
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
            annotationView?.canShowCallout = true
        }
        if let imageData = place.imageData {
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
        
        if incomeSegueIdentifier == segueIdentifierShowPlace && previousLocation != nil {
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
                } else if cityName != nil, streetName != nil {
                    self.addressLabel.text = "\(cityName!), \(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
    }
    
    //    Для отображения маршрута на карте
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = .systemBlue
        
        return renderer
    }
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        
        mapManager.checkLocationAuthorization(mapView: mapView, segueIdentifier: incomeSegueIdentifier, manager: manager)
    }
    
}
