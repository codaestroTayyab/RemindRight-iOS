//
//  ProfileViewController.swift
//  RemindRight
//
//  Created by Dev on 12/11/2023.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseStorage
import SDWebImage

class ProfileViewController: UIViewController {
    
    @IBOutlet private weak var profileImageView: UIImageView!
    @IBOutlet private weak var txtfName: UITextField!
    @IBOutlet private weak var txtfEmail: UITextField!
    
    @IBOutlet weak var lblWarning: UILabel!
    
    @IBOutlet weak var btnSave: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        setupLogoutButton();
        // Load user data into UI elements
        updateUI()
    }
    
    private func setupProfilePicture(for user: User) {
            // Load and display user's profile image from Firebase Storage
            if let photoURL = user.photoURL {
                profileImageView.sd_setImage(with: photoURL, placeholderImage: UIImage(named: "defaultProfileImage")) { (image, error, cacheType, url) in
                    if let error = error {
                        print("Error loading profile image: \(error.localizedDescription)")
                    } else {
                        print("User profile image updated from setupProfileImage")
                    }
                }
            } else {
                // User does not have a profile image, display default profile picture
                profileImageView.image = UIImage(named: "defaultProfileImage")
            }
            
            // Customize your UI elements as needed
            profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2
            profileImageView.clipsToBounds = true
            
            // Add gesture recognizer to handle tapping on the image for editing
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(editImageTapped))
            profileImageView.addGestureRecognizer(tapGesture)
            profileImageView.isUserInteractionEnabled = true
        }
    
    private func updateUI() {
        // Replace the following lines with your logic to fetch user data
        if let user = Auth.auth().currentUser {
            let userName = user.displayName
            let userEmail = user.email
            txtfEmail.text = userEmail
            txtfName.text = userName
            
            setupProfilePicture(for: user)
        }
        txtfName.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        btnSave.isEnabled = false
        lblWarning.isHidden = true
        txtfEmail.isEnabled = false
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
    
    @IBAction func btnSavePressed(_ sender: UIButton) {
        // Validate the name before saving
        print("Save button pressed")
        guard let updatedName = txtfName.text, !updatedName.isEmpty else {
            DispatchQueue.main.async {
                self.lblWarning.isHidden = false
                self.lblWarning.textColor = UIColor.red
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
                        self.lblWarning.textColor = UIColor.red
                        self.lblWarning.text = "Error updating user profile"
                    }
                } else {
                    DispatchQueue.main.async {
                        self.lblWarning.isHidden = false
                        self.lblWarning.textColor = UIColor.green
                        self.lblWarning.text = "User profile updated successfully"
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.lblWarning.isHidden = false
                self.lblWarning.textColor = UIColor.red;
                self.lblWarning.text = "Error. Try Again."
            }
        }
    }
    
    // Action when the edit image button is tapped
    @objc func editImageTapped() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Action when the change password button is tapped
    @IBAction func changePasswordTapped() {
        // Present the modal for changing the password
        let changePasswordVC = ChangePasswordViewController()
        navigationController?.pushViewController(changePasswordVC, animated: true);
    }
}

//MARK: - UIImagePicker Delegate

// Add UIImagePickerControllerDelegate and UINavigationControllerDelegate to your class declaration
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.editedImage] as? UIImage {
            profileImageView.image = pickedImage
            uploadImageToFirebase(image: pickedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImageToFirebase(image: UIImage) {
        // Convert the image to Data
        if let imageData = image.jpegData(compressionQuality: 0.5) {
            // Get the user's UID
            guard let userUID = Auth.auth().currentUser?.uid else {
                print("Error: User UID not available.")
                return
            }
            
            // Create a unique file name for the image using the user's UID
            let imageName = "\(userUID)_\(UUID().uuidString).jpg"
            
            // Get a reference to the Firebase Storage location
            let storageRef = Storage.storage().reference().child("profileImages").child(imageName)
            
            // Upload the image to Firebase Storage
            storageRef.putData(imageData, metadata: nil) { (metadata, error) in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    // Handle error
                    if let detailedError = error as NSError? {
                            print("Detailed Error Code: \(detailedError.code)")
                            print("Detailed Error Domain: \(detailedError.domain)")
                        }
                } else {
                    // Image uploaded successfully, update user profile with image URL
                    storageRef.downloadURL { (url, error) in
                        if let downloadURL = url {
                            // Update the user's profile with the image URL
                            if let user = Auth.auth().currentUser {
                                let changeRequest = user.createProfileChangeRequest()
                                changeRequest.photoURL = downloadURL
                                changeRequest.commitChanges(completion: { (error) in
                                    if let error = error {
                                        print("Error updating user profile with image URL: \(error.localizedDescription)")
                                        // Handle error
                                    } else {
                                        print("User profile updated with image URL: \(downloadURL.absoluteString)")
                                    }
                                })
                            }
                        } else {
                            print("Error getting image URL: \(error?.localizedDescription ?? "Unknown error")")
                            // Handle error
                        }
                    }
                }
            }
        }
    }
}


