# SVPinView
SVPinView is a light-weight customisable library used for accepting pin numbers or one-time passwords.

<p align="left">
	<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/Swift_4-compatible-4BC51D.svg?style=flat" alt="Swift 4 compatible" /></a>
	<a href="https://cocoapods.org/pods/ScrollableDatepicker"><img src="https://img.shields.io/badge/pod-2.1.0-blue.svg" alt="CocoaPods compatible" /></a>
	<img src="https://img.shields.io/badge/platform-iOS-blue.svg?style=flat" alt="Platform iOS" />
	<a href="https://raw.githubusercontent.com/maxsokolov/tablekit/master/LICENSE"><img src="http://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="License: MIT" /></a>
</p>

![demo](SVPinView/Screenshots/SVPinView.gif)

## Getting Started

An [example ViewController](https://github.com/xornorik/SVPinView/blob/master/SVPinView/Example/PinViewController.swift) is included for demonstrating the functionality of SVPinView.


## Installation

### CocoaPods

Add the following line to your Podfile:

```ruby
pod 'SVPinView'
```

Then run the following in the same directory as your Podfile:
```ruby
pod install
```

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
  pinView.underlineColor = UIColor.black
  pinView.underLineThickness = 2
  pinView.shouldSecureText = true
        
  pinView.font = UIFont.systemFont(ofSize: 15)
  pinView.keyboardType = .phonePad
  pinView.pinIinputAccessoryView = UIView()

```

### Callbacks

SVPinView has a 'didFinish' callback, which gets executed after the pin has been entered. This is useful when a network call has to be made or for navigating to a different ViewController after the pin has been entered.  

```swift
pinView.didFinishCallback = { pin in
   print("The pin entered is \(pin)")
}
```

## Requirements

- iOS 9.0
- Xcode 8.0


## License

SVPinView is available under the MIT license. See LICENSE for details.
