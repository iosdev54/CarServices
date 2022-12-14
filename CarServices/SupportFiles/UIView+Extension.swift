//
//  UIView+Extension.swift
//  CarServices
//
//  Created by Dmytro Grytsenko on 06.12.2022.
//

import UIKit

extension UIView {
    
    func applyShadow(cornerRadius: CGFloat) {
        
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = false
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 4.0
    }
    
    func makeCorner(cornerRadius: CGFloat) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
        layer.isOpaque = false
    }
}
