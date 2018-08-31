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

class MapViewController: UIViewController {
    
    // MARK: - Variables
    var fetchedResultsController : NSFetchedResultsController<Pin>!
    
    //MARK: - IBOutlets
    @IBOutlet weak var mapView : MKMapView!
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupFetchedResultsController()
        loadPinsFromCoreData()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        <#code#>
//    }
//    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(animated)
//        fetchedResultsController = nil
//    }
    
    //MARK: - UI setings
    private func configureUI(){
        setMapDelegate()
        setMapRegion()
        setLongPress()
    }
    
    private func setMapDelegate(){
        self.mapView.delegate = self
    }
    
    private func setMapRegion(){
        if let region = Preferences.sharedInstance().region{
            mapView.region = region
        }
    }
    
    private func setLongPress(){
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addPin(gestureRecognizer:)))
        mapView.addGestureRecognizer(longPress)
    }
    
    //MARK: - Setup FetchedResultsController
    func setupFetchedResultsController(){
        //Create a fetchRequest (like "SELECT * FROM PHOTO")
        let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.sharedInstance().viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        //set fetchedResultsController delegate
        fetchedResultsController.delegate = self
        
        do{
            try fetchedResultsController.performFetch()
        }catch{
            fatalError("Could not fetched note: \(error.localizedDescription)")
        }
        
    }
    
    //MARK: - Editing
    private func loadPinsFromCoreData() {
        if let annotations = fetchedResultsController.fetchedObjects{
            mapView.addAnnotations(annotations)
        }
    }
    
    @objc func addPin(gestureRecognizer:UIGestureRecognizer){
        // this check is necessary because the longPress triggers this method multiple times and multiple pins would be dropped
        if gestureRecognizer.state == .began{
            let touchPoint = gestureRecognizer.location(in: mapView)
            
            let pin = Pin(context: DataController.sharedInstance().viewContext)
            pin.latitude = mapView.convert(touchPoint, toCoordinateFrom: mapView).latitude
            pin.longitude = mapView.convert(touchPoint, toCoordinateFrom: mapView).longitude
            
            try? DataController.sharedInstance().viewContext.save()
        }
    }
}
//MARK: -
extension MapViewController: MKMapViewDelegate{
    
    // MARK: MKMapViewDelegate
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)
        
        let photosViewController = storyboard?.instantiateViewController(withIdentifier: Constants.StoryboardID.photosViewController) as! PhotosViewController
        
        photosViewController.pin = view.annotation as! Pin
        navigationController?.pushViewController(photosViewController, animated: true)
    }
    
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
//MARK: -
extension MapViewController: NSFetchedResultsControllerDelegate{
    
    //MARK: NSFetchedResultsControllerDelegate
    
    // informa o início das mudanças
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //prepara a tabela para iniciar as mudanças
        //tableView.beginUpdates()
    }
    // informa o fim das mudanças
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //finaliza as mudanças na tabela
        //tableView.endUpdates()
    }

    /* This method is called whenever the fetchedResultsController receives notification that a
     object has been added, deleted, or changed. */
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard let pin = anObject as? Pin else {
            preconditionFailure("All changes observed in the map view controller should be for Point instances")
        }
        
        // the 'type' parameter informs if it is insertion, deletion, update or change
        switch type {
        case .insert:
            mapView.addAnnotation(pin)
            break
        case .delete:
            mapView.removeAnnotation(pin)
            break
        case .update:
            mapView.removeAnnotation(pin)
            mapView.addAnnotation(pin)
            break
        case .move:
            // N.B. The fetched results controller was set up with a single sort descriptor that produced a consistent ordering for its fetched Point instances.
            fatalError("How did we move a Point? We have a stable sort.")
        }
    }
}
