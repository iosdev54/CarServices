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
            setupStar()
        }
    }
    
    private var ratingImageView = [UIImageView]()
    
    @IBInspectable var starSize: CGSize = CGSize(width: 13.0, height: 13.0) {
        didSet {
            setupStar()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet {
            setupStar()
        }
    }
    
    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupStar()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupStar()
    }
    
    private func setupStar() {
        
        for imageView in ratingImageView {
            removeArrangedSubview(imageView)
            imageView.removeFromSuperview()
        }
        ratingImageView.removeAll()
        
        //Load image
        let bundle = Bundle(for: type(of: self))
        let emptyStar = UIImage(named: "emptyStar", in: bundle, compatibleWith: self.traitCollection)
        
        for _ in 0 ..< starCount {
            let imageView = UIImageView()
            
            //Set the button image
            imageView.image = emptyStar
            
            //Add constraints
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.heightAnchor.constraint(equalToConstant: starSize.height) .isActive = true
            imageView.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            addArrangedSubview(imageView)
            
            ratingImageView.append(imageView)
        }
        updateRating()
    }
    
    func updateRating() {
        
        for (index, imageView) in ratingImageView.enumerated() {
            
            let bundle = Bundle(for: type(of: self))
            let highlightedStar = UIImage(named: "highlightedStar", in: bundle, compatibleWith: self.traitCollection)
            
            if index < rating {
                imageView.image = highlightedStar
            }
        }
    }
    
    
}
