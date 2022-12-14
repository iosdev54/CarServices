//
//  String+Extension.swift
//  CarServices
//
//  Created by Dmytro Grytsenko on 12.12.2022.
//

import Foundation

extension String {
    
    var isPhoneNumber: Bool {
        let digitsCharacters = CharacterSet(charactersIn: "+0123456789")
        return CharacterSet(charactersIn: self).isSubset(of: digitsCharacters)
    }
}
