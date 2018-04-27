//
//  ViewController.swift
//  ImpulseProgrammingChallenge
//
//  Created by Rohan Sharma on 4/10/18.
//  Copyright © 2018 Rohan Sharma. All rights reserved.
//

import UIKit
import GooglePlaces
import Reachability

class ViewController: UIViewController {
    @IBOutlet weak var startButton: UIButton!
    
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
        // Do any additional setup after loading the view, typically from a nib.
        
        startButton.layer.cornerRadius = 5
        startButton.layer.borderWidth = 2
        startButton.layer.borderColor = UIColor.white.cgColor
        
        // Will call startButtonAnim when app becomes active
        NotificationCenter.default.addObserver(self, selector: #selector(startButtonAnim), name: Notification.Name.UIApplicationDidBecomeActive, object: nil)
        
        // Removes animations when app is no longer active
        NotificationCenter.default.addObserver(self, selector: #selector(removeButtonAnim), name: Notification.Name.UIApplicationWillResignActive, object: nil)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: @objc methods
    
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
    
    // Function for checking internet connection
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
