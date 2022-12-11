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
    static let placeholder = UIImage(named: "ServiceImage")
    
    //Icon for the Title in NavBar
    static let titleIcon = UIImage(named: "TitleIcon")
    
    //Icon for the leftBarButtonItem
    static let leftBarImage = UIImage(systemName: "arrow.up.arrow.down")
    
    //Icon for the sortFunction
    static let ascending = UIImage(systemName: "arrow.down")
    static let descending = UIImage(systemName: "arrow.up")
    
    //Icon for the alertController
    static let call = UIImage(systemName: "iphone")
    static let delete = UIImage(systemName: "trash")
}
