//
//  CellRating.swift
//  MyPlaces
//
//  Created by Dmytro Grytsenko on 26.11.2022.
//

import UIKit

@IBDesignable class CellRating: UIStackView {
    
    var rating = 0 {
        didSet {
            setupDrop()
        }
    }
    
    private var ratingImageView = [UIImageView]()
    
    @IBInspectable var dropSize: CGSize = CGSize(width: 20.0, height: 20.0) {
        didSet {
            setupDrop()
        }
    }
    @IBInspectable var dropCount: Int = 5 {
        didSet {
            setupDrop()
        }
    }
    
    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDrop()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupDrop()
    }
    
    private func setupDrop() {
        
        for imageView in ratingImageView {
            removeArrangedSubview(imageView)
            imageView.removeFromSuperview()
        }
        ratingImageView.removeAll()
        
        //Load image
        let bundle = Bundle(for: type(of: self))
        let emptyDrop = UIImage(named: Const.oilDropImage.empty.name, in: bundle, compatibleWith: self.traitCollection)
        
        for _ in 0 ..< dropCount {
            let imageView = UIImageView()
            
            //Set the button image
            imageView.image = emptyDrop
            imageView.contentMode = .scaleAspectFit
            
            //Add constraints
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.heightAnchor.constraint(equalToConstant: dropSize.height) .isActive = true
            imageView.widthAnchor.constraint(equalToConstant: dropSize.width).isActive = true
            
            addArrangedSubview(imageView)
            
            ratingImageView.append(imageView)
        }
        updateRating()
    }
    
    func updateRating() {
        
        for (index, imageView) in ratingImageView.enumerated() {
            
            let bundle = Bundle(for: type(of: self))
            let filledStar = UIImage(named: Const.oilDropImage.filled.name, in: bundle, compatibleWith: self.traitCollection)
            
            if index < rating {
                imageView.image = filledStar
            }
        }
    }
    
    
}
