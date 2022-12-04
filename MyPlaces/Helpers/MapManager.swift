//
//  MapManager.swift
//  MyPlaces
//
//  Created by Dmytro Grytsenko on 01.12.2022.
//

import Foundation
import MapKit

class MapManager {
    
    //MARK: - Private constants
    private let segueIdentifierGetAddress = "getAddress"
    
    let locationManager = CLLocationManager()
    
    private var placeCoordinate: CLLocationCoordinate2D?
    private var directionsArray: [MKDirections] = []
    private let regionInMetters = 1000.00
    
    //Мвркер заведения
    func setupPlaceMark(place: Place, mapView: MKMapView) {
        
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
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            self.placeCoordinate = placemarkLocation.coordinate
            
            mapView.showAnnotations([annotation], animated: true)
            //Выделяем, слегка увеличиваем аннотацию
            mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    //Проверка доступности сервисов геолокации
    func checkLocationServises(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            closure()
        } else {
            //Алерт отображается если геолокация отключена глобально для всего устройства
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let `self` = self else { return }
                self.showAlert(title: "Location Services are Disabled", message: "To enable it go: Settings -> Privacy -> Location Services and turn On.")
            }
        }
    }
    
    //Проверка авторизации приложения для использования сервисов геолокации
    func checkLocationAuthorization(mapView: MKMapView, segueIdentifier: String, manager: CLLocationManager) {
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            mapView.showsUserLocation = true
            
            if segueIdentifier == segueIdentifierGetAddress {
                showUserLocation(mapView: mapView)
            }
            break
        case .denied:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let `self` = self else { return }
                self.showAlert(title: "Your Location is not Available", message: "To give permission Go to: Settings -> MyPlaces -> Location")
            }
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard let `self` = self else { return }
                self.showAlert(title: "Your Location is not Available", message: "To give permission Go to: Settings -> MyPlaces -> Location")
            }
            break
        case .authorizedAlways:
            break
        @unknown default:
            print("New Additional Case")
        }
    }
    
    //Фокус карты на местоположение пользователя
    func showUserLocation(mapView: MKMapView) {
        
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found.")
            return
        }
        let region = MKCoordinateRegion(center: location, latitudinalMeters: regionInMetters, longitudinalMeters: regionInMetters)
        mapView.setRegion(region, animated: true)
        
    }
    
    //Строим маршрут от местоположения пользователя до заведения
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> (), completion: @escaping (_ distance: String, _ timeInterval: Int) -> ()) {
        
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found.")
            return }
        
        locationManager.startUpdatingLocation()
        
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude))
        
        guard let request = createDirectionsRequest(from: location) else {
            showAlert(title: "Error", message: "Destination is not found.")
            return
        }
        let directions = MKDirections(request: request)
        
        //Удаляем все текущие маршруты, которые были созданы ранее
        resetMapView(withNew: directions, mapView: mapView)
        
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
                mapView.addOverlay(route.polyline)
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                let distanceInKm = String(format: "%.1f", route.distance / 1000)
                let timeInterval = ceilf(Float(route.expectedTravelTime / 60))
                let timeIntervalInMin = Int(timeInterval)
                
                completion(distanceInKm, timeIntervalInMin)
            }
        }
    }
    
    //Настройка запроса для настройки маршрута
    private func createDirectionsRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
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
    
    //Меняем отображаемую зону области карты в соотвествии с перемещением пользователя
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        
        guard let location = location else { return }
        let center = getCenterLocation(for: mapView)
        guard center.distance(from: location) > 50 else { return }
        closure(center)
    }
    
    //Сброс всех ранее построенных маршрутов перед построением нового
    private func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
        
        mapView.removeOverlays(mapView.overlays)
        directionsArray.append(directions)
        let _ = directionsArray.map { $0.cancel() }
        directionsArray.removeAll()
    }
    
    //Опрелеление центра отображаемой области карты
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(okAction)
        
        activeVC()?.present(alert, animated: true)
        
        //        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        //        alertWindow.rootViewController = UIViewController()
        //        alertWindow.windowLevel = UIWindow.Level.alert + 1
        //        alertWindow.makeKeyAndVisible()
        //        alertWindow.rootViewController?.present(alert, animated: true)
    }
    
    private func activeVC() -> UIViewController? {
        // Use connectedScenes to find the .foregroundActive rootViewController
        var rootVC: UIViewController?
        for scene in UIApplication.shared.connectedScenes {
            if scene.activationState == .foregroundActive {
                rootVC = (scene.delegate as? UIWindowSceneDelegate)?.window!!.rootViewController
                break
            }
        }
        // Then, find the topmost presentedVC from it.
        var presentedVC = rootVC
        while presentedVC?.presentedViewController != nil {
            presentedVC = presentedVC?.presentedViewController
        }
        return presentedVC
    }
    
}


