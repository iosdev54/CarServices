//
//  CallFunction.swift
//  CarServices
//
//  Created by Dmytro Grytsenko on 12.12.2022.
//

import UIKit

class CallManager {
    
    func callNumber(phoneNumber: String) {
        
        if !phoneNumber.isPhoneNumber || phoneNumber.isEmpty {
            AlertManager.showAlert(title: "No number or wrong number", message: nil)
            return
        }
        
        guard let url = URL(string: "telprompt://\(phoneNumber)"),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
}
