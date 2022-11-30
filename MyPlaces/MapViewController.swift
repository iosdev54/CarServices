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
    
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    let regionInMetters = 10_000.00
    var incomeSegueIdentifier = ""
    var placeCoordinate: CLLocationCoordinate2D?
    
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
        checkLocationServises()
    }
    
    @IBAction func centerViewInUserLocation() {
        
        showUserLocation()
    }
    
    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true)
    }
    
    @IBAction func goButtonPressed() {
        getDirections()
    }
    
    @IBAction func closeVC() {
        dismiss(animated: true)
    }
    
    private func setupMapView() {
        
        goButton.isHidden = true
        distanceLabel.isHidden = true
        timeIntervalLabel.isHidden = true
        
        if incomeSegueIdentifier == "showPlace" {
            setupPlaceMark()
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
            distanceLabel.isHidden = false
            timeIntervalLabel.isHidden = false
        }
    }
    
    private func setupPlaceMark() {
        
        guard let location = place.location else { return }
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(location) { [weak self] placemarks, error in
            guard let `self` = self else { return }
            
            if let error = error {
                print(error)
                return
            }
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = self.place.name
            annotation.subtitle = self.place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            self.mapView.showAnnotations([annotation], animated: true)
            //Выделяем, слегка увеличиваем аннотацию
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func checkLocationServises() {
        
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
        } else {
            //Алерт отображается если геолокация отключена глобально для всего устройства
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location Services are Disabled", message: "To enable it go: Settings -> Privacy -> Location Services and turn On.")
            }
        }
    }
    
    private func setupLocationManager() {
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func showUserLocation() {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMetters, longitudinalMeters: regionInMetters)
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func getDirections() {
        
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found.")
            return }
        
        guard let request = createDirectionRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found.")
            return
        }
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] responce, error in
            guard let `self` = self else { return }
            if let error = error {
                print(error)
                return
            }
            guard let responce = responce else {
                self.showAlert(title: "Error", message: "The route is not available.")
                return }
            //For each route
            /*
             for route in responce.routes  {
             self.mapView.addOverlay(route.polyline)
             self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
             
             let distance = String(format: "%.1f", route.distance / 1000)
             let timeInterval = ceilf(Float(route.expectedTravelTime / 60))
             self.distanceLabel.text = "Растояние до места - \(distance) км."
             self.timeIntervalLabel.text = "Время в пути - \(timeInterval) мин."
             }
             */
            //For first route
            if let route = responce.routes.first {
                self.mapView.addOverlay(route.polyline)
                self.mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distance = String(format: "%.1f", route.distance / 1000)
                let timeInterval = ceilf(Float(route.expectedTravelTime / 60))
                self.distanceLabel.text = "Растояние до места - \(distance) км."
                self.timeIntervalLabel.text = "Время в пути - \(timeInterval) мин."
            }
        }
    }
    
    private func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCoordinate = placeCoordinate else { return nil }
        let startingLocation = MKPlacemark(coordinate: coordinate)
        let destination = MKPlacemark(coordinate: destinationCoordinate)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: startingLocation)
        request.destination = MKMapItem(placemark: destination)
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        return request
    }
    
    private func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(okAction)
        present(alert, animated: true)
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
        
        let center = getCenterLocation(for: mapView)
        
        let geocoder = CLGeocoder()
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
            
            DispatchQueue.main.async {
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
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            if incomeSegueIdentifier == "getAddress" {
                showUserLocation()
            }
            break
        case .denied:
            showAlert(title: "Your Location is not Available", message: "To give permission Go to: Settings -> MyPlaces -> Location")
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            showAlert(title: "Your Location is not Available", message: "To give permission Go to: Settings -> MyPlaces -> Location")
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New case is available")
        }
    }
}

