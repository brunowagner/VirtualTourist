//
//  Pin.swift
//  VirtualTourist
//
//  Created by Bruno W on 27/08/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation
import MapKit
extension Pin : MKAnnotation{
    public var coordinate: CLLocationCoordinate2D {
        // latitude and longitude are optional NSNumbers
        
        let latDegrees = CLLocationDegrees(latitude)
        let longDegrees = CLLocationDegrees(longitude)
        
        return CLLocationCoordinate2D(latitude: latDegrees, longitude: longDegrees)
    }
    
    class func keyPathsForValuesAffectingCoordinate() -> Set<String> {
        return Set<String>([ #keyPath(latitude), #keyPath(longitude) ])
    }
}
