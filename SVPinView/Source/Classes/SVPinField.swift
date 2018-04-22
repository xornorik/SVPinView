//
//  SVPinField.swift
//  SVPinView
//
//  Created by Srinivas Vemuri on 20/04/18.
//  Copyright © 2018 Xornorik. All rights reserved.
//

import UIKit

class SVPinField: UITextField {
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(UIResponderStandardEditActions.copy(_:)) ||
            action == #selector(UIResponderStandardEditActions.cut(_:)) ||
            action == #selector(UIResponderStandardEditActions.select(_:)) ||
            action == #selector(UIResponderStandardEditActions.selectAll(_:)) ||
            action == #selector(UIResponderStandardEditActions.delete(_:)) {
            
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
}
