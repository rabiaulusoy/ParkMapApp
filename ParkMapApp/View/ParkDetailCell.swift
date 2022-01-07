//
//  ParkDetailCell.swift
//  ParkMapApp
//
//  Created by rabia on 26.12.2021.
//

import UIKit

class ParkDetailCell : UITableViewCell {
    
    @IBOutlet weak var txtTitle: UILabel!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var txtImage: UIImageView!
    @IBOutlet weak var lblDateTime: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func arrangeCell(locationModel : ParkLocationModel){
        txtTitle.text = locationModel.title
        txtDescription.text = locationModel.description
        
        let df = DateFormatter()
        df.dateFormat = "YY, MMM d, HH:mm:ss"
        lblDateTime.text = df.string(from: locationModel.datetime)
        
        if locationModel.imageList.isEmpty {
            txtImage.image = UIImage(systemName: "photo.artframe")
            return
        }
        txtImage.image = locationModel.imageList[0]
        txtImage.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
    }
}
