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

class ViewController: UIViewController {
    @IBOutlet weak var startButton: UIButton!
    
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
    
    // MARK: @objc Methods
    
    @objc func startButtonAnim() {
        let anim = CABasicAnimation(keyPath: "borderColor")
        anim.autoreverses = true
        anim.repeatCount = .infinity
        anim.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        anim.fromValue = UIColor.white.cgColor
        anim.toValue = UIColor.black.cgColor
        anim.duration = 1.5
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
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "SearchViewNavController") as! UINavigationController
        self.present(vc, animated: true, completion: nil)
    }
}
