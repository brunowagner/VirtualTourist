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
        
        self.mapView.delegate = self
        
        if let region = Preferences.sharedInstance().region{
            mapView.region = region
            print ("Region resoursed!")
            print (region)
        }
        
        //add longPress (permite executar uma funcao apos "clicar" e "segurar" um local no mapa)
        //let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addPin(gestureRecognizer:)))
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addPin(gestureRecognizer:)))
        //longPress.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(longPress)

        
    }
    
    
    @objc func addPin(gestureRecognizer:UIGestureRecognizer){
        //esta verificação é necessária pois o longPress aciona esta método multiplas vezes e multiplos pinos seriam "dropados"
        if gestureRecognizer.state == .began{
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            mapView.addAnnotation(annotation)
        }
    }
    
    // se fosse adicionar um pino com o endereço como título
    // esta função não está sendo usada!
    @objc func addAnnotation(gestureRecognizer:UIGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation()
            annotation.coordinate = newCoordinates
            
            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
                if error != nil {
                    print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
                    return
                }
                
                if (placemarks?.count)! > 0 {
                    let pm = placemarks![0] as CLPlacemark
                    
                    // not all places have thoroughfare & subThoroughfare so validate those values
                    if pm.thoroughfare != nil && pm.subThoroughfare != nil {
                        annotation.title = pm.thoroughfare! + ", " + (pm.subThoroughfare)!
                        annotation.subtitle = pm.subLocality
                        self.mapView.addAnnotation(annotation)
                        print(pm)
                    }
                }
                else {
                    annotation.title = "Unknown Place"
                    self.mapView.addAnnotation(annotation)
                    print("Problem with the data received from geocoder")
                }
                //places.append(["name":annotation.title,"latitude":"\(newCoordinates.latitude)","longitude":"\(newCoordinates.longitude)"])
            })
        }
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

    

    

    
    
    
    // MARK: - MKMapViewDelegate
    
    // This delegate method is implemented to respond to taps. It go to PhotoViewController
    // to the URL specified in the annotationViews subtitle property.
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        print("pin tapped callout!")
        if control == view.rightCalloutAccessoryView {
            let photosViewController = storyboard?.instantiateViewController(withIdentifier: Constants.StoryboardID.photosViewController)
            navigationController?.pushViewController(photosViewController!, animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let photosViewController = storyboard?.instantiateViewController(withIdentifier: Constants.StoryboardID.photosViewController) as! PhotosViewController

        photosViewController.annotation = view.annotation
        navigationController?.pushViewController(photosViewController, animated: true)
        
        
    }
    
    // Here we create a view with a "right callout accessory view". You might choose to look into other
    // decoration alternatives. Notice the similarity between this method and the cellForRowAtIndexPath
    // method in TableViewDataSource.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"

        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = false
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    

    
    /*
     This delegate's functions is called when de region on MapView is changed
     */
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        Preferences.sharedInstance().region = mapView.region
        Preferences.sharedInstance().save()
    }
}
