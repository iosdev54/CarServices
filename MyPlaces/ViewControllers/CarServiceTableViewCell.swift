//
//  CarServiceTableViewCell.swift
//  MyPlaces
//
//  Created by Dmytro Grytsenko on 05.12.2022.
//

import UIKit

class CarServiceTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageOfPlace: UIImageView! {
        didSet {
            imageOfPlace.layer.cornerRadius = 10
            imageOfPlace.clipsToBounds = true
        }
    }
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var cellRating: CellRating!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        applyShadow(cornerRadius: 10)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //set the values for top,left,bottom,right margins
        let margins = UIEdgeInsets(top: 7, left: 14, bottom: 7, right: 14)
        contentView.frame = contentView.frame.inset(by: margins)
        contentView.layer.cornerRadius = 10
    }
    
    @IBAction func phoneTapped(_ sender: UIButton) {
        print("Phone Tapped")
    }
    
    func configureCell(indexPath: IndexPath, servise: Place) {
        
        nameLabel.text = servise.name
        typeLabel.text = servise.type
        locationLabel.text = servise.location
        //        phoneLabel.text = servise.phone
        cellRating.rating = Int(servise.rating)
        
        imageOfPlace.image = UIImage(data: servise.imageData!)
        contentMode = .scaleAspectFill
    }
    
}
