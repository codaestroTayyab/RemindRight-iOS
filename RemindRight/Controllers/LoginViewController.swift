//
//  LoginViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
   
    @IBOutlet weak var txtfEmail: UITextField!
    
    @IBOutlet weak var txtfPassword: UITextField!
    
    @IBOutlet weak var lblWarning: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad();
        
        lblWarning.isHidden = true;
    }
    
    
   
    @IBAction func loginPressed(_ sender: UIButton) {
        
        let remindersViewController = storyboard?.instantiateViewController(withIdentifier: "ReminderListViewController") as! ReminderListViewController;

        if let email = txtfEmail.text, let password = txtfPassword.text {
            Auth.auth().signIn(withEmail: email, password: password) { [self] authResult, error in
                if let e = error {
                    self.lblWarning.isHidden = false;
                    self.lblWarning.text = "Incorrect Password"
                    print(e);
                }
                else {
                    self.navigationController?.pushViewController(remindersViewController, animated: true)
                    
                }
            }
        }
        
    }
    
}
