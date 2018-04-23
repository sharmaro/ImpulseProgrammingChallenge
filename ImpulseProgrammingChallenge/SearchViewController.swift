//
//  SearchViewController.swift
//  ImpulseProgrammingChallenge
//
//  Created by Rohan Sharma on 4/19/18.
//  Copyright © 2018 Rohan Sharma. All rights reserved.
//

import UIKit
import Reachability

struct AutocompleteObj {
    var placeId = ""
    var mainText = ""
    var secondaryText = ""
    
    // Empty initializer
    init() {}
    
    // Initializer with useful params
    init(_ placeId: String, _ mainText: String, _ secondaryText: String) {
        self.placeId = placeId
        self.mainText = mainText
        self.secondaryText = secondaryText
    }
}

class SearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var autocompleteObjsArr = [AutocompleteObj]()
    
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
        
        textField.layer.cornerRadius = 5
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.white.cgColor
        
        textField.text = ""
        textField.attributedPlaceholder = NSAttributedString(string: "Please search for places here", attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)])
        
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        textField.becomeFirstResponder()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Getting rid of the 1px separator between UINavigationBar and UIViewController for aesthetic purposes
        let navBar = self.navigationController?.navigationBar
        navBar?.barTintColor = UIColor.black
        navBar?.isTranslucent = false
        navBar?.setBackgroundImage(UIImage(), for: .default)
        navBar?.shadowImage = UIImage()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: Helper methods
    
    func makeURLRequest(_ input: String) {
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=\(input)&types=establishment&key=\(AppDelegate.apiKey)")
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
//                        print("tableView reload data")
                        self.tableView.reloadData()
                    }
                } catch  {
                    print("error trying to convert data to JSON")
                    return
                }
                } .resume()
        }
    }
    
    func parseResponse(_ placeData: [String:Any]) {
        autocompleteObjsArr.removeAll()
        let placesArr = placeData["predictions"]! as! NSArray
//        print("placesArr: \(placeData)")
        
        for i in 0..<placesArr.count {
            var autoComplObj = AutocompleteObj()
            
            let placesDict = placesArr[i] as! NSDictionary
            let structFormatDict = placesDict["structured_formatting"] as! NSDictionary
            
            autoComplObj.placeId = placesDict["place_id"] as! String
            autoComplObj.mainText = structFormatDict["main_text"] as! String
            autoComplObj.secondaryText = structFormatDict["secondary_text"] as! String
            
//            print("self.autocompleteObjsArr.append")
            autocompleteObjsArr.append(autoComplObj)
        }
    }
    
    // MARK: @objc methods
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let text = textField.text
        
        self.makeURLRequest(text!)
    }
    
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
    
    // MARK: UITableViewDelegate methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return autocompleteObjsArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "SearchViewController"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: id, for: indexPath) as! SearchViewTableCell
        
        if indexPath.row < autocompleteObjsArr.count {
            cell.placeNameLabel.text = autocompleteObjsArr[indexPath.row].mainText
            cell.placeAddrLabel.text = autocompleteObjsArr[indexPath.row].secondaryText
        }
        
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor(red: 97/255, green: 97/255, blue: 97/255, alpha: 1.0)
        
        cell.selectedBackgroundView = selectedView
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PopUpViewController") as! PopUpViewController
        PopUpViewController.autoCompleteObj = autocompleteObjsArr[indexPath.row]
        self.present(vc, animated: true) {
            self.tableView.deselectRow(at: indexPath, animated: false)
        }
    }
}

// Cell class
class SearchViewTableCell: UITableViewCell {
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeAddrLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
