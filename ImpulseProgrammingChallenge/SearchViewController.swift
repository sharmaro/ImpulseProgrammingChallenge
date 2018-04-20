//
//  SearchViewController.swift
//  ImpulseProgrammingChallenge
//
//  Created by Rohan Sharma on 4/19/18.
//  Copyright © 2018 Rohan Sharma. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.layer.cornerRadius = 5
        textField.layer.borderWidth = 2
        textField.layer.borderColor = UIColor.white.cgColor
        
        textField.text = ""
        textField.attributedPlaceholder = NSAttributedString(string: "Please begin typing here", attributes: [NSAttributedStringKey.foregroundColor: UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)])
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
