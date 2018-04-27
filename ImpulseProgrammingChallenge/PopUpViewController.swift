//
//  PopUpViewController.swift
//  ImpulseProgrammingChallenge
//
//  Created by Rohan Sharma on 4/21/18.
//  Copyright © 2018 Rohan Sharma. All rights reserved.
//

import UIKit
import MapKit
import Reachability

class PopUpViewController: UIViewController {
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var placeNameLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var directionsBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    static var autoCompleteObj = AutocompleteObj()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: AppDelegate.reachability)
        do{
            try AppDelegate.reachability.startNotifier()
        }catch{
            print("could not start reachability notifier")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popupView.layer.cornerRadius = 5
        popupView.layer.borderWidth = 1
        popupView.layer.borderColor = UIColor(red: 0, green: 161/255, blue: 121/255, alpha: 1.0).cgColor

        directionsBtn.layer.cornerRadius = 5
        directionsBtn.layer.borderWidth = 1
        directionsBtn.layer.borderColor = UIColor.white.cgColor
        directionsBtn.tag = 0
        
        cancelBtn.layer.cornerRadius = 5
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.borderColor = UIColor.red.cgColor
        cancelBtn.tag = 1
        
        setupLabels()
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    // MARK: Helper methods
    
    func setupLabels() {
        placeNameLbl.text = PopUpViewController.autoCompleteObj.mainText
        addressLbl.text = PopUpViewController.autoCompleteObj.secondaryText
    }
    
    func makePlaceIDRequest(_ id: String) {
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(id)&key=\(AppDelegate.apiKey)")
        if url != nil {
            let request = URLRequest(url: url!)
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if error != nil {
                    print(error!.localizedDescription)
                }
                
                guard let respData = data else {
                    print("respData is nil")
                    return
                }
                
                do {
                    guard let placeData = try JSONSerialization.jsonObject(with: respData, options: JSONSerialization.ReadingOptions.allowFragments)
                        as? [String: Any] else {
                            print("error trying to convert data to JSON")
                            return
                    }
                    
                    // Should not update UI from background thread
                    DispatchQueue.main.async {
                        self.parseResponse(placeData)
                    }
                } catch  {
                    print("error trying to convert data to JSON")
                    return
                }
                } .resume()
        }
    }
    
    func parseResponse(_ data: [String:Any]) {
        let resultDict = data["result"] as! NSDictionary
        let geometryDict = resultDict["geometry"] as! NSDictionary
        let locationDict = geometryDict["location"] as! NSDictionary
        
        let coord = CLLocationCoordinate2DMake(locationDict["lat"]! as! CLLocationDegrees, locationDict["lng"]! as! CLLocationDegrees)
        
        showMaps(coord)
    }
    
    func showMaps(_ coord: CLLocationCoordinate2D) {
        let mapAlertController = UIAlertController(title: "Directions", message: nil, preferredStyle: .actionSheet)
        
        let appleMapsAction = UIAlertAction(title: "Apple Maps", style: .default) { (action) in
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coord, addressDictionary: nil))
            mapItem.name = PopUpViewController.autoCompleteObj.mainText
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        }
        mapAlertController.addAction(appleMapsAction)
        
        if UIApplication.shared.canOpenURL(URL(string: "comgooglemaps://")!) {
            let googleMapsAction = UIAlertAction(title: "Google Maps", style: .default) { (action) in
                UIApplication.shared.open(URL(string: "comgooglemaps://?saddr=&daddr=\(coord.latitude),\(coord.longitude)&directionsmode=driving")!, options: [:], completionHandler: nil)
            }
            mapAlertController.addAction(googleMapsAction)
        }
        
        if UIApplication.shared.canOpenURL(URL(string: "waze://")!) {
            let wazeMapsAction = UIAlertAction(title: "Waze", style: .default) { (action) in
                UIApplication.shared.open(URL(string: "waze://?ll=\(coord.latitude),\(coord.longitude)&navigate=yes")!, options: [:], completionHandler: nil)
            }
            mapAlertController.addAction(wazeMapsAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        mapAlertController.addAction(cancelAction)
        
        self.present(mapAlertController, animated: true, completion: nil)
    }
    
    // MARK: @objc methods
    
    @objc func reachabilityChanged(note: Notification) {
        let reachability = note.object as! Reachability
        
        let alertController = UIAlertController(title: "No Internet Connection", message: "Please try again", preferredStyle: .alert)
        let okayAction = UIAlertAction(title: "Okay", style: .default, handler: nil)
        alertController.addAction(okayAction)
        
        switch reachability.connection {
        case .wifi:
            print("Reachable via WiFi")
            alertController.dismiss(animated: true, completion: nil)
        case .cellular:
            print("Reachable via Cellular")
            alertController.dismiss(animated: true, completion: nil)
        case .none:
            print("Network not reachable")
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    // MARK: IBAction methods
    
    @IBAction func btnTchDown(_ sender: Any) {
        if let button = sender as? UIButton {
            button.alpha = 0.5
        }
    }
    
    @IBAction func btnDragExit(_ sender: Any) {
        if let button = sender as? UIButton {
            button.alpha = 1.0
        }
    }
    
    @IBAction func btnDragIn(_ sender: Any) {
        if let button = sender as? UIButton {
            button.alpha = 0.5
        }
    }
    
    @IBAction func btnTchUpIn(_ sender: Any) {
        if let button = sender as? UIButton {
            button.alpha = 1.0
            
            switch button.tag {
            case 0: // Directions button
                makePlaceIDRequest(PopUpViewController.autoCompleteObj.placeId)
            case 1: // Done button
                self.dismiss(animated: true, completion: nil)
            default:
                break
            }
        }
    }
}
