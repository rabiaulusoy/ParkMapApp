//
//  ParkListViewController.swift
//  ParkMapApp
//
//  Created by rabia on 26.12.2021.
//

import Foundation
import UIKit
import CoreData

class ParkListViewController : UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var locationListModel : [ParkLocationModel] = [ParkLocationModel]()
    var selectedParkLocation : ParkLocationModel?
    let parkDetailCellId = "parkDetailCell"
    let parkDetailId = "parkDetail"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        retrieveValues()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if let parkDetailVC = segue.destination as? ParkDetailViewController  {
                parkDetailVC.locationModel = selectedParkLocation
            }
    }
    
    func retrieveValues(){
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<ParkLocationEntity>(entityName: ParkLocationEntityAttributes.ParkLocationEntity.rawValue)
            
            do {
                let results = try context.fetch(fetchRequest)
                
                for result in results {
                    guard let title = result.title,
                          let desc = result.parkDescription,
                          let dtTime = result.datetime
                    else { return }
                    
                    locationListModel.append(ParkLocationModel(latitude: result.latitude, longitude: result.longitude, title: title, description: desc, imageList: convertDataToImageList(data: result.image), datetime: dtTime))
                }
            }
            catch {
                print(ErrorCode.CantGetValuesFromDB)
            }
        }
    }
    
    func convertDataToImageList(data: NSObject?) -> [UIImage] {
        var result = [UIImage]()
        if let dataArray = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSArray.self, from: data as! Data) {
                for data in dataArray {
                    if let data = data as? Data, let image = UIImage(data: data) {
                        result.append(image)
                    }
                }
        }
        return result
    }
    
}


extension ParkListViewController :  UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.locationListModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: parkDetailCellId) as? ParkDetailCell {
            cell.arrangeCell(locationModel: locationListModel[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedParkLocation = locationListModel[indexPath.row]
        performSegue(withIdentifier: parkDetailId, sender: self)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let deleteAlert = UIAlertController(title: "Kayıt Sil", message: "Kayıt silinecektir.", preferredStyle: .alert)
            deleteAlert.addAction(UIAlertAction(title: "Sil", style: .default, handler: {(action: UIAlertAction!) in
                self.locationListModel.remove(at: indexPath.row)
                tableView.reloadData()
            }))
            deleteAlert.addAction(UIAlertAction(title: "Vazgeç", style: .default, handler: { (action: UIAlertAction!) in
                tableView.reloadData()
            }))
            present(deleteAlert, animated: true, completion: nil)
        }
    }
    
}
