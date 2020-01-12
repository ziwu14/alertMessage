//
//  Config.swift
//  AlertMessage
//
//  Created by ZIHAO WU on 11/18/19.
//  Copyright © 2019 ZIHAO WU. All rights reserved.
//

import Foundation

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
                return 10
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
                return 0.01
            case .two:
                return 0.02
            case .three:
                return 0.03
//            default:
//                return 10
            }
        }
    }
    
}
