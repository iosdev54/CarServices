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
        clipsToBounds = true
        layer.masksToBounds = false
        layer.shadowRadius = 4.0
        layer.shadowOpacity = 0.5
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = .zero
    }
}
