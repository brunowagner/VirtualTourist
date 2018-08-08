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

class MapViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
