//
//  StorageManager.swift
//  CarServices
//
//  Created by Dmytro Grytsenko on 22.11.2022.
//

import Foundation
import RealmSwift

let realm = try! Realm()

class StorageManager {
    
    static func saveObject(_ service: Service) {
        try! realm.write {
            realm.add(service)
        }
    }
    
    static func deleteObject(_ service: Service) {
        try! realm.write {
            realm.delete(service)
        }
    }
    
}
