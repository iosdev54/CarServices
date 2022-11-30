//
//  MapViewController.swift
//  MyPlaces
//
//  Created by Dmytro Grytsenko on 28.11.2022.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    var place = Place()
    let annotationIdentifier = "annotationIdentifier"
    let locationManager = CLLocationManager()
    let regionInMetters = 10_000.00
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPlaceMark()
        
        mapView.delegate = self
        
        checkLocationServises()
    }
    
    @IBAction func centerViewInUserLocation() {
        
        if let location = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMetters, longitudinalMeters: regionInMetters)
            
            mapView.setRegion(region, animated: true )
        }
    }
    
    @IBAction func closeVC() {
        dismiss(animated: true)
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
            
            self.mapView.showAnnotations([annotation], animated: true)
            //Выделяем, слегка увеличиваем аннотацию
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func checkLocationServises() {
        
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            //            checkLocationAuthorization()
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
    
    /*  //Deprecated
     private func checkLocationAuthorization() {
     switch CLLocationManager.authorizationStatus() {
     case .authorizedWhenInUse:
     mapView.showsUserLocation = true
     break
     case .denied:
     //Show alert controller
     break
     case .notDetermined:
     locationManager.requestWhenInUseAuthorization()
     case .restricted:
     //Show alert controller
     break
     case .authorizedAlways:
     break
     @unknown default:
     print("New case is available")
     }
     }
     */
    
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
}

extension MapViewController: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        //        checkLocationAuthorization()
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
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

