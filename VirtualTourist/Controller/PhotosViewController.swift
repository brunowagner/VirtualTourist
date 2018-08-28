//
//  PhotosViewController.swift
//  VirtualTourist
//
//  Created by Bruno W on 07/08/2018.
//  Copyright © 2018 Bruno_W. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotosViewController: UIViewController {
    
    //var annotation : MKAnnotation!
    
    var pin : Pin!
    
    var fetchedResultsController : NSFetchedResultsController<Photo>!
    
    @IBOutlet weak var mapView : MKMapView!
    @IBOutlet weak var collectionView : UICollectionView!

    fileprivate func addPhoto(_ imageData: Data) {
        let photo = Photo(context: DataController.sharedInstance().viewContext)
        
        photo.photo = imageData
        photo.pin = self.pin
        
        try? DataController.sharedInstance().viewContext.save()
    }
    
    fileprivate func downLoadPhotos() {
        FlickrClient.sharedInstance().findPhotosURLByLocation(latitude: pin.latitude, longitude: pin.longitude, radius: 1) { (urls, error) in
            guard error == nil else{
                print ("falkha ao baixar imagens")
                return
            }
            
            for url in urls!{
                if let imageData = try? Data(contentsOf: url){
                    self.addPhoto(imageData)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        addPin()
        setupFetchedResultsController()
        
        print("Pin injetado em PhotoViewControlle:")
        print(pin)
        
        if pinHasPhotoOnCoreData(pin: pin){
            
        }else{
            downLoadPhotos()
        }
    }
    
    private func pinHasPhotoOnCoreData(pin : Pin) -> Bool{
        guard let itens = pin.photos else {
            print("Pin.Photos Inválido!")
            return false
        }
        
        if itens.count > 0 {
            return true
        }else{
            return false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func addPin() {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = pin.latitude
        annotation.coordinate.longitude = pin.longitude

        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.001, 0.001)
        let region = MKCoordinateRegionMake(annotation.coordinate, span)
        mapView.region = region
    }
    
    func setupFetchedResultsController(){
        //Create a fetchRequest (like "SELECT * FROM PHOTO")
        let fetchRequest : NSFetchRequest<Photo> = Photo.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        //Create a predicate (like: "WHERE ... ")
        let predicate = NSPredicate(format: "pin == %@", pin)
        
        //Add predicate at fetchRequest
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController<Photo>(fetchRequest: fetchRequest, managedObjectContext: DataController.sharedInstance().viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do{
            try fetchedResultsController.performFetch()
        }catch{
            fatalError("Could not fetched note: \(error.localizedDescription)")
        }
        
    }

}
extension PhotosViewController: MKMapViewDelegate{
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
}

extension PhotosViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let aPhoto = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        cell.imageView.image = UIImage(data: aPhoto.photo!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return (fetchedResultsController.sections?[section].numberOfObjects)!
    }
}

extension PhotosViewController: NSFetchedResultsControllerDelegate{
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        <#code#>
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
            break
        case .update:
            //TODO: Codeficar o tipo update
            break
        case .move: break
        //TODO: codificar o tipo move
        }
    }
}
