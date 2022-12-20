//
//  AlertManager.swift
//  CarServices
//
//  Created by Dmytro Grytsenko on 18.12.2022.
//

import UIKit

class AlertManager {
    
    static func showAlert(title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel)
        alert.addAction(okAction)
        
        guard let currentViewController = (UIApplication.shared.keyWindow?.rootViewController?.topMostViewController),
              ((UIApplication.shared.keyWindow?.rootViewController?.topMostViewController.isKind(of: UIAlertController.self)) != nil)
                       else { return }
        
        currentViewController.present(alert, animated: true)
    }
    
}

extension UIViewController {
    
    var topMostViewController: UIViewController {
        
        if let presented = self.presentedViewController {
            return presented.topMostViewController
        }
        return self
    }

}
