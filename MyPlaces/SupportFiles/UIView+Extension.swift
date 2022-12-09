//
//  UIView+Extension.swift
//  MyPlaces
//
//  Created by Dmytro Grytsenko on 06.12.2022.
//

import Foundation
import UIKit

extension UIView {
    
    func applyShadow(cornerRadius: CGFloat) {
        
        layer.cornerRadius = cornerRadius
//        clipsToBounds = true
        layer.masksToBounds = false
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 4.0
    }
    
    func makeCorner(with radius: CGFloat) {
        layer.cornerRadius = radius
        layer.masksToBounds = true
        layer.isOpaque = false
    }
}
