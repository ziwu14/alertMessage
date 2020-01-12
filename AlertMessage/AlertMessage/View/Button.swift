//
//  UIRoundButton.swift
//  AlertMessage
//
//  Created by ZIHAO WU on 10/29/19.
//  Copyright © 2019 ZIHAO WU. All rights reserved.
//



// @IBDesignable is a special attribute that allows the Storyboard file to see our custom UI element and it will actually compile the code for the Storyboard.
// Buttons can be created either programmatically or via the drag and drop Storyboard/.xib interface files



import UIKit

@IBDesignable
class myButton: UIButton {
    
    //MARK: - Init
//    programmatically created buttons
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
//    for Storyboard/.xib created buttons
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    
//    called within the Storyboard editor itself for rendering @IBDesignable controls
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    func sharedInit() {
        // all intialization functions go here
        refreshCorners(value: cornerRadius) //use default value
        refreshRound(value: isRound)
    }
    
    
    //MARK: - Corner radius
    
//    @IBInspectable variables are exposed to the Storyboard UI, which allows you to change these properties via the "Attributes Inspector" when editing a RoundButton.
//    didSet{} to update the visuals anytime the cornerRadius is changed in code or via the Storyboard file.
    @IBInspectable var cornerRadius: CGFloat = 15 { //default value = 15
        didSet {
            refreshCorners(value: cornerRadius)
        }
    }
//    The CALayer properties have an attribute that you can change to create a cornerRadius on any UIView.
//    Add a helper method named refreshCorners() to update the corner radius:
    func refreshCorners(value: CGFloat) {
        layer.cornerRadius = value
    }
    
    //MARK: - is Round
    @IBInspectable var isRound: Bool = false { //default value = 15
        didSet {
            refreshRound(value: isRound)
        }
    }
    
    func refreshRound(value: Bool) {
        if value == true {
            self.layer.cornerRadius = self.frame.width / 2
            self.clipsToBounds = true
        }
        
    }
    
    //TODO: - others
}
