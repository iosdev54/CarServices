//
//  PlaceModel.swift
//  MyPlaces
//
//  Created by Dmytro Grytsenko on 21.11.2022.
//

import UIKit
import RealmSwift

class Service: Object {
    
    @Persisted var name: String = ""
    @Persisted var type: String?
    @Persisted var location: String?
    @Persisted var phone: String?
    @Persisted var imageData: Data?
    @Persisted var date = Date()
    @Persisted var rating = 0.0
    
    convenience init(name: String, type: String?, location: String?, phone: String?, imageData: Data?, rating: Double) {
        self.init()
        self.name = name
        self.type = type
        self.location = location
        self.phone = phone
        self.imageData = imageData
        self.rating = rating
    }
    
}
