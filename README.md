# SVPinView
SVPinView is a light-weight customisable library used for accepting pin numbers or one-time passwords.

[![Swift 5.1](https://img.shields.io/badge/Swift-5.1-orange.svg?style=flat)](https://developer.apple.com/swift/)
[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/SVPinView.svg)](https://developer.apple.com/swift/)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![Platforms iOS](https://img.shields.io/badge/Platforms-iOS-lightgray.svg?style=flat)](http://www.apple.com/ios/)
[![License MIT](https://img.shields.io/badge/License-MIT-lightgrey.svg?style=flat)](https://opensource.org/licenses/MIT)

![demo](SVPinView/Screenshots/SVPinView.gif)

## Getting Started

An [example project](https://github.com/xornorik/SVPinView/blob/master/SVPinView/Example) is included for demonstrating the functionality of SVPinView.


## Installation

### CocoaPods

Add the following line to your Podfile:

```ruby
pod 'SVPinView', '~> 1.0'
```

Then run the following in the same directory as your Podfile:
```ruby
pod install
```

### Carthage

```ruby
github xornorik/SVPinView
```

- Create a Cartfile file at the root of your project folder
- Add github `xornorik/SVPinView` to your Cartfile
- Run carthage update
- Drag and drop SVPinView.framework from /Carthage/Build/iOS/ to Linked frameworks and libraries in Xcode (Project>Target>General>Linked frameworks and libraries)
- Add new run script (Project>Target>Build Phases>+> New run script phase) /usr/local/bin/carthage copy-frameworks
- Add Input files $(SRCROOT)/Carthage/Build/iOS/SVPinView.framework

### Manual

Clone the repo and drag files from `SVPinView/Source` folder into your Xcode project.

## Usage

### Storyboard
![IBInspectables](SVPinView/Screenshots/IBInspectables.png)

### Code
```swift
pinView.pinLength = 5
pinView.secureCharacter = "\u{25CF}"
pinView.interSpace = 5
pinView.textColor = UIColor.black
pinView.shouldSecureText = true
pinView.style = .box

pinView.borderLineColor = UIColor.black
pinView.activeBorderLineColor = UIColor.lightGray
pinView.borderLineThickness = 1
pinView.activeBorderLineThickness = 3

pinView.font = UIFont.systemFont(ofSize: 15)
pinView.keyboardType = .phonePad
pinView.keyboardAppearance = .default
pinView.pinIinputAccessoryView = UIView()
pinView.placeholder = "******"
pinView.becomeFirstResponderAtIndex = 0
```
The `becomeFirstResponderAtIndex` property sets the pinField at the specified index as the first responder.
The `isContentTypeOneTimeCode` property sets the contentType of the first pinField to `.oneTimeCode` to leverage the iOS 12 feature where the passcode is directly fetched from the messages. 

#### Styles
```swift
enum SVPinViewStyle : Int {
    case none = 0
    case underline
    case box
}
```
There are two inbuilt styes; `underline` & `box`. However, the *fieldBackgroundColor* & *fieldCornerRadius* properties along with *activeFieldBackgroundColor* & *activeCornerRadius* properties can be used to create custom styles.
```swift
pinView.style = .none
pinView.fieldBackgroundColor = UIColor.white
pinView.fieldCornerRadius = 0
```

### Delete Button Actions

SVPinView offers three different behaviours for when the delete button is tapped. This can be set using the *deleteButtonAction* property on the pinView with the following values -  

- **.deleteCurrentAndMoveToPrevious**: 
This is the default option set with pinView. It deletes the contents of the current field and moves the cursor to the previous field. Once on the previous field, if an entry is made, it overwrites the existing value and moves to the next field.  
![deleteCurrentAndMoveToPrevious](SVPinView/Screenshots/deleteCurrentAndMoveToPrevious.gif)

- **.deleteCurrent**: 
This deletes the contents of the current field without moving the cursor. If there is no value in the field when the delete button is tapped, it moves the cursor to the previous field.
![deleteCurrent](SVPinView/Screenshots/deleteCurrent.gif)

- **.moveToPreviousAndDelete**:
This deletes the contents of the current field when it is focused. When the delete button is tapped, it moves the cursor to the previous field and deletes it's contents.
![movetopreviousAndDelete](SVPinView/Screenshots/movetopreviousAndDelete.gif)

### Methods

- **getPin**: Returns the entered pin as a String. If the method is called when the pin entry is incomplete, it returns an *empty* String for validation.
- **pastePin**: Takes a String as an argument and enters it into the pinView. Useful for showing default values or for pasting from clipboard. Long-press on the pin field will also allow pasting from the clipboard.
- **clearPin**: Clears the entered pin and also refreshes the view. Returns a completion handler for when the view is refreshed. 
- **refreshView**: Clears the entered pin and refreshes the view. Returns a completion handler for when the view is refreshed. 

### Callbacks

- **didFinishCallback**: Gets executed after the entire pin has been entered. This is useful when a network call has to be made or for navigating to a different ViewController after the pin has been entered.
- **didChangeCallback**: Gets executed when any of the pinFields have been changed. This gives additional control to the parent VC - Eg: if a submit button has to be enabled/disabled based on the pin validation. 
```swift
pinView.didFinishCallback = { [weak self] pin in
    print("The pin entered is \(pin)")
}
```
```swift
pinView.didChangeCallback = { [weak self] pin in
    submitButton.isEnabled = isValid(pin)
}
```

## Requirements

- iOS 9.0 +
- Xcode 8.0 +

## License

SVPinView is available under the MIT license. See LICENSE for details.
