//
//  PinViewController.swift
//  SVPinView
//
//  Created by Srinivas Vemuri on 31/10/17.
//  Copyright © 2017 Xornorik. All rights reserved.
//
import UIKit
import SVPinView

class PinViewController: UIViewController {
    
    @IBOutlet var pinView:SVPinView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "SVPinView"
        configurePinView()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Setup background gradient
        let valenciaColor = UIColor(red: 218/255, green: 68/255, blue: 83/255, alpha: 1)
        let discoColor = UIColor(red: 137/255, green: 33/255, blue: 107/255, alpha: 1)
        setGradientBackground(view: self.view, colorTop: valenciaColor, colorBottom: discoColor)
    }
    
    func configurePinView() {
        
        pinView.pinLength = 6
        pinView.secureCharacter = "\u{25CF}"
        pinView.interSpace = 10
        pinView.textColor = UIColor.white
        pinView.borderLineColor = UIColor.white
        pinView.activeBorderLineColor = UIColor.white
        pinView.borderLineThickness = 1
        pinView.shouldSecureText = true
        pinView.allowsWhitespaces = false
        pinView.style = .none
        pinView.fieldBackgroundColor = UIColor.white.withAlphaComponent(0.3)
        pinView.activeFieldBackgroundColor = UIColor.white.withAlphaComponent(0.5)
        pinView.fieldCornerRadius = 15
        pinView.activeFieldCornerRadius = 15
        pinView.placeholder = "******"
        pinView.becomeFirstResponderAtIndex = 0
        
        pinView.font = UIFont.systemFont(ofSize: 15)
        pinView.keyboardType = .phonePad
        pinView.pinInputAccessoryView = { () -> UIView in
            let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
            doneToolbar.barStyle = UIBarStyle.default
            let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(dismissKeyboard))
            
            var items = [UIBarButtonItem]()
            items.append(flexSpace)
            items.append(done)
            
            doneToolbar.items = items
            doneToolbar.sizeToFit()
            return doneToolbar
        }()
        
        pinView.didFinishCallback = didFinishEnteringPin(pin:)
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(false)
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
    
    @IBAction func pastePin() {
        guard let pin = UIPasteboard.general.string else {
            showAlert(title: "Error", message: "Clipboard is empty")
            return
        }
        pinView.pastePin(pin: pin)
    }
    
    @IBAction func toggleStyle() {
        var nextStyle = pinView.style.rawValue + 1
        if nextStyle == 3 {nextStyle = 0}
        let style = SVPinViewStyle(rawValue: nextStyle)!
        switch style {
        case .none:
            pinView.fieldBackgroundColor = UIColor.white.withAlphaComponent(0.3)
            pinView.activeFieldBackgroundColor = UIColor.white.withAlphaComponent(0.5)
            pinView.fieldCornerRadius = 15
            pinView.activeFieldCornerRadius = 15
            pinView.style = style
        case .box:
            pinView.activeBorderLineThickness = 4
            pinView.fieldBackgroundColor = UIColor.clear
            pinView.activeFieldBackgroundColor = UIColor.clear
            pinView.fieldCornerRadius = 0
            pinView.activeFieldCornerRadius = 0
            pinView.style = style
        case .underline:
            pinView.activeBorderLineThickness = 4
            pinView.fieldBackgroundColor = UIColor.clear
            pinView.activeFieldBackgroundColor = UIColor.clear
            pinView.fieldCornerRadius = 0
            pinView.activeFieldCornerRadius = 0
            pinView.style = style
        }
        clearPin()
    }
    
    func didFinishEnteringPin(pin:String) {
        showAlert(title: "Success", message: "The Pin entered is \(pin)")
    }
    
    // MARK: Helper Functions
    func showAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setGradientBackground(view:UIView, colorTop:UIColor, colorBottom:UIColor) {
        for layer in view.layer.sublayers! {
            if layer.name == "gradientLayer" {
                layer.removeFromSuperlayer()
            }
        }
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop.cgColor, colorBottom.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = view.bounds
        gradientLayer.name = "gradientLayer"
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
}
