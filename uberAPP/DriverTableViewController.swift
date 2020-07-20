//
//  DriverTableViewController.swift
//  uberAPP
//
//  Created by El nino Cholo on 2020/07/14.
//  Copyright © 2020 El nino Cholo. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation
import MapKit

class DriverTableViewController: UITableViewController ,CLLocationManagerDelegate {

    var myfirebaseuserlocationobject = [DataSnapshot]()
    let locationManager = CLLocationManager()
    var driverLocation = CLLocationCoordinate2D()
    var driverlat:Double?
    var driverlon:Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        tableView.separatorStyle = .none
        
        Database.database().reference().child("RiderRequest").observe(.childAdded) { (snapshot) in
            //we checking if the user has a driver already
            if let riderDctionary = snapshot.value as? [String:Any]
            {
                if self.driverlat == riderDctionary["driverlat"] as? Double
                {
                    if self.driverlon == riderDctionary["driverlon"] as? Double
                    {
                         print("There is a driver assigned to this ride already")
                                      
                    }
                   
                }
                
                self.myfirebaseuserlocationobject.append(snapshot)
               
            }
        }
        
            Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (Timer) in
            self.tableView.reloadData()
        }

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myfirebaseuserlocationobject.count
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        
        if location.horizontalAccuracy > 0
        {
            driverLocation = location.coordinate
            
            print(driverLocation)
            
        }
       
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
       let item = myfirebaseuserlocationobject[indexPath.row]
       
        if let myitemCell = item.value as? [String:Any]
        {
            let latitude = myitemCell["lat"] as! Double
            let longitude = myitemCell["lon"] as! Double
            let email = myitemCell["email"] as! String
            
            let userprecise = CLLocation(latitude: latitude, longitude: longitude)
            let driverprecise = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
            let differcentKM = driverprecise.distance(from: userprecise) / 1000
            let roundedvalue = round(differcentKM * 100) / 100

            cell.textLabel?.text = "\(email) - \(roundedvalue)km away"
            cell.backgroundColor = UIColor.black
            cell.textLabel?.textColor = UIColor.white
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
         let currrentUserCoordinate = myfirebaseuserlocationobject[indexPath.row].value as? [String:Any]

        performSegue(withIdentifier: "activitysegue", sender: currrentUserCoordinate)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "activitysegue"
        {
            let secondVC = segue.destination as! AcceptRideViewController
            
            if let userCoordinate = sender as? [String:Any]
            {
                let lat = userCoordinate["lat"] as! Double
                let lon = userCoordinate["lon"] as! Double
                let email = userCoordinate["email"] as! String
                let myuserlocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                secondVC.reuqestLoaction = myuserlocation
                secondVC.reuqestEmail = email
                secondVC.DrivierLocation = driverLocation
                
            }
        }
    }
    

    @IBAction func logOut(_ sender: Any)
    {
        do
        {
            try Auth.auth().signOut()
        }catch let error as NSError
        {
            print("There was an error while trying to log out", error)
        }
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
}
