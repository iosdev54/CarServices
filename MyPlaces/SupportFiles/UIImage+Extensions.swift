//
//  UIImage+Extensions.swift
//  MyPlaces
//
//  Created by Dmytro Grytsenko on 04.12.2022.
//

import Foundation
import UIKit

extension UIImage {
    
    static let sortByAZ = UIImage(named: "AZ")
    static let sortByZA = UIImage(named: "ZA")
    static let placeholder = UIImage(named: "Placeholder")
    
    //Icon for AlertController
    static let cameraIcon = UIImage(named: "Camera")
    static let photoIcon = UIImage(named: "Photo")
    
    //Icon for swipeAction
    static let delete = UIImage(systemName: "trash")
    static let addNewItem = UIImage(systemName: "plus.square")
}
