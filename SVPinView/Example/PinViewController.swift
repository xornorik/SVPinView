//
//  PinViewController.swift
//  SVPinView
//
//  Created by Srinivas Vemuri on 31/10/17.
//  Copyright © 2017 Srinivas Vemuri. All rights reserved.
//

import UIKit

class PinViewController: UIViewController {
    
    @IBOutlet var pinView:SVPinView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "SVPinView"
        
        configurePinView()
    }
    
    func configurePinView() {
        
        pinView.pinLength = 5
        pinView.secureCharacter = "\u{25CF}"
        pinView.interSpace = 5
        pinView.textColor = UIColor.black
        pinView.underlineColor = UIColor.black
        pinView.underLineThickness = 2
        pinView.shouldSecureText = true
        
        pinView.font = UIFont.systemFont(ofSize: 15)
        pinView.keyboardType = .phonePad
        pinView.pinIinputAccessoryView = UIView()
        
        pinView.didFinishCallback = didFinishEnteringPin(pin:)
    }
    
    @IBAction func printPin() {
        let pin = pinView.getPin()
        guard !pin.isEmpty else {
            showAlert(title: "Error", message: "Pin entry incomplete")
            return
        }
        showAlert(title: "Success", message: "The Pin entered is \(pin)")
    }
    
    @IBAction func clearPin() {
        pinView.clearPin()
    }
    
    func didFinishEnteringPin(pin:String) {
        showAlert(title: "Success", message: "The Pin entered is \(pin)")
    }
    
    func showAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
