//
//  ProfileViewController.swift
//  RemindRight
//
//  Created by Dev on 12/11/2023.
//

import Foundation
import UIKit
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var txtfName: UITextField!
    @IBOutlet private weak var txtfEmail: UITextField!
    
    @IBOutlet weak var lblWarning: UILabel!
    
    @IBOutlet weak var btnSave: UIButton!
    let profileImage = UIImage(named: "profileImage")
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupLogoutButton();
        // Load user data into UI elements
        updateUI()
    }
    
    private func setupProfilePicture () {
        profileImageView.image = profileImage;
        // Customize your UI elements as needed
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
        profileImageView.clipsToBounds = true
        
        // Add gesture recognizer to handle tapping on the image for editing
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(editImageTapped))
        profileImageView.addGestureRecognizer(tapGesture)
        profileImageView.isUserInteractionEnabled = true
    }
    
    // Function to load/update user data in UI elements
    private func updateUI() {
        // Replace the following lines with your logic to fetch user data
        if let user = Auth.auth().currentUser {
            let userName = user.displayName
            let userEmail = user.email
            txtfEmail.text = userEmail
            txtfName.text = userName
        }
        txtfName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        setupProfilePicture();
        btnSave.isEnabled = false;
        lblWarning.isHidden = true;
        txtfEmail.isEnabled = false;
    }
    
    private func setupLogoutButton() {
        // Create a logout button
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutButtonPressed))

        // Set the button to the right side of the navigation bar
        navigationItem.rightBarButtonItem = logoutButton
    }
    
    @objc private func textFieldDidChange (_ textField: UITextField) {
        btnSave.isEnabled = true;
    }

    @objc private func logoutButtonPressed() {
        // Implement the logout functionality using Firebase Auth
        do {
            try Auth.auth().signOut()
            // Navigate back to the first screen (assuming it's the root view controller)
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    @IBAction func saveNameButton(_ sender: UIButton) {
        // Validate the name before saving
        guard let updatedName = txtfName.text, !updatedName.isEmpty else {
            DispatchQueue.main.async {
                self.lblWarning.isHidden = false
                self.lblWarning.text = "Name Field can't be empty"
            }
            print("Name Field can't be empty")
            return
        }

        
        // Update the user's display name in Firebase
        if let user = Auth.auth().currentUser {
            let changeRequest = user.createProfileChangeRequest()
            changeRequest.displayName = updatedName
            changeRequest.commitChanges { error in
                if let _ = error {
                    DispatchQueue.main.async {
                        self.lblWarning.isHidden = false
                        self.lblWarning.text = "Error updating user profile"
                    }
                } else {
                    DispatchQueue.main.async {
                        self.lblWarning.isHidden = false
                        self.lblWarning.text = "User profile updated successfully"
                        self.lblWarning.textColor = UIColor.green
                    }
                }
            }
        }else{
            DispatchQueue.main.async {
                self.lblWarning.isHidden = false
                self.lblWarning.text = "Error. Try Again."
            }
        }
    }
    
    // Action when the edit image button is tapped
    @objc func editImageTapped() {
        // Implement image editing logic
        // This could open the image picker or another view controller for image editing
        
        print("edit image open")
    }
    
    // Action when the change password button is tapped
    @IBAction func changePasswordTapped() {
        // Present the modal for changing the password
        let changePasswordVC = ChangePasswordViewController()
        navigationController?.pushViewController(changePasswordVC, animated: true);
    }
}

