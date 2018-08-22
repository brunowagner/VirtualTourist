//
//  Preferences.swift
//  VirtualTourist
//
//  Created by Bruno W on 20/08/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import Foundation
import MapKit
class Preferences{
    
    //MARK: Properties
    var region : MKCoordinateRegion!
    
    private var latitude : Double!
    private var longitude: Double!
    private var latDelta : Double!
    private var longDelta : Double!
    
    private var splittedRegionsDataDictionary : [String : Double]!

    func save(){
        guard (region != nil) else{
            print("region nil. Did not saved!")
            return
        }
        latitude = region.center.latitude
        longitude = region.center.longitude
        latDelta = region.span.latitudeDelta
        longDelta = region.span.longitudeDelta
        
        splittedRegionsDataDictionary = [
            "latidude" : latitude,
            "longitude" : longitude,
            "latidudeDelta" : latDelta,
            "longitudeDelta" : longDelta
        ]
        
        UserDefaults.standard.set(splittedRegionsDataDictionary, forKey: Constants.UserDefaultsKeys.regionPreference)
        print ("Preferences saved!")
    }
    
    fileprivate func setCoordinates() {
        latitude = splittedRegionsDataDictionary["latidude"]
        longitude = splittedRegionsDataDictionary["longitude"]
        latDelta = splittedRegionsDataDictionary["latidudeDelta"]
        longDelta = splittedRegionsDataDictionary["longitudeDelta"]
    }
    
    func fetch(){
        
        if let fetchedLocation = UserDefaults.standard.dictionary(forKey: Constants.UserDefaultsKeys.regionPreference) as? [String : Double]{
            self.splittedRegionsDataDictionary = fetchedLocation
        }
        
        guard self.splittedRegionsDataDictionary != nil  else {
            print ("Region nil. Did not fetched!")
            return
        }
        
        setCoordinates()
        
        let coordinates = CLLocationCoordinate2DMake(latitude , longitude )
        let span = MKCoordinateSpanMake(latDelta , longDelta )
        
        self.region = MKCoordinateRegionMake(coordinates, span)
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> Preferences{
        
        struct Singleton{
            static var sharedInstance = Preferences()
        }
        return Singleton.sharedInstance
    
    }
}


