//
//  ViewController.swift
//  ImpulseProgrammingChallenge
//
//  Created by Rohan Sharma on 4/10/18.
//  Copyright © 2018 Rohan Sharma. All rights reserved.
//

import UIKit
import GooglePlaces


// Struct that holds important info from Google Autocompelete Request response
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

class ViewController: UIViewController {
    @IBOutlet weak var startButton: UIButton!
    
    var autocompleteObjsArr = [AutocompleteObj]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        startButton.layer.cornerRadius = 5
        startButton.layer.borderWidth = 2
        startButton.layer.borderColor = UIColor.white.cgColor
        
        // Will call startButtonAnim when app becomes active
        NotificationCenter.default.addObserver(self, selector: #selector(startButtonAnim), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        
        // Removes animations when devices is no longer active
        NotificationCenter.default.addObserver(self, selector: #selector(removeButtonAnim), name: Notification.Name.UIApplicationWillResignActive, object: nil)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: My Methods
    
    func makeURLRequest() {
        let url = NSURL(string: "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=Chip&types=establishment&key=\(AppDelegate.apiKey)")! as URL
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
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
                
                self.parseResponse(placeData)
                
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
            } .resume()
    }
    
    func parseResponse(_ placeData: [String:Any]) {
        let placesArr = placeData["predictions"]! as! NSArray
        
        for i in 0..<placesArr.count {
            var autoComplObj = AutocompleteObj()
            
            let placesDict = placesArr[i] as! NSDictionary
            let structFormatDict = placesDict["structured_formatting"] as! NSDictionary
            
            autoComplObj.placeId = placesDict["place_id"] as! String
            autoComplObj.mainText = structFormatDict["main_text"] as! String
            autoComplObj.secondaryText = structFormatDict["secondary_text"] as! String
            
            autocompleteObjsArr.append(autoComplObj)
        }
        
        for obj in autocompleteObjsArr {
            print("obj: \(obj)\n")
        }
    }
    
    // MARK: @objc Methods
    
    @objc func startButtonAnim() {
        let anim = CABasicAnimation(keyPath: "borderColor")
        anim.autoreverses = true
        anim.repeatCount = .infinity
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        anim.fromValue = UIColor.white.cgColor
        anim.toValue = UIColor.black.cgColor
        anim.duration = 2.0
        startButton.layer.add(anim, forKey: "")
    }
    
    @objc func removeButtonAnim() {
        self.view.layer.removeAllAnimations()
    }
    
    // MARK: IBAction Methods
    
    @IBAction func btnTchDown(_ sender: Any) {
        if let btn = sender as? UIButton {
            btn.alpha = 0.5
        }
    }
    
    @IBAction func btnTchDragExit(_ sender: Any) {
        if let btn = sender as? UIButton {
            btn.alpha = 1.0
        }
    }
    
    @IBAction func btnTchDragOut(_ sender: Any) {
        if let btn = sender as? UIButton {
            btn.alpha = 1.0
        }
    }
    
    // Where action should trigger
    @IBAction func btnTchUpIn(_ sender: Any) {
        if let btn = sender as? UIButton {
            btn.alpha = 1.0
        }
        
        startButton.layer.removeAllAnimations()
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        self.present(vc, animated: true, completion: nil)
    }
}
