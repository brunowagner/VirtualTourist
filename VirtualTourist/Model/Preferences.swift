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

    var region : MKCoordinateRegion!
    
    func save(){
        UserDefaults.standard.set(self.region, forKey: Constants.UserDefaultsKeys.regionPreference)
    }
    
    func fetch(){
        self.region = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.regionPreference) as! MKCoordinateRegion
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> Preferences{
        
        struct Singleton{
            static var sharedInstance = Preferences()
        }
        return Singleton.sharedInstance
    
    }
}

