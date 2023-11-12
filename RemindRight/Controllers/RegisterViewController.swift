//
//  RegisterViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {
    
   
    @IBOutlet weak var txtfName: UITextField!
    
    @IBOutlet weak var txtfEmail: UITextField!
    
    
    @IBOutlet weak var txtfConfirmPass: UITextField!
    @IBOutlet weak var txtfPassword: UITextField!
    
    
    @IBAction func registerPressed(_ sender: UIButton) {
        
       let loginViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController;
        
        if let email = txtfEmail.text, let password = txtfPassword.text {
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e);
                }
                else{
                    self.navigationController?.pushViewController(loginViewController, animated: true)
                }
                
            }
        }
        
    }
    
}
