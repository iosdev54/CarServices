//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Dmytro Grytsenko on 22.11.2022.
//

import Foundation
import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ place: Place) {
        try! realm.write {
            realm.add(place)
        }
    }
    
    static func deleteObject(_ place: Place) {
        try! realm.write {
            realm.delete(place)
        }
    }
    
}

