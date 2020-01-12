//
//  User.swift
//  AlertMessage
//
//  Created by ZIHAO WU on 11/10/19.
//  Copyright © 2019 ZIHAO WU. All rights reserved.
//

import Foundation


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
    
}

/*
    Config is a singleton variable, since upTimeInterval and geoFence might
    be used in background thread
*/
struct Config {
    
    enum RiskLevel {
        case one
        case two
        case three
    }
    
    //TODO: - change updateTimeInterval and geoFence later
    static var riskLevel: RiskLevel = .one
    static var updateTimeInterval: Double {
        get {
            switch riskLevel {
            case .one:
                return 20
            case .two:
                return 5
            case .three:
                return 1
//            default:
//                return 10
            }
        }
    }
    static var geoFence: Double {
        get {
            switch riskLevel {
            case .one:
                return 10
            case .two:
                return 20
            case .three:
                return 30
//            default:
//                return 10
            }
        }
    }
    
}
