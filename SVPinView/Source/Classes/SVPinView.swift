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
    @IBInspectable public var emptyBorderLineColor:UIColor = UIColor.black
    @IBInspectable public var activeBorderLineColor:UIColor = UIColor.black
    @IBInspectable public var shouldDismissKeyboardOnEmptyFirstField:Bool = true
    @IBInspectable public var shouldSecureText:Bool = true
    @IBInspectable public var allowsWhitespace:Bool = true
    @IBInspectable public var fieldBackgroundColor:UIColor = UIColor.clear
    @IBInspectable public var fieldCornerRadius:CGFloat = 0
    @IBInspectable public var placeholder:String = ""

    public var style:SVPinViewStyle = .underline
    
    public var font:UIFont = UIFont.systemFont(ofSize: 15){
        didSet {
            let cells = self.collectionView?.visibleCells ?? []
            for (idx, cell) in cells.enumerated() {
                (cell.viewWithTag(101+idx) as? SVPinField)?.font = self.font
            }
        }
    }
    public var keyboardType:UIKeyboardType = UIKeyboardType.phonePad {
        didSet {
            let cells = self.collectionView?.visibleCells ?? []
            for (idx, cell) in cells.enumerated() {
                (cell.viewWithTag(101+idx) as? SVPinField)?.keyboardType = self.keyboardType
            }
        }
    }
    public var pinIinputAccessoryView:UIView? {
        didSet {
            let cells = self.collectionView?.visibleCells ?? []
            for (idx, cell) in cells.enumerated() {
                (cell.viewWithTag(101+idx) as? SVPinField)?.inputAccessoryView = self.pinIinputAccessoryView
            }
        }
    }
    public var becomeFirstResponderAtIndex:Int? {
        didSet {
            if let firstResponseIndex = self.becomeFirstResponderAtIndex {
                self.getTextField(forIndex: firstResponseIndex)?.becomeFirstResponder()
            }
        }
    }
    

    
    fileprivate var password = [String]()
    public var didFinishCallback: ((String)->())?
    public var didChangeCallback: ((String)->())?
    
    fileprivate var view:UIView!
    fileprivate var reuseIdentifier = "SVPinCell"
    fileprivate var isLoading = true

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadView()
    }
    
    private func loadView() {
        let podBundle = Bundle(for: SVPinView.self)
        let nib = UINib(nibName: "SVPinView", bundle: podBundle)
        view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        // for CollectionView
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
        let placeholderLabel = textField.superview?.viewWithTag(400) as! UILabel

        // ensure single character in text box and trim spaces
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
        
        // check if entered text is backspace
        if isBackSpace() {
            nextTag = textField.tag - 1
        } else {
            nextTag = textField.tag + 1
        }
        
        if !self.allowsWhitespace && !isBackSpace() && textField.text!.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 {
            return
        }
        
        // Try to find next responder
        let nextResponder = textField.superview?.superview?.superview?.superview?.viewWithTag(nextTag) as UIResponder?
        if (nextResponder != nil) {
            // Found next responder, so set it.
            nextResponder?.becomeFirstResponder()
        } else {
            // Not found, so dismiss keyboard
            if !isBackSpace() && self.shouldDismissKeyboardOnEmptyFirstField {
                textField.resignFirstResponder()
            }
            
        }
        
        // activate the placeholder if textField empty
        placeholderLabel.isHidden = !textField.text!.isEmpty
        
        // secure text after a bit
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
            if textField.text == "" {
                textField.text = " "
                placeholderLabel.isHidden = false
            } else {
                placeholderLabel.isHidden = true
                if self.shouldSecureText {textField.text = self.secureCharacter} else {}
            }
        })

        // store text
        let text =  textField.text ?? ""
        if self.activeBorderLineColor == self.borderLineColor {
            textField.superview?.viewWithTag(50)?.backgroundColor = text.count > 0 ? self.borderLineColor : self.emptyBorderLineColor
            if style == .box {
                textField.superview?.layer.borderColor = (text.count > 0 ? self.borderLineColor : self.emptyBorderLineColor).cgColor
            }
        }
        let passwordIndex = index - 1
        if password.count > (passwordIndex) {
            // delete if space
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
        self.didChangeCallback?(pin)
        guard !pin.isEmpty else {return}
        if didFinishCallback != nil {
            didFinishCallback!(pin)
        }
    }
    
    fileprivate func setPlaceholder() {
        for (index,char) in placeholder.enumerated() {
            guard index < pinLength else {return}
            
            let placeholderLabel = collectionView.cellForItem(at: IndexPath(item: index, section: 0))?.viewWithTag(400) as! UILabel
            placeholderLabel.text = String(char)
        }
    }
    
    fileprivate func getTextField(forIndex index:Int) -> SVPinField? {
        if index >= self.collectionView.numberOfItems(inSection: 0) {
            return nil
        }
        
        return self.collectionView.cellForItem(at: IndexPath(item: index, section: 0))?.viewWithTag(101+index) as? SVPinField
    }
    
    // MARK: Public methods
    @objc
    public func setBorderColor(color:UIColor?=nil) {
        let cells = self.collectionView?.visibleCells ?? []
        for (idx, cell) in cells.enumerated() {
            if let textField = cell.viewWithTag(101+idx) as? SVPinField {
                var color = color ?? (textField.text!.trimmingCharacters(in: .whitespacesAndNewlines).count == 0 ? self.emptyBorderLineColor : self.borderLineColor)
                if textField.isFirstResponder && self.activeBorderLineColor != self.borderLineColor {
                    color = self.activeBorderLineColor
                }
                textField.superview?.viewWithTag(50)?.backgroundColor = color
                if style == .box {
                    textField.superview?.layer.borderColor = color.cgColor
                }
            }
        }
    }
    
    
    @objc
    public func getPin() -> String {
        
        guard !isLoading else {return ""}
        
        guard password.count == pinLength && password.joined().trimmingCharacters(in: CharacterSet(charactersIn: " ")).count == pinLength else {
            print("")
            return ""
        }
        return password.joined()
    }
    
    @objc
    public func clearPin() {
        
        guard !isLoading else {return}
        
        password.removeAll()
        let cells = self.collectionView?.visibleCells ?? []
        for (idx, cell) in cells.enumerated() {
            (cell.viewWithTag(101+idx) as? SVPinField)?.text = ""
        }
    }
    
    @objc
    public func pastePin(pin:String) {
        
        password = []
        for (index,char) in pin.enumerated() {
            
            guard index < pinLength else {return}
            
            //Get the first textField
            let textField = collectionView.cellForItem(at: IndexPath(item: index, section: 0))?.viewWithTag(101 + index) as! SVPinField
            let placeholderLabel = collectionView.cellForItem(at: IndexPath(item: index, section: 0))?.viewWithTag(400) as! UILabel

            textField.text = String(char)
            placeholderLabel.isHidden = true
            
            //secure text after a bit
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500), execute: {
                if textField.text == "" {
                    textField.text = " "
                    placeholderLabel.isHidden = false
                } else {
                    if self.shouldSecureText {textField.text = self.secureCharacter} else {}
                }
            })
            
            // store text
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
        
        let textField = cell.viewWithTag(100) as! SVPinField
        let containerView = cell.viewWithTag(51)!
        let underLine = cell.viewWithTag(50)!
        let placeholderLabel = cell.viewWithTag(400) as! UILabel

        // Setting up textField
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
        
        placeholderLabel.text = ""
        placeholderLabel.textColor = self.textColor.withAlphaComponent(0.5)
        
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
            setupUnderline(color: emptyBorderLineColor, withThickness: borderLineThickness)
            containerView.layer.borderWidth = 0
            containerView.layer.borderColor = UIColor.clear.cgColor
        case .box:
            setupUnderline(color: UIColor.clear, withThickness: 0)
            containerView.layer.borderWidth = borderLineThickness
            containerView.layer.borderColor = emptyBorderLineColor.cgColor
        }
        
        // Make the Pin field the first responder
        if let firstResponderIndex = becomeFirstResponderAtIndex, firstResponderIndex == indexPath.item {
            textField.becomeFirstResponder()
        }
        
        // Finished loading pinView
        if indexPath.row == pinLength - 1 && isLoading {
            isLoading = false
            DispatchQueue.main.async {
                if !self.placeholder.isEmpty {self.setPlaceholder()}
            }
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            let width = (collectionView.bounds.width - (interSpace * CGFloat(max(pinLength, 1) - 1)))/CGFloat(pinLength)
            return CGSize(width: width, height: collectionView.frame.height)
        }
        let width = (collectionView.bounds.width - (interSpace * CGFloat(max(pinLength, 1) - 1)))/CGFloat(pinLength)
        let height = collectionView.frame.height
        return CGSize(width: min(width, height), height: min(width, height))
    }
        
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return interSpace
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
        let width = (collectionView.bounds.width - (interSpace * CGFloat(max(pinLength, 1) - 1)))/CGFloat(pinLength)
        let height = collectionView.frame.height
        let top = (collectionView.bounds.height - min(width, height)) / 2
        if height < width {
            // If width of field > height, size the fields to the pinView height and center them.
            let totalCellWidth = height * CGFloat(pinLength)
            let totalSpacingWidth = interSpace * CGFloat(max(pinLength, 1) - 1)
            let inset = (collectionView.frame.size.width - CGFloat(totalCellWidth + CGFloat(totalSpacingWidth))) / 2
            return UIEdgeInsets(top: top, left: inset, bottom: 0, right: inset)
        }
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
        let placeholderLabel = textField.superview?.viewWithTag(400) as! UILabel
        placeholderLabel.isHidden = true

        if text.count == 0 {
            textField.isSecureTextEntry = false
            textField.text =  " "
            placeholderLabel.isHidden = false
        }
        self.setBorderColor()
    }
    public func textFieldDidEndEditing(_ textField: UITextField) {
        let text = textField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        textField.superview?.viewWithTag(50)?.backgroundColor = text.count == 0 ? self.emptyBorderLineColor : self.borderLineColor
        if style == .box {
            textField.superview?.layer.borderColor = (text.count == 0 ? self.emptyBorderLineColor : self.borderLineColor).cgColor
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
