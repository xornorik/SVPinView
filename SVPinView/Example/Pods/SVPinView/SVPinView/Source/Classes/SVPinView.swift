//
//  SVPinView.swift
//  SVPinView
//
//  Created by Srinivas Vemuri on 10/10/17.
//  Copyright © 2017 Xornorik. All rights reserved.
//

import UIKit

@objc
public class SVPinView: UIView {
    
    @IBOutlet var collectionView : UICollectionView!
    
    var flowLayout: UICollectionViewFlowLayout {
        return self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    @IBInspectable public var pinLength:Int = 5
    @IBInspectable public var secureCharacter:String = "\u{25CF}"
    @IBInspectable public var interSpace:CGFloat = 5
    @IBInspectable public var textColor:UIColor = UIColor.black
    @IBInspectable public var underlineColor:UIColor = UIColor.black
    @IBInspectable public var underLineThickness:CGFloat = 2
    @IBInspectable public var shouldSecureText:Bool = true
    
    public var font:UIFont = UIFont.systemFont(ofSize: 15)
    public var keyboardType:UIKeyboardType = UIKeyboardType.phonePad
    public var pinIinputAccessoryView:UIView = UIView()
    
    var password = [String]()
    public var didFinishCallback: ((String)->())?
    
    var view:UIView!
    var reuseIdentifier = "SVPinCell"
    var isResetting = false

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadView()
    }
    
    func loadView() {
        let podBundle = Bundle(for: SVPinView.self)
        let nib = UINib(nibName: "SVPinView", bundle: podBundle)
        view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        //for CollectionView
        let collectionViewNib = UINib(nibName: "SVPinCell", bundle:podBundle)
        collectionView.register(collectionViewNib, forCellWithReuseIdentifier: reuseIdentifier)
        flowLayout.scrollDirection = .vertical //weird!!!
        collectionView.isScrollEnabled = false

        self.addSubview(view)
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        var nextTag = textField.tag
        let index = nextTag - 100
        
        //ensure single character in text box and trim spaces
        if textField.text!.count > 1 {
            textField.text?.removeFirst()
            textField.text = { () -> String in
                let text = textField.text ?? ""
                return String(text[..<text.index((text.startIndex), offsetBy: 1)])
            }()
        }
        
        let isBackSpace = { () -> Bool in
            let char = textField.text!.cString(using: String.Encoding.utf8)!
            if strcmp(char, "\\b") == -92 {
                return true
            } else {
                return false
            }
        }
        
        //check if entered text is backspace
        if isBackSpace() {
            nextTag = textField.tag - 1
        } else {
            nextTag = textField.tag + 1
        }
        
        // Try to find next responder
        let nextResponder = textField.superview?.superview?.superview?.superview?.viewWithTag(nextTag) as UIResponder!
        if (nextResponder != nil) {
            // Found next responder, so set it.
            nextResponder?.becomeFirstResponder()
        } else {
            // Not found, so dismiss keyboard
            textField.resignFirstResponder()
        }
        
        //secure text after a bit
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
            if textField.text == "" {
                textField.text = " "
            } else {
                if self.shouldSecureText {textField.text = self.secureCharacter} else {}
            }
        })

        //store text 
        let text =  textField.text ?? ""
        let passwordIndex = index - 1
        if password.count > (passwordIndex) {
            //delete if space 
            if text == " " {
                password[passwordIndex] = ""
            } else {
                password[passwordIndex] = text
            }
        } else {
            password.append(text)
        }
        validateAndSendCallback()
    }
    
    @objc
    public func getPin() -> String {
        guard password.count == pinLength && password.joined().trimmingCharacters(in: CharacterSet(charactersIn: " ")).count == pinLength else {
            print("")
            return ""
        }
        return password.joined()
    }
    
    @objc
    public func clearPin() {
        password.removeAll()
        isResetting = true
        self.collectionView.reloadData()
    }
    
    func validateAndSendCallback() {
        let pin = getPin()
        guard !pin.isEmpty else {return}
        if didFinishCallback != nil {
            didFinishCallback!(pin)
        }
    }
}
extension SVPinView : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
{
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pinLength
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        //The tag of the last cell of the pinView is (100 + (pinLength - indexPath.row))
        let textField = isResetting ? (cell.viewWithTag(100 + (pinLength - indexPath.row)) as! UITextField) : (cell.viewWithTag(100) as! UITextField)
        let underLine = cell.viewWithTag(50)!

        //Setting up textField
        textField.tag = 101 + indexPath.row //textField.tag += (indexPath.row + 1)
        textField.text = " "
        textField.isSecureTextEntry = false
        textField.textColor = self.textColor
        textField.tintColor = textColor
        textField.font = self.font
        textField.keyboardType = self.keyboardType
        textField.inputAccessoryView = self.pinIinputAccessoryView
        
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        //underLine Setup
        underLine.backgroundColor = underlineColor
        underLine.constraints.filter { (constraint) -> Bool in
            return constraint.identifier == "underlineHeight"
        }.first?.constant = underLineThickness
        
        //reset the resetFlag :P
        if isResetting && (indexPath.row == pinLength - 1) {
            isResetting = false
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - (interSpace * CGFloat(max(pinLength, 1) - 1)))/CGFloat(pinLength)
        return CGSize(width: width, height: collectionView.bounds.height)
    }
        
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return interSpace
    }
    
    public override func layoutSubviews() {
        flowLayout.invalidateLayout()
    }
}
extension SVPinView : UITextFieldDelegate
{
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        let text = textField.text!

        if text.count == 0 {
            textField.isSecureTextEntry = false
            textField.text =  " "
        }
    }
}
