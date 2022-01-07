//
//  ImageCell.swift
//  ParkMapApp
//
//  Created by rabia on 26.12.2021.
//

import UIKit

class ImageCell : UICollectionViewCell {
    
    @IBOutlet weak var imageCell: UIImageView!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func arrangeCell(carImg : UIImage, isNew: Bool){
        imageCell.image = carImg
        if isNew == false {
            imageCell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi/2))
        }
    }
}
