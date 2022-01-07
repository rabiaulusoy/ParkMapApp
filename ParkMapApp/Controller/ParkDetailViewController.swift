//
//  ParkDetailViewController.swift
//  ParkMapApp
//
//  Created by rabia on 26.12.2021.
//

import Foundation
import UIKit
import MapKit

class ParkDetailViewController: UIViewController {
    
    var locationModel: ParkLocationModel!
    let annotation = MKPointAnnotation()

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var btnNavigate: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        mapView.delegate = self
        mapView.isZoomEnabled = false
        mapView.isScrollEnabled = false
        mapView.isUserInteractionEnabled = false
        
        lblTitle.text = locationModel.title
        txtDescription.text = locationModel.description
        
        let center = CLLocationCoordinate2D(latitude: locationModel.latitude, longitude: locationModel.longitude)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        
        self.mapView.setRegion(region, animated: true)
    }
    
    @IBAction func btnNavigavetClicked(_ sender: Any) {
        let latDouble = Double(locationModel.latitude)
        let longDouble = Double(locationModel.longitude)
        
        if let url = URL(string: "comgooglemaps://?saddr=&daddr=\(latDouble),\(longDouble)&directionsmode=driving") {
                UIApplication.shared.open(url, options: [:])
            }
    }
    
}

extension ParkDetailViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return locationModel.imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as? ImageCell {
            cell.arrangeCell(carImg: locationModel.imageList[indexPath.row], isNew: false)
            return cell
            
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let newImageView = UIImageView(image: locationModel.imageList[indexPath.row])
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
}

extension ParkDetailViewController: MKMapViewDelegate {
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        annotation.coordinate = mapView.centerCoordinate
        mapView.addAnnotation(annotation)
    }
    
}
