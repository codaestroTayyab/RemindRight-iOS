//
//  ChangePasswordViewController.swift
//  RemindRight
//
//  Created by Dev on 12/11/2023.
//

import Foundation
import UIKit
import FirebaseAuth

class ChangePasswordViewController: UIViewController {
    
    private let oldPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Old Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let newPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "New Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let confirmPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Confirm Password"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 5
        return button
    }()
    
    private let warningLabel: UILabel = {
        let label = UILabel()
        label.text = "Passwords do not match"
        label.textColor = .red
        label.isHidden = true
        return label
    }()
    
    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        setupConstraints()
    }
    
    private func setupUI() {
        view.addSubview(stackView)
        stackView.addArrangedSubview(oldPasswordTextField)
        stackView.addArrangedSubview(newPasswordTextField)
        stackView.addArrangedSubview(confirmPasswordTextField)
        view.addSubview(warningLabel)
        view.addSubview(saveButton)
        
        // Set content insets for the button
        saveButton.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        
        // Set content hugging priority to avoid compression of the button's intrinsic size
        saveButton.setContentHuggingPriority(.required, for: .vertical)
        
        saveButton.addTarget(self, action: #selector(savePasswordTapped), for: .touchUpInside)
    }
    
    
    private func setupConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            saveButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            saveButton.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 20),
            
            warningLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            warningLabel.topAnchor.constraint(equalTo: saveButton.bottomAnchor, constant: 8)
        ])
    }
    
    @objc private func savePasswordTapped() {
        // Check if the new password and confirm password match
        guard let newPassword = newPasswordTextField.text, let confirmPassword = confirmPasswordTextField.text, newPassword == confirmPassword else {
            warningLabel.isHidden = false
            warningLabel.text = "Password and confirm password do not match"
            return
        }
        
        // Authenticate the user with their current password to update the password
        if let user = Auth.auth().currentUser, let oldPassword = oldPasswordTextField.text {
            let credential = EmailAuthProvider.credential(withEmail: user.email!, password: oldPassword)
            user.reauthenticate(with: credential) { _, error in
                if let e = error {
                    // The old password is incorrect
                    self.warningLabel.isHidden = false
                    self.warningLabel.text = "Old password is incorrect"
                    print(e)
                } else {
                    // Change the password
                    user.updatePassword(to: newPassword) { error in
                        if let error = error {
                            // Handle password change error
                            print("Error changing password: \(error.localizedDescription)")
                            self.warningLabel.isHidden = false
                            self.warningLabel.text = "Error changing password"
                        } else {
                            // Password successfully changed
                            print("Password changed successfully")
                            self.warningLabel.isHidden = false
                            self.warningLabel.text = "Password changed successfully"
                            self.warningLabel.textColor = UIColor.green
                            
                            // Delay popping back to the previous screen
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
}
