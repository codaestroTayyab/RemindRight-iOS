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
    
    @IBOutlet weak var lblWarning: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
        lblWarning.isHidden = true;
    }
    
    @IBAction func registerPressed(_ sender: UIButton) {
        
        let loginViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController;
        
        if let name = txtfName.text, let email = txtfEmail.text, let password = txtfPassword.text {
            if password == txtfConfirmPass.text {
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let error = error {
                        print(error.localizedDescription)
                        DispatchQueue.main.async {
                            self.lblWarning.isHidden = false
                            self.lblWarning.text = "\(error.localizedDescription)"
                        }
                    } else {
                        // Successfully created the user, now save the user's name
                        if let user = Auth.auth().currentUser {
                            // Create a user profile change request
                            let changeRequest = user.createProfileChangeRequest()
                            changeRequest.displayName = name
                            changeRequest.photoURL = nil
                            
                            // Commit the changes to the user's profile
                            changeRequest.commitChanges { error in
                                if let error = error {
                                    DispatchQueue.main.async {
                                        self.lblWarning.isHidden = false
                                        self.lblWarning.text = "\(error.localizedDescription)"
                                    }
                                } else {
                                    DispatchQueue.main.async {
                                        self.lblWarning.isHidden = false
                                        self.navigationController?.pushViewController(loginViewController, animated: true)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
