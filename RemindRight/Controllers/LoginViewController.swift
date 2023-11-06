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
    
    override func viewDidLoad() {
        super.viewDidLoad();
    }
    
    
   
    @IBAction func loginPressed(_ sender: UIButton) {
        
        let remindersViewController = storyboard?.instantiateViewController(withIdentifier: "ReminderListViewController") as! ReminderListViewController;

        if let email = txtfEmail.text, let password = txtfPassword.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e);
                }
                else {
                    self.navigationController?.pushViewController(remindersViewController, animated: true)
                    
                }
            }
        }
        
    }
    
}
