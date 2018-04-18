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
        anim.fromValue = UIColor.white.cgColor
        anim.toValue = UIColor.gray.cgColor
        anim.duration = 1.2
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
    }
}

extension UIView {
    func borderGray(_ duration: TimeInterval = 1.0, _ delay: TimeInterval = 0.0, options: UIViewAnimationOptions, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
            self.layer.borderColor = UIColor.gray.cgColor
        }, completion: completion)
    }
    
    func borderWhite(_ duration: TimeInterval = 1.0, _ delay: TimeInterval = 0.0, options: UIViewAnimationOptions, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: options, animations: {
            self.layer.borderColor = UIColor.white.cgColor
        }, completion: completion)
    }
}
