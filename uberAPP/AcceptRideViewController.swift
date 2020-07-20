//
//  AcceptRideViewController.swift
//  uberAPP
//
//  Created by El nino Cholo on 2020/07/14.
//  Copyright © 2020 El nino Cholo. All rights reserved.
//

import UIKit
import Firebase
import MapKit

class AcceptRideViewController: UIViewController {

    
    @IBOutlet weak var acceptbutton: UIButton!
    var reuqestLoaction = CLLocationCoordinate2D()
    var DrivierLocation = CLLocationCoordinate2D()
    var reuqestEmail:String = ""
    
    
    @IBOutlet weak var activitymapView: MKMapView!
    
    var acceptRide:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

       let region = MKCoordinateRegion(center: reuqestLoaction, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
       activitymapView.setRegion(region, animated: false)
       adduseronmaps()
        
    }
    
    
    func adduseronmaps()
    {
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = reuqestLoaction
        annotation.title = "\(reuqestEmail)"
        activitymapView.addAnnotations([annotation])
    }
    
    @IBAction func acceptRide(_ sender: Any)
    {
        Database.database().reference().child("RiderRequest").queryOrdered(byChild: "email").queryEqual(toValue: reuqestEmail).observe(.childAdded) { (sanpshot) in
            
            self.acceptRide = true
            sanpshot.ref.updateChildValues(["driverlat" : self.DrivierLocation.latitude,"driverlon" : self.DrivierLocation.longitude])
            
            Database.database().reference().child("RiderRequest").removeAllObservers()
        }
        
        //Give directions
        let requestLocation = CLLocation(latitude: reuqestLoaction.latitude  , longitude: reuqestLoaction.longitude)
        CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarks, error) in
            if error != nil
            {
                print("There was an error ",error!.localizedDescription)
            }else
            {
                if let myPlaceMarks = placemarks
                {
                    if myPlaceMarks.count > 0
                    {
                        
                        let myMKplcaemark = MKPlacemark(placemark: myPlaceMarks[0])
                        let MyMap = MKMapItem(placemark: myMKplcaemark)
                        MyMap.name = self.reuqestEmail
                        let option = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                        MyMap.openInMaps(launchOptions: option)
                    }
                }
            }
        }
            
        acceptRide = false
    }
    
}
