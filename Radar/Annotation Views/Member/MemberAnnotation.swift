//
//  MemberAnnotation.swift
//  Miss Chief
//
//  Created by Kevin Ng on 2/2/17.
//  Copyright © 2017 Miss-Chief. All rights reserved.
//

import Foundation
import MapKit

class MemberAnnotation: NSObject, MKAnnotation {
    
    var radar: MKMapView
    
    dynamic var coordinate: CLLocationCoordinate2D
    
    var memberId: String
    
    init(coordinate: CLLocationCoordinate2D,
         memberId: String,
         radar: MKMapView) {
        self.radar = radar
        self.memberId = memberId
        self.coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
        super.init()
        
        self.coordinate = coordinate
    }
}
