//
//  Const.swift
//  MyPlaces
//
//  Created by Dmytro Grytsenko on 04.12.2022.
//

import Foundation

enum Const {
    
    enum StarImageName {
        case filled
        case empty
        case highlighted
        
        var name: String {
            switch self {
            case.empty: return "EmptyStar"
            case .filled: return "FilledStar"
            case .highlighted: return "HighlightedStar"
            }
        }
        
    }
    
}



