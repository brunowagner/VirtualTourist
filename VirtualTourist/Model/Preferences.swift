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
    
    private var locationData : [String : Double]!

    func save(){
//        let pref = Preferences.sharedInstance()
//        let preferencesData = NSKeyedArchiver.archivedData(withRootObject: pref)
//        UserDefaults.standard.set(preferencesData, forKey: Constants.UserDefaultsKeys.regionPreference)

//        let regionData = NSKeyedArchiver.archivedData(withRootObject: region)
//        UserDefaults.standard.set(regionData, forKey: Constants.UserDefaultsKeys.regionPreference)
        
        guard (region != nil) else{
            print("region nil. Did not saved!")
            return
        }
        
        latitude = region.center.latitude
        longitude = region.center.longitude
        latDelta = region.span.latitudeDelta
        longDelta = region.span.longitudeDelta
        
        locationData = [
            "latidude" : latitude,
            "longitude" : longitude,
            "latidudeDelta" : latDelta,
            "longitudeDelta" : longDelta
        ]
        
        UserDefaults.standard.set(locationData, forKey: Constants.UserDefaultsKeys.regionPreference)
        print ("Preferences saved!")
    }
    
    fileprivate func setLocationData( locationDictyonary: [String : Double]) {
        latitude = locationDictyonary["latidude"]
        longitude = locationDictyonary["longitude"]
        latDelta = locationDictyonary["latidudeDelta"]
        longDelta = locationDictyonary["longitudeDelta"]
    }
    
    func fetch(){
//        if let loadedData = UserDefaults.standard.data(forKey: Constants.UserDefaultsKeys.regionPreference) {
//            if let loadedPreferences = NSKeyedUnarchiver.unarchiveObject(with: loadedData) as? Preferences{
//                self.region = loadedPreferences.region
//                print("Preferences fetched!")
//            }
//        }
//        if let loadedData = UserDefaults.standard.data(forKey: Constants.UserDefaultsKeys.regionPreference) {
//            if let loadedRegion = NSKeyedUnarchiver.unarchiveObject(with: loadedData) as? MKCoordinateRegion{
//                self.region = loadedRegion
//                print("Preferences fetched!")
//            }
//        }
        
        if let fetchedLocation = UserDefaults.standard.dictionary(forKey: Constants.UserDefaultsKeys.regionPreference) as? [String : Double]{
            self.locationData = fetchedLocation
        }
        
        guard self.locationData != nil  else {
            print ("Region nil. Did not fetched!")
            return
        }
        
        setLocationData(locationDictyonary: self.locationData)
        
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


