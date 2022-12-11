//
//  RatingControl.swift
//  MyPlaces
//
//  Created by Dmytro Grytsenko on 25.11.2022.
//

import UIKit

@IBDesignable class RatingControl: UIStackView {
    
    var rating = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }
    
    private var ratingButtons = [UIButton]()
    
    @IBInspectable var dropSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet {
            setupButtons()
        }
    }
    @IBInspectable var dropCount: Int = 5 {
        didSet {
            setupButtons()
        }
    }
    
    //MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    //MARK: - Button action
    
    @objc func ratingButtonTapped(button: UIButton) {
        
        guard let index = ratingButtons.firstIndex(of: button) else { return }
        
        //Calculate the rating of the selected button
        let selectedRating = index + 1
        
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    
    private func setupButtons() {
        
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
        }
        ratingButtons.removeAll()
        
        //Load button image
        let bundle = Bundle(for: type(of: self))
        let filledDrop = UIImage(named: Const.oilDropImage.filled.name, in: bundle, compatibleWith: self.traitCollection)
        let emptyDrop = UIImage(named: Const.oilDropImage.empty.name, in: bundle, compatibleWith: self.traitCollection)
        let highlightedDrop = UIImage(named: Const.oilDropImage.highlighted.name, in: bundle, compatibleWith: self.traitCollection)
        
        for _ in 0 ..< dropCount {
            let button = UIButton()
            
            //Set the button image
            button.setImage(emptyDrop, for: .normal)
            button.setImage(filledDrop, for: .selected)
            button.setImage(highlightedDrop, for: .highlighted)
            button.setImage(highlightedDrop, for: [.highlighted, .selected])
            button.imageView?.contentMode = .scaleAspectFit
            
            //Add constraints
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: dropSize.height) .isActive = true
            button.widthAnchor.constraint(equalToConstant: dropSize.width).isActive = true
            
            //Setup the button action
            button.addTarget(self, action: #selector(ratingButtonTapped), for: .touchUpInside)
            
            addArrangedSubview(button)
            ratingButtons.append(button)
        }
        updateButtonSelectionState()
    }
    
    private func updateButtonSelectionState() {
        
        for (index, button) in ratingButtons.enumerated() {
            
            button.isSelected = index < rating
        }
    }
    
    func dropAnimation() {
                
        for (index, button) in ratingButtons.enumerated() {
            
            button.transform = CGAffineTransform(scaleX: 0, y: 0)
            
            let delay = Double(index) * 0.3
            
            UIView.animate(withDuration: 0.6, delay: delay, usingSpringWithDamping: 0.5, initialSpringVelocity: 0, options: .curveEaseInOut) {
                
                button.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
        }
    }
    
}
