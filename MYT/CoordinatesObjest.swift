//
//  CoordinatesObjest.swift
//  MYT
//
//  Created by Deniss Kaibagarovs on 7/26/15.
//  Copyright (c) 2015 AwesomeCompany. All rights reserved.
//

import CoreLocation

class CoordinatesObjest: NSObject {
    
    init (Latitude latitude: CLLocationDegrees?, Longitude longitude:CLLocationDegrees?) {
        _latitude = latitude!
        _longitude = longitude!
    }
    var _latitude:CLLocationDegrees = CLLocationDegrees()
    var _longitude:CLLocationDegrees = CLLocationDegrees()
}
