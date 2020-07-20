//
//  ViewController.swift
//  uberAPP
//
//  Created by El nino Cholo on 2020/07/13.
//  Copyright © 2020 El nino Cholo. All rights reserved.
//

import UIKit
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth

class ViewController: UIViewController {
    
    @IBOutlet weak var driverlabele: UILabel!
    @IBOutlet weak var riderlabel: UILabel!
    @IBOutlet weak var emailAdress: UITextField!
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var driverRiderSwitch: UISwitch!
    
    @IBOutlet weak var topbutton: UIButton!
    
    @IBOutlet weak var bottombutton: UIButton!
    
    var signUpmode:Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func signUPButtonPressed(_ sender: Any)
    {
        if  (emailAdress.text == "" || passwordField.text == "")
        {
            alertMessage(title: "Missing Information", message: "You must provide both password and email")
            
        }else
        {
            if signUpmode
            {
                  //Auth
                if let email = emailAdress.text
                {
                    if let password = passwordField.text
                    {
                        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
                        if error != nil
                        {
                            self.alertMessage(title: "Error", message: error!.localizedDescription)
                        }else
                        {
                            if self.driverRiderSwitch.isOn
                            {
                                //Driver
                                let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                req?.displayName = "Driver"
                                req?.commitChanges(completion: nil)
                                self.performSegue(withIdentifier: "DriverSegue", sender: self)
                            }else
                            {
                                //Rider
                                let req = Auth.auth().currentUser?.createProfileChangeRequest()
                                req?.displayName = "Rider"
                                req?.commitChanges(completion: nil)
                                self.alertMessage(title: "Success", message: "You have created your account succesfully")
                                self.performSegue(withIdentifier: "segueRider", sender: self)
                            }
                           
                        }
                     }
                                
                    }
                }
            }else
            {
                
                if let email = emailAdress.text
                {
                    if let password = passwordField.text
                    {
                        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                            if error != nil
                            {
                                self.alertMessage(title: "Error", message: error!.localizedDescription)
                            }else
                            {
                                if user?.user.displayName == "Driver"
                                {
                                      print("Driver Signed In")
                                    self.performSegue(withIdentifier: "DriverSegue", sender: self)
                                }else
                                {
                                    self.performSegue(withIdentifier: "segueRider", sender: self)
                                }
                                
                               
                            }
                        }
                    }
                }
                
            }
            
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
    @IBAction func switchtologinButton(_ sender: Any)
    {
        if signUpmode == true
        {
            topbutton.setTitle("LogIn", for: UIControl.State.normal)
            bottombutton.setTitle("Switch SignUp", for: UIControl.State.normal)
            driverlabele.isHidden = true
            riderlabel.isHidden = true
            driverRiderSwitch.isHidden = true
            
            signUpmode = false
        }else
        {
            topbutton.setTitle("Sign Up", for: UIControl.State.normal)
            bottombutton.setTitle("Switch LogIn", for: UIControl.State.normal)
            driverlabele.isHidden = false
            riderlabel.isHidden = false
            driverRiderSwitch.isHidden = false
            
            signUpmode = true
        }
    }
}

