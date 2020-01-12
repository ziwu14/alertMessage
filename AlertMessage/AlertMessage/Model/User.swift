//
//  User.swift
//  AlertMessage
//
//  Created by ZIHAO WU on 11/10/19.
//  Copyright © 2019 ZIHAO WU. All rights reserved.
//

import Foundation
import UIKit

/*
    User is a singleton variable, since lat, lon, status might
    be update in background thread
 */
struct User {
    
    enum Status: String {
        case normal = "normal"
        case risky = "risky"
        case emergent = "emergent"
        case offline = "offline"
        
        func description()-> String {
            return self.rawValue
        }
    }
    
    
    
    static var username: String?
    static var email: String?
    static var phone: String?
    static var lat: Double?
    static var lon: Double?
    static var status: Status = .normal
    static var imageURL: URL?
    static var image: UIImage?
    static var friendEmailArray: [String] = []
    
    static func clear() {
        username = nil
        email = nil
        phone = nil
        lat = nil
        lon = nil
        status = .offline
        imageURL = nil
        image = nil
        friendEmailArray = []
    }
    
}

struct UserAnnotationInfo {
    var status: String
    var lon: Double
    var lat: Double
    var email: String
}


struct Friend {
    var name: String?
    var status: String?
    var email: String?
    var image: UIImage?
}
