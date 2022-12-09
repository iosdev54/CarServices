//
//  ContentViewController.swift
//  MyPlaces
//
//  Created by Dmytro Grytsenko on 08.12.2022.
//

import UIKit

class ContentViewController: UIViewController {
    
    private var imageIsChanged = false
    
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        containerView.applyShadow(cornerRadius: 10)
        
//        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: 10).cgPath
    }
    
    
    @IBAction func cancelAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        
        
    }

    
}
