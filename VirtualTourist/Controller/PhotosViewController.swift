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
    
    // MARK: Variables
    var selectedIndexes = [IndexPath]()
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    var updatedIndexPaths: [IndexPath]!
    var pin : Pin!
    var fetchedResultsController : NSFetchedResultsController<Photo>!
    
    //MARK: IBOutlets
    @IBOutlet weak var mapView : MKMapView!
    @IBOutlet weak var collectionView : UICollectionView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
 
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.haveNoPhotoInfo(display: false)
		self.configureFlow()
        self.setDelegatesAndDataSource()
        self.addPinOnTheMap()
        self.setupFetchedResultsController()
        self.populateCollection()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        configureFlow(toTransition: true)
    }
	
	//MARK: IBAction
    @IBAction func newCollectionAction(sender: UIBarButtonItem){
        self.deletePhotos()
        self.populateCollection()
    }
    
	//MARK: Editing
	private func addPhoto(imageData: Data) {
        let photo = Photo(context: DataController.sharedInstance().viewContext)
        
        photo.photo = imageData
        photo.pin = self.pin
        
        try? DataController.sharedInstance().viewContext.save()
    }

    private func deletePhotos(){
        for photos in fetchedResultsController.fetchedObjects!{
            DataController.sharedInstance().viewContext.delete(photos)
        }
        try? DataController.sharedInstance().viewContext.save()
    }
    
    //MARK: Setup FetchedResultsController
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
        
	//MARK: ConfigureUI
	private func setDelegatesAndDataSource(){
		collectionView.delegate = self
		collectionView.dataSource = self
		mapView.delegate = self
	}

	private func enableNewCollectionButton(anable:Bool){
        performUIUpdatesOnMain {
            self.newCollectionButton.isEnabled = anable
		}
    }
    
    private func haveNoPhotoInfo(display: Bool){
        performUIUpdatesOnMain {
            self.infoLabel.isHidden = !display
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
    	
	//MARK: Populate
	fileprivate func addPinOnTheMap() {
        let annotation = MKPointAnnotation()
        annotation.coordinate.latitude = pin.latitude
        annotation.coordinate.longitude = pin.longitude

        mapView.addAnnotation(annotation)
        let span = MKCoordinateSpanMake(0.001, 0.001)
        let region = MKCoordinateRegionMake(annotation.coordinate, span)
        mapView.region = region
    }
    
	private func populateCollection(){
		guard !pinHasPhotoOnCoreData(pin: pin) else{
			return
		}
		
		self.enableNewCollectionButton(anable: false)
		
		downloadPhotos{(success) in
            if !success{
                self.haveNoPhotoInfo(display: true)
            }
			self.enableNewCollectionButton(anable: true)
		}
	}
	
	//MARK: Auxiliary functions
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
    
	fileprivate func downloadPhotos(completion: @escaping (_ success: Bool)->Void) {
        
        FlickrClient.sharedInstance().findPhotosURLByLocation(latitude: pin.latitude, longitude: pin.longitude, radius: 0.1) { (urls, error) in
            guard error == nil else{
				//TODO: Codificar alerta de erro!
                completion(false)
                print ("Error: Could not download photo(s)")
                return
            }
			
			//TODO: Testar cenário onde não existe fotos para download
			
            for url in urls!{
                if let imageData = try? Data(contentsOf: url){
                    self.addPhoto(imageData: imageData)
                }
            }
			completion(true)
        }
    }
}

extension PhotosViewController: MKMapViewDelegate{
    
    //MARK: MKMapViewDelegate
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
