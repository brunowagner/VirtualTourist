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
    
    //var pin : Pin!
    
    var fetchedResultsController : NSFetchedResultsController<Pin>!
    
    
    func setupFetchedResultsController(){
        //Create a fetchRequest (like "SELECT * FROM PHOTO")
        let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        //bloco que testa o fetchRequest
//        if let results = try? DataController.sharedInstance().viewContext.fetch(fetchRequest){
//            print ("\(results[0].longitude)")
//
//            for pin in results{
//                print( "Long: \(pin.longitude) \n Lat: \(pin.latitude)" )
//            }
//        }
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: DataController.sharedInstance().viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        //set fetchedResultsController delegate
        fetchedResultsController.delegate = self
        
        do{
            try fetchedResultsController.performFetch()
        }catch{
            fatalError("Could not fetched note: \(error.localizedDescription)")
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.mapView.delegate = self

        if let region = Preferences.sharedInstance().region{
            mapView.region = region
            print ("Region resoursed!")
        }
        
        //add longPress (permite executar uma funcao apos "clicar" e "segurar" um local no mapa)
        //let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addPin(gestureRecognizer:)))
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(addPin(gestureRecognizer:)))
        //longPress.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(longPress)
        
        setupFetchedResultsController()
        
        if let annotations = fetchedResultsController.fetchedObjects{
            mapView.addAnnotations(annotations)
            print("Quantidade de Pins ao carregar: \(annotations.count)")
            for pin in annotations{
                print(pin)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        fetchedResultsController = nil
    }
    
    //MARK: Editing
    @objc func addPin(gestureRecognizer:UIGestureRecognizer){
        //esta verificação é necessária pois o longPress aciona esta método multiplas vezes e multiplos pinos seriam "dropados"
        if gestureRecognizer.state == .began{
            let touchPoint = gestureRecognizer.location(in: mapView)

            let pin = Pin(context: DataController.sharedInstance().viewContext)
            pin.latitude = mapView.convert(touchPoint, toCoordinateFrom: mapView).latitude
            pin.longitude = mapView.convert(touchPoint, toCoordinateFrom: mapView).longitude
            
            try? DataController.sharedInstance().viewContext.save()
            
            print("Quantidade de Pins após salvar: \(String(describing: fetchedResultsController.fetchedObjects?.count))")
            for pin in fetchedResultsController.fetchedObjects!{
                print(pin)
            }
        }
        
        
        
    }
    
    // se fosse adicionar um pino com o endereço como título
    // esta função não está sendo usada!
//    @objc func addAnnotation(gestureRecognizer:UIGestureRecognizer){
//        if gestureRecognizer.state == UIGestureRecognizerState.began {
//            let touchPoint = gestureRecognizer.location(in: mapView)
//            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
//            let annotation = MKPointAnnotation()
//            annotation.coordinate = newCoordinates
//
//            CLGeocoder().reverseGeocodeLocation(CLLocation(latitude: newCoordinates.latitude, longitude: newCoordinates.longitude), completionHandler: {(placemarks, error) -> Void in
//                if error != nil {
//                    print("Reverse geocoder failed with error" + (error?.localizedDescription)!)
//                    return
//                }
//
//                if (placemarks?.count)! > 0 {
//                    let pm = placemarks![0] as CLPlacemark
//
//                    // not all places have thoroughfare & subThoroughfare so validate those values
//                    if pm.thoroughfare != nil && pm.subThoroughfare != nil {
//                        annotation.title = pm.thoroughfare! + ", " + (pm.subThoroughfare)!
//                        annotation.subtitle = pm.subLocality
//                        self.mapView.addAnnotation(annotation)
//                        print(pm)
//                    }
//                }
//                else {
//                    annotation.title = "Unknown Place"
//                    self.mapView.addAnnotation(annotation)
//                    print("Problem with the data received from geocoder")
//                }
//                //places.append(["name":annotation.title,"latitude":"\(newCoordinates.latitude)","longitude":"\(newCoordinates.longitude)"])
//            })
//        }
//    }
    



    


//    @IBAction func photosAction(_ sender: Any){
//        let photosViewController = storyboard?.instantiateViewController(withIdentifier: Constants.StoryboardID.photosViewController)
//
//        navigationController?.pushViewController(photosViewController!, animated: true)
//    }

    

    

    
    
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        mapView.deselectAnnotation(view.annotation, animated: true)

        let photosViewController = storyboard?.instantiateViewController(withIdentifier: Constants.StoryboardID.photosViewController) as! PhotosViewController
        
//       let indexPath = fetchedResultsController.indexPath(forObject: view.annotation as! Pin)
//        print (view.annotation as! Pin)
//        print ("IndexPath: \(String(describing: indexPath))")

        photosViewController.pin = view.annotation as! Pin
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
    
    /* Este método é chamado sempre que o fetchedResultsController recebe a notificação de que um
     objeto foi adicionado, excluído ou alterado. */
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        guard let pin = anObject as? Pin else {
            preconditionFailure("All changes observed in the map view controller should be for Point instances")
        }
        
        // o parâmetro 'type' informa se é inserção, deleção ou alteração
        switch type {
        case .insert:
            mapView.addAnnotation(pin)
            print ("Adicionado pin: \(pin)")
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
    
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//
//        let indexSet = IndexSet(integer: sectionIndex)
//
//        switch type {
//        case .insert:
//            tableView.insertSections(indexSet, with: .fade)
//            break
//        case .delete:
//            tableView.deleteSections(indexSet, with: .fade)
//            break
//        case .move, .update:
//            fatalError("Invalid change type in controller(_:didChange:atSectionIndex:for:). Only .insert ou .delete should be possible.")
//        }
//    }
}

