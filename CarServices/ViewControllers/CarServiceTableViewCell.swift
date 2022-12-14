//
//  CarServiceTableViewCell.swift
//  CarServices
//
//  Created by Dmytro Grytsenko on 05.12.2022.
//

import UIKit

class CarServiceTableViewCell: UITableViewCell {
    
    var callManager: CallManager?
    
    @IBOutlet weak var imageOfService: UIImageView! {
        didSet {
            imageOfService.makeCorner(cornerRadius: 10)
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
        //set the values for top, left, bottom, right margins
        let margins = UIEdgeInsets(top: 7, left: 14, bottom: 7, right: 14)
        contentView.frame = contentView.frame.inset(by: margins)
        contentView.makeCorner(cornerRadius: 10)
    }
    
    func configureCell(indexPath: IndexPath, servise: Service, callManager: CallManager) {
        
        nameLabel.text = servise.name
        typeLabel.text = servise.type
        locationLabel.text = servise.location
        phoneLabel.text = servise.phone
        cellRating.rating = Int(servise.rating)
        
        imageOfService.image = UIImage(data: servise.imageData!)
        contentMode = .scaleAspectFill
        
        self.callManager = callManager
    }
    
    @IBAction func phoneTapped(_ sender: UIButton) {
        
        guard let servicePhone = phoneLabel.text else { return }
        callManager?.callNumber(phoneNumber: servicePhone)
    }
    
}
