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
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    // MARK: - Variables
    
    var selectedIndexes = [IndexPath]()
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    

    fileprivate func addPhoto(_ imageData: Data) {
        let photo = Photo(context: DataController.sharedInstance().viewContext)
        
        photo.photo = imageData
        photo.pin = self.pin
        
        try? DataController.sharedInstance().viewContext.save()
    }
    
    fileprivate func downLoadPhotos() {
        
        disableNewCollectionButton(disable: true)
        
        FlickrClient.sharedInstance().findPhotosURLByLocation(latitude: pin.latitude, longitude: pin.longitude, radius: 0.1) { (urls, error) in
            guard error == nil else{
                print ("falkha ao baixar imagens")
                return
            }
            
            for url in urls!{
                if let imageData = try? Data(contentsOf: url){
                    self.addPhoto(imageData)
                }
            }
            performUIUpdatesOnMain {
                self.disableNewCollectionButton(disable: false)
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        configureFlow(toTransition: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFlow()
        
        collectionView.delegate = self
        
        self.hidesBottomBarWhenPushed = false
        
        mapView.delegate = self
        collectionView.dataSource = self
        addPin()
        setupFetchedResultsController()
        
        print("Pin injetado em PhotoViewControlle:")
        print(pin)
        
        if pinHasPhotoOnCoreData(pin: pin){
        }else{
            downLoadPhotos()
        }
    }
    
    private func disableNewCollectionButton(disable:Bool){
        newCollectionButton.isEnabled = !disable
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
    
    func configureFlow(toTransition : Bool = false){
        let space : CGFloat = 1.0
        let side : CGFloat
        
        if toTransition{
            side = (view.frame.size.height - (2 * space)) / 3.0
        }else{
            side = (view.frame.size.width - (2 * space)) / 3.0
        }

        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: side, height: side)
    }
    
    @IBAction func newCollectionAction(sender: UIBarButtonItem){
        //apagar anterior
        self.deletePhotos()
        self.downLoadPhotos()
    }
    
    func deletePhotos(){
        for photos in fetchedResultsController.fetchedObjects!{
            DataController.sharedInstance().viewContext.delete(photos)
        }
        try? DataController.sharedInstance().viewContext.save()
    }
}

extension PhotosViewController: MKMapViewDelegate{
    
    //MARK: MKMapViewDelegate
    
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
    
    //MARK: UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let aPhoto = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        
        cell.imageView.image = UIImage(data: aPhoto.photo!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[0].numberOfObjects ?? 0
        //return (fetchedResultsController.sections?[section].numberOfObjects)!
    }
}

extension PhotosViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let photoToDelete = fetchedResultsController.object(at: indexPath)
        DataController.sharedInstance().viewContext.delete(photoToDelete)
        try? DataController.sharedInstance().viewContext.save()
        
    }
}

extension PhotosViewController: NSFetchedResultsControllerDelegate{
    
    //MARK: NSFetchedResultsControllerDelegate
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //this code was found at "https://github.com/ton1n8o/Virtual-Tourist/blob/master/Virtual%20Tourist/ViewControllers/PhotoAlbumViewController%2BExtension.swift"
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        updatedIndexPaths = [IndexPath]()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //this code was found at "https://github.com/ton1n8o/Virtual-Tourist/blob/master/Virtual%20Tourist/ViewControllers/PhotoAlbumViewController%2BExtension.swift"
        collectionView.performBatchUpdates({() -> Void in
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            
            for indexPath in self.updatedIndexPaths {
                self.collectionView.reloadItems(at: [indexPath])
            }
            
        }, completion: nil)
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        //this code was found at "https://github.com/ton1n8o/Virtual-Tourist/blob/master/Virtual%20Tourist/ViewControllers/PhotoAlbumViewController%2BExtension.swift"
        switch (type) {
        case .insert:
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            deletedIndexPaths.append(indexPath!)
            break
        case .update:
            updatedIndexPaths.append(indexPath!)
            break
        case .move:
            print("Move an item. We don't expect to see this in this app.")
            break
        }
    }
}
