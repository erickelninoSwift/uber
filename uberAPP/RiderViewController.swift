//
//  RiderViewController.swift
//  uberAPP
//
//  Created by El nino Cholo on 2020/07/14.
//  Copyright © 2020 El nino Cholo. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import CoreLocation


class RiderViewController: UIViewController,CLLocationManagerDelegate {

    
    @IBOutlet weak var mapviewDisplay: MKMapView!
    
    var locationManager = CLLocationManager()
    var userlocation = CLLocationCoordinate2D()
    var uberhavebeenCalled:Bool = false
    @IBOutlet weak var reuestuberDrive: UIButton!
    var driverOntheway:Bool = false
    
    var driverLocation = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        session()
        
        
        // Do any additional setup after loading the view.
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0
        {
    
            if driverOntheway
            {
               displayDriverAndDriver()
                
            }else
            {

                   let coordinates = location.coordinate
                     userlocation = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude:coordinates.longitude)
                
                    let region = MKCoordinateRegion(center: userlocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                    mapviewDisplay.setRegion(region, animated: true)
                
                    
                    mapviewDisplay.removeAnnotations(mapviewDisplay.annotations)
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = userlocation
                    annotation.title = "Your location"
                    mapviewDisplay.addAnnotation(annotation)
                
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        alertMessage(title: "Error Location", message: "There was an error while trying to get your location coordinate")
    }
    
    func stopUpdatinglocation()
    {
        locationManager.stopUpdatingLocation()
    }
    
    func session()
    {
        
        if let myemail = Auth.auth().currentUser?.email
        {
            let database = Database.database().reference().child("RiderRequest")
            database.queryOrdered(byChild: "email").queryEqual(toValue: myemail).observe(.childAdded) { (snapshot) in
                
                if let data = snapshot.value as? Dictionary<String,Any>
                {
                    if !data.isEmpty
                    {
                        self.uberhavebeenCalled = true
                        self.reuestuberDrive.setTitle("Cancel Uber", for: UIControl.State.normal)
                        database.removeAllObservers()
                        
                        if let riderDctionary = snapshot.value as? [String:Any]
                        {
                            if let driverlat = riderDctionary["driverlat"] as? Double
                            {
                                if let driverlon = riderDctionary["driverlon"] as? Double
                                {
                                    self.driverLocation = CLLocationCoordinate2D(latitude: driverlat, longitude: driverlon)
                                    self.driverOntheway = true
                                    self.displayDriverAndDriver()
                                    self.UpdateDriverLocationtouser()
                                }
                                
                            }
                        }
                    }
                    
                }
            }
        
        }
        
    }
    
    //Driver Cuurent Location real time Update
    func UpdateDriverLocationtouser()
    {
        if let myemail = Auth.auth().currentUser?.email
                       {
                           let database = Database.database().reference().child("RiderRequest")
                           database.queryOrdered(byChild: "email").queryEqual(toValue: myemail).observe(.childChanged) { (snapshot) in
                               
                               if let riderDctionary = snapshot.value as? [String:Any]
                               {
                                   if let driverlat = riderDctionary["driverlat"] as? Double
                                   {
                                       if let driverlon = riderDctionary["driverlon"] as? Double
                                       {
                                           self.driverLocation = CLLocationCoordinate2D(latitude: driverlat, longitude: driverlon)
                                           self.driverOntheway = true
                                           self.displayDriverAndDriver()
                                       }
                                       
                                   }
                               }
                           }
                           
            }
    }
    //Show the user the KM of the Uber and how long it willl take him to arrive
    
    func displayDriverAndDriver()
    {
        if driverOntheway
        {
            let driverCLLocagtion = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
            let riderCLLocation = CLLocation(latitude: userlocation.latitude, longitude: userlocation.longitude)
            
            let differcentKM = driverCLLocagtion.distance(from: riderCLLocation) / 1000
            let roundedvalue = round(differcentKM * 100) / 100
            reuestuberDrive.setTitle("Driver is \(roundedvalue)Km away!", for: UIControl.State.normal)
            mapviewDisplay.removeAnnotations(mapviewDisplay.annotations)
            let latDelta = abs(driverLocation.latitude - userlocation.latitude) * 2 + 0.005
            let LonDelta = abs(driverLocation.longitude - userlocation.longitude) * 2 + 0.005
            
            
            let region = MKCoordinateRegion(center: userlocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: LonDelta))
            
            mapviewDisplay.setRegion(region, animated: true)
            
            let riderAnnotation = MKPointAnnotation()
            riderAnnotation.coordinate = userlocation
            riderAnnotation.title = "your location"
            mapviewDisplay.addAnnotation(riderAnnotation)
            
            let driverAnnotation = MKPointAnnotation()
            driverAnnotation.coordinate = driverLocation
            driverAnnotation.title = "Driver"
            mapviewDisplay.addAnnotation(driverAnnotation)
        
        }
        
    }
    
    @IBAction func requestanUber(_ sender: Any)
    {
        if !driverOntheway
        {
            if let myemail = Auth.auth().currentUser?.email
                   {
                       let database = Database.database().reference().child("RiderRequest")
                       let dictionary = ["email": myemail , "lat": userlocation.latitude , "lon": userlocation.longitude] as [String: Any]
                       
                       if uberhavebeenCalled == false
                       {
                           database.childByAutoId().setValue(dictionary) { (error, reference) in
                               if error != nil
                               {
                                   self.alertMessage(title: "Error ", message: error!.localizedDescription)
                               }else
                               {
                                   print("The Request was sent successfuly")
                               
                                   self.uberhavebeenCalled = true
                                   self.reuestuberDrive.setTitle("Cancel Uber", for: UIControl.State.normal)
                                   
                               }
                           }
                       }else
                       {
                             let database = Database.database().reference().child("RiderRequest")
                             self.reuestuberDrive.setTitle("Request an Uber", for: UIControl.State.normal)
                              database.queryOrdered(byChild: "email").queryEqual(toValue: myemail).observe(.childAdded) { (snapshot) in
                               snapshot.ref.removeValue()
                               database.removeAllObservers()
                                 self.uberhavebeenCalled = false
                                 
                           }
                          
                           
                       }
                       
                   }
        }
    }
    
    @IBAction func logoutbutton(_ sender: Any)
    {
        do
        {
            try Auth.auth().signOut()
            navigationController?.dismiss(animated: true, completion: nil)
        }catch let error as NSError
        {
            alertMessage(title: "Error", message: error.localizedDescription)
        }
    }
    
    func alertMessage(title: String,message: String)
    {
        let alert = UIAlertController(title: title, message: message
            , preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "ok", style: .default) { (erickmiessage) in
            
        }
        alert.addAction(alertAction)
        self.present(alert, animated: true, completion: nil)
        
    }
    
}
