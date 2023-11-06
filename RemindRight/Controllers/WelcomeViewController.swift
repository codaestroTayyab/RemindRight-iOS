//
//  ViewController.swift
//  RemindRight
//
//  Created by Dev on 03/11/2023.
//

import UIKit

class WelcomeViewController: UIViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()
       
    }
    
        
    @IBAction func registerPressed(_ sender: UIButton) {
        
        let registerViewController = storyboard?.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController;
        
        navigationController?.pushViewController(registerViewController, animated: true)
    }
    
    @IBAction func loginPressed(_ sender: UIButton) {
        
        let loginViewController = storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController;
        
        navigationController?.pushViewController(loginViewController, animated: true)
        
    }
    
}

