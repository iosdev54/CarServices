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
            showAlert()
            return
        }
        
        guard let url = URL(string: "telprompt://\(phoneNumber)"),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func showAlert() {
        
        let alert = UIAlertController(title: "No number or wrong number", message: nil, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(cancel)
        activeVC()?.present(alert, animated: true)
    }
    
    private func activeVC() -> UIViewController? {
       
        // Use connectedScenes to find the .foregroundActive rootViewController
        var rootVC: UIViewController?
        for scene in UIApplication.shared.connectedScenes {
            if scene.activationState == .foregroundActive {
                rootVC = (scene.delegate as? UIWindowSceneDelegate)?.window!!.rootViewController
                break
            }
        }
        // Then, find the topmost presentedVC from it.
        var presentedVC = rootVC
        while presentedVC?.presentedViewController != nil {
            presentedVC = presentedVC?.presentedViewController
        }
        return presentedVC
    }
    
}
