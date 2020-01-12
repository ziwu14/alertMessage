//
//  CustomAnnotation.swift
//  AlertMessage
//
//  Created by ZIHAO WU on 11/20/19.
//  Copyright © 2019 ZIHAO WU. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    
    init(title: String, subtitle: String, coord: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coord
    }
}
