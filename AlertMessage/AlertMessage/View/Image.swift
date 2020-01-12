//
//  Image.swift
//  AlertMessage
//
//  Created by ZIHAO WU on 10/29/19.
//  Copyright © 2019 ZIHAO WU. All rights reserved.
//

import UIKit

@IBDesignable
class RoundImage : UIImageView
{
    //MARK: - Init
    
//    programmatically created buttons
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
//    for Storyboard/.xib created buttons
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        sharedInit()
    }
    
//    called within the Storyboard editor itself for rendering @IBDesignable controls
    override func prepareForInterfaceBuilder() {
        sharedInit()
    }
    
    
    func sharedInit() {
        // all intialization functions go here
        refreshCorners()
    }
    
    //MARK: - Round Image

    func refreshCorners() {
        self.layer.borderWidth = 1
        self.layer.masksToBounds = false
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
    
}
