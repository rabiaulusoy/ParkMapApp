//
//  ViewController.swift
//  ParkMapApp
//
//  Created by rabia on 26.12.2021.
// modified on 07.01.2022
//

import UIKit
import MapKit
import CoreLocation
import EventKit
import EventKitUI
import CoreData

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    var locationManager = CLLocationManager()
    let eventStore = EKEventStore()
    var currentLocation : (latitude: Double, longitude: Double) = (0,0)
    var imageList : [UIImage] = [UIImage]()
    let listPageId = "parkList"
    let imageCellId = "imageCell"
    var imagePicker: UIImagePickerController!
    let annotation = MKPointAnnotation()
    var locationModel : ParkLocationModel?
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnList: UIButton!
    @IBOutlet weak var mkMapView: MKMapView!
    @IBOutlet weak var txtTitle: UITextField!
    @IBOutlet weak var txtDescription: UITextField!
    @IBOutlet weak var btnCalender: UIButton!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnSave: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.txtTitle.delegate = self
        self.txtDescription.delegate = self
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        mkMapView.delegate = self
        
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager.startUpdatingLocation()
        }
    }

    @IBAction func btnListClicked(_ sender: UIButton) {
        performSegue(withIdentifier: listPageId, sender: self)
    }
    
    @IBAction func btnSaveClicked(_ sender: UIButton) {
        guard let title = txtTitle.text else { return }
        guard let description = txtDescription.text else { return }
        
        saveParkLocation(value: ParkLocationModel(latitude: currentLocation.0, longitude: currentLocation.1, title: title, description: description, imageList: imageList, datetime: Date.now))
        
        performSegue(withIdentifier: listPageId, sender: self)
            
        txtDescription.text = ""
        imageList = [UIImage]()
        collectionView.reloadData()
    }
    
    func saveParkLocation(value: ParkLocationModel) {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let context = appDelegate.persistentContainer.viewContext
            
            guard let entityDescription = NSEntityDescription.entity(forEntityName: ParkLocationEntityAttributes.ParkLocationEntity.rawValue, in: context) else { return }
                    
            let newValue =  NSManagedObject(entity: entityDescription, insertInto: context)
            newValue.setValue(convertImageToData(images: value.imageList), forKey: ParkLocationEntityAttributes.image.rawValue)
            newValue.setValue(value.datetime, forKey: ParkLocationEntityAttributes.datetime.rawValue)
            newValue.setValue(value.latitude, forKey: ParkLocationEntityAttributes.latitude.rawValue)
            newValue.setValue(value.longitude, forKey: ParkLocationEntityAttributes.longitude.rawValue)
            newValue.setValue(value.description, forKey: ParkLocationEntityAttributes.parkDescription.rawValue)
            newValue.setValue(value.title, forKey: ParkLocationEntityAttributes.title.rawValue)
            
            do {
                try context.save()
            }
            catch {
                print(ErrorCode.SaveParkLocationError)
            }
        }
    }
    
    func convertImageToData(images : [UIImage]) -> Data? {
        let dataArray = NSMutableArray()
        
        for img in images {
            if let data = img.pngData() {
                dataArray.add(data)
            }
        }
        
        return try? NSKeyedArchiver.archivedData(withRootObject: dataArray, requiringSecureCoding: true)
    }
}

extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: imageCellId, for: indexPath) as? ImageCell {
            cell.arrangeCell(carImg: imageList[indexPath.row], isNew: true)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newImageView = UIImageView(image: imageList[indexPath.row])
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

extension ViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if currentLocation.longitude == 0 && currentLocation.latitude == 0 {
            if let location = locations.last{
                
                let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                self.mkMapView.setRegion(region, animated: true)
                
                currentLocation = (center.latitude,center.longitude)
                
                let address = CLGeocoder.init()
                address.reverseGeocodeLocation(CLLocation.init(latitude: center.latitude, longitude:center.longitude)) { (places, error) in
                        if error == nil{
                            guard let placeMark = places?.first else { return }
                             if let street = placeMark.thoroughfare {
                                if let city = placeMark.subAdministrativeArea {
                                    if let country = placeMark.country {
                                        self.txtTitle.text = "\(street), \(city), \(country)"
                                    }
                                }
                             }
                        }
                    }
              }
        }
    }
    
}

extension ViewController : MKMapViewDelegate {
    
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        annotation.coordinate = mapView.centerCoordinate
        mkMapView.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        currentLocation = (mapView.centerCoordinate.latitude,mapView.centerCoordinate.longitude)
        
        let address = CLGeocoder.init()
        address.reverseGeocodeLocation(CLLocation.init(latitude: mapView.centerCoordinate.latitude, longitude:mapView.centerCoordinate.longitude)) { (places, error) in
                if error == nil{
                    guard let placeMark = places?.first else { return }
                     if let street = placeMark.thoroughfare {
                        if let city = placeMark.subAdministrativeArea {
                            if let country = placeMark.country {
                                self.txtTitle.text = "\(street), \(city), \(country)"
                            }
                        }
                     }
                }
            }
    }
    
}

extension ViewController : EKEventEditViewDelegate {
    
    @IBAction func btnCalenderClicked(_ sender: UIButton) {
        
        switch EKEventStore.authorizationStatus(for: .event){
        case .authorized:
            insertEvent(store: eventStore)
        case .denied:
            print(ErrorCode.AccesDenied)
        case .notDetermined:
            eventStore.requestAccess(to: .event, completion: {
                (response, error) in
                if error != nil {
                    print(ErrorCode.AccesDenied)
                    return
                }
                self.insertEvent(store: self.eventStore)
            })
        default:
            break
        }
    }
        
    func insertEvent(store: EKEventStore) {
        DispatchQueue.main.async {
            let startDate = Date()
            let endDate = startDate.addingTimeInterval(1*60*60)
            
            let event = EKEvent(eventStore: store)
            event.title = self.txtTitle.text
            event.notes = self.txtDescription.text
            event.startDate = startDate
            event.endDate = endDate
            event.calendar = store.defaultCalendarForNewEvents
            
            let structuredLocation = EKStructuredLocation(title: "Park Konumunuz")
                structuredLocation.geoLocation = CLLocation(latitude: self.currentLocation.latitude, longitude: self.currentLocation.longitude)
            event.structuredLocation = structuredLocation
        
            let eventController = EKEventEditViewController()
            eventController.event = event
            eventController.eventStore = store
            eventController.editViewDelegate = self
            self.present(eventController, animated: true, completion: nil)
        }
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}

extension ViewController : UIImagePickerControllerDelegate {
    
    @IBAction func btnCameraClicked(_ sender: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                   selectImageFrom(.photoLibrary)
                   return
               }
               selectImageFrom(.camera)
    }
    
    func selectImageFrom(_ source: ImageSource){
            imagePicker =  UIImagePickerController()
            imagePicker.delegate = self
            switch source {
            case .camera:
                imagePicker.sourceType = .camera
            case .photoLibrary:
                imagePicker.sourceType = .photoLibrary
            }
            present(imagePicker, animated: true, completion: nil)
        }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
               guard let selectedImage = info[.originalImage] as? UIImage else {
                   print(ErrorCode.ImageNotFound)
                   return
               }
        
        imageList.append(selectedImage)
        self.collectionView.reloadData()
    }
    
}

extension ViewController : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
            return true
    }
    
}

