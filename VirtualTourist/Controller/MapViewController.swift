//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Bruno W on 07/08/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//
import Foundation
import CoreData
import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView : MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        if let region = Preferences.sharedInstance().region{
            mapView.region = region
            print ("Region resoursed!")
            print (region)
        }

        
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        Preferences.sharedInstance().region = mapView.region
        Preferences.sharedInstance().save()
    }


    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */


    @IBAction func photosAction(_ sender: Any){
        let photosViewController = storyboard?.instantiateViewController(withIdentifier: Constants.StoryboardID.photosViewController)

        navigationController?.pushViewController(photosViewController!, animated: true)
    }

}
