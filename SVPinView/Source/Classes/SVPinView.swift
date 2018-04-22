//
//  SVPinView.swift
//  SVPinView
//
//  Created by Srinivas Vemuri on 10/10/17.
//  Copyright © 2017 Xornorik. All rights reserved.
//

import UIKit

@objc
public enum SVPinViewStyle : Int {
    case none = 0
    case underline
    case box
}

@objc
public class SVPinView: UIView {
    
    @IBOutlet fileprivate var collectionView : UICollectionView!
    
    fileprivate var flowLayout: UICollectionViewFlowLayout {
        return self.collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
    }
    
    @IBInspectable public var pinLength:Int = 5
    @IBInspectable public var secureCharacter:String = "\u{25CF}"
    @IBInspectable public var interSpace:CGFloat = 5
    @IBInspectable public var textColor:UIColor = UIColor.black
    @IBInspectable public var borderLineColor:UIColor = UIColor.black
    @IBInspectable public var borderLineThickness:CGFloat = 2
    @IBInspectable public var shouldSecureText:Bool = true
    @IBInspectable public var fieldBackgroundColor:UIColor = UIColor.clear
    @IBInspectable public var fieldCornerRadius:CGFloat = 0
    public var style:SVPinViewStyle = .underline
    
    public var font:UIFont = UIFont.systemFont(ofSize: 15)
    public var keyboardType:UIKeyboardType = UIKeyboardType.phonePad
    public var pinIinputAccessoryView:UIView = UIView()
    
    fileprivate var password = [String]()
    public var didFinishCallback: ((String)->())?
    
    fileprivate var view:UIView!
    fileprivate var reuseIdentifier = "SVPinCell"
    fileprivate var isResetting = false

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadView()
    }
    
    private func loadView() {
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
    
    @objc fileprivate func textFieldDidChange(_ textField: UITextField) {
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
    
    private func validateAndSendCallback() {
        let pin = getPin()
        guard !pin.isEmpty else {return}
        if didFinishCallback != nil {
            didFinishCallback!(pin)
        }
    }
    
    //MARK: Public methods
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
    
    @objc
    public func pastePin(pin:String) {
        
        password = []
        for (index,char) in pin.enumerated() {
            
            guard index < pinLength else {return}
            
            //Get the first textField
            let textField = collectionView.cellForItem(at: IndexPath(item: index, section: 0))?.viewWithTag(101 + index) as! SVPinField
            textField.text = String(char)
            
            //secure text after a bit
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                if textField.text == "" {
                    textField.text = " "
                } else {
                    if self.shouldSecureText {textField.text = self.secureCharacter} else {}
                }
            })
            
            //store text
            password.append(String(char))
            validateAndSendCallback()
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
        let textField = isResetting ? (cell.viewWithTag(100 + (pinLength - indexPath.row)) as! SVPinField) : (cell.viewWithTag(100) as! SVPinField)
        let containerView = cell.viewWithTag(51)!
        let underLine = cell.viewWithTag(50)!

        //Setting up textField
        textField.tag = 101 + indexPath.row
        textField.text = " "
        textField.isSecureTextEntry = false
        textField.textColor = self.textColor
        textField.tintColor = textColor
        textField.font = self.font
        textField.keyboardType = self.keyboardType
        textField.inputAccessoryView = self.pinIinputAccessoryView
        
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        containerView.backgroundColor = fieldBackgroundColor
        containerView.layer.cornerRadius = fieldCornerRadius
        
        func setupUnderline(color:UIColor, withThickness thickness:CGFloat) {
            underLine.backgroundColor = color
            underLine.constraints.filter { (constraint) -> Bool in
                return constraint.identifier == "underlineHeight"
                }.first?.constant = thickness
        }
        
        switch style {
        case .none:
            setupUnderline(color: UIColor.clear, withThickness: 0)
            containerView.layer.borderWidth = 0
            containerView.layer.borderColor = UIColor.clear.cgColor
        case .underline:
            setupUnderline(color: borderLineColor, withThickness: borderLineThickness)
            containerView.layer.borderWidth = 0
            containerView.layer.borderColor = UIColor.clear.cgColor
        case .box:
            setupUnderline(color: UIColor.clear, withThickness: 0)
            containerView.layer.borderWidth = borderLineThickness
            containerView.layer.borderColor = borderLineColor.cgColor
        }
        
        //reset the resetFlag :P
        if isResetting && (indexPath.row == pinLength - 1) {
            isResetting = false
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - (interSpace * CGFloat(max(pinLength, 1) - 1)))/CGFloat(pinLength)
        return CGSize(width: width, height: width)
    }
        
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return interSpace
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let width = (collectionView.bounds.width - (interSpace * CGFloat(max(pinLength, 1) - 1)))/CGFloat(pinLength)
        let top = (collectionView.bounds.height - width) / 2
        return UIEdgeInsets(top: top, left: 0, bottom: 0, right: 0)
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
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == UIPasteboard.general.string {
            textField.resignFirstResponder()
            DispatchQueue.main.async {
                self.pastePin(pin: string)
            }
            return false
        }
        return true
    }
}
