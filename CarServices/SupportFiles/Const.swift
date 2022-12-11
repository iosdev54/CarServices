//
//  Const.swift
//  CarServices
//
//  Created by Dmytro Grytsenko on 04.12.2022.
//

import Foundation

enum Const {
    
    enum oilDropImage {
        case filled
        case empty
        case highlighted
        
        var name: String {
            switch self {
            case.empty: return "EmptyOilDrop"
            case .filled: return "FilledOilDrop"
            case .highlighted: return "HighlightedOilDrop"
            }
        }
    }
    
}



