//
//  Constants.swift
//  AlertMessage
//
//  Created by ZIHAO WU on 11/11/19.
//  Copyright © 2019 ZIHAO WU. All rights reserved.
//

struct K {
    static let appName = "Alert Message"
    //VC name in storyboard
    //segue name in storyboard
    static let signoutSegueIdentifier = "fromProfileToLogin"
    
    //Color set
//    struct BrandColors {
//        static let purple = "BrandPurple"
//        static let lightPurple = "BrandLightPurple"
//        static let blue = "BrandBlue"
//        static let lighBlue = "BrandLightBlue"
//    }
    
    //Firestore database keywords
    struct FStore {
        static let collectionName = "users"
        static let lonField = "lon"
        static let latField = "lat"
        static let phoneField = "phone"
        //static let usernameField = "username"
        static let emailField = "email"
        static let statusField = "status"
    }
}

