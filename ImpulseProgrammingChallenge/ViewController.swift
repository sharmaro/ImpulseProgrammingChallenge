//
//  ViewController.swift
//  ImpulseProgrammingChallenge
//
//  Created by Rohan Sharma on 4/10/18.
//  Copyright © 2018 Rohan Sharma. All rights reserved.
//

import UIKit
import GooglePlaces

class ViewController: UIViewController {
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        startButton.layer.cornerRadius = 5
        startButton.layer.borderWidth = 2
        startButton.layer.borderColor = UIColor.white.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        present(autocompleteController, animated: true, completion: nil)
    }
}

// From Google Places API Docs
extension ViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress!)")
        print("Place attributions: \(place.attributions!)")
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // User canceled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
}
