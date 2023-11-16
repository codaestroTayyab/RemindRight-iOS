//
//  ReminderListViewController.swift
//  RemindRight
//
//  Created by Dev on 06/11/2023.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import UserNotifications
import SDWebImage

private let reuseIdentifier = "Cell"

class ReminderListViewController: UICollectionViewController {
    
    
    
    var dataSource: DataSource!
    var reminders: [Reminder] = []
    let db = Firestore.firestore();
    let firebaseService = FirebaseService();
    var userId: String = "user123"
    
    var searchController: UISearchController!
    var isSearching: Bool = false
    var profileImageView: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkLoginState();

        setupSearchController()
        
        setupProfileImage();
        
        assignUserId();
        
        getNotificationPermission();

        
        
        //Assigning our custom layout to collection View
        let listLayout = listLayout();
        collectionView.collectionViewLayout = listLayout;
        
        //Cell registration specifies how to configure the content and appearance of a cell.
        let cellRegistration = UICollectionView.CellRegistration(handler: cellRegistrationHandler) //Calls the method from the extension vc, that have data source logic
        
        
        //In the initializer, you pass a closure that configures and returns a cell for a collection view.
        dataSource = DataSource(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, itemidentifier: Reminder.ID) in
            return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemidentifier)
        }
        
        
        
        //Apply the data source to the Collection View
        collectionView.dataSource = dataSource;
        
        //Add button on the top left of navigation bar
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didPressAddButton(_:)))
        navigationItem.rightBarButtonItem = addButton;
        
        DispatchQueue.main.async {
            self.fetchRemindersFromFirestore();
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("Reminder array at view will appear: \(reminders)")
        setupProfileImage()
        DispatchQueue.main.async {
            self.reminders.forEach {
                self.updateSnapshot(reloading: [$0.id])
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let id = reminders[indexPath.row].id
        pushDataForDetailVC(withId: id);
        return false;
    }
    
    func pushDataForDetailVC(withId id: Reminder.ID) {
        let reminder = reminder(withId: id);
        let detailViewController = ReminderViewController(reminder: reminder) { [weak self] reminder in
            self?.updateReminder(reminder);
            print("Reminder from detail VC: \(reminder)")
            self?.updateSnapshot(reloading: [reminder.id]);
        }
        navigationController?.pushViewController(detailViewController, animated: true);
    }
    
    func getNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                // User granted permission
                print("Notification permission granted")
            } else {
                // Handle denial or error
                print("Notification permission denied or error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    func assignUserId () {
        //Checking user signed-in using Firebase Auth
        guard let currentUser = Auth.auth().currentUser else {
            print("No user signed in")
            return}
        
        self.userId = currentUser.uid;
    }
    
    
    func checkLoginState() {
        // Add the auth state change listener
               Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
                   if user == nil {
                       // User is not signed in, navigate back to the welcome screen
                       self?.navigateToWelcomeScreen()
                   }
               }
    }
    
    //Creates a new list configuration variable with the grouped appearance.
    private func listLayout() -> UICollectionViewCompositionalLayout {
        
        //UICollectionLayoutListConfiguration creates a section in a list layout.
        var listConfiguration = UICollectionLayoutListConfiguration(appearance: .grouped)
        
        listConfiguration.showsSeparators = false
        listConfiguration.backgroundColor = .clear
        listConfiguration.trailingSwipeActionsConfigurationProvider = makeSwipeActions
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    private func makeSwipeActions(for indexPath: IndexPath?) -> UISwipeActionsConfiguration? {
        guard let indexPath = indexPath, let id = dataSource.itemIdentifier(for: indexPath) else {
            return nil
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            self?.deleteReminder(withId: id)
            self?.updateSnapshot()
            completion(false);
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    
    
    private func setupSearchController() {
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false;
    }
    
    private func navigateToWelcomeScreen() {
            let welcomeViewController = storyboard?.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
        
            navigationController?.setViewControllers([welcomeViewController], animated: true)
        }

    private func setupProfileImage() {
        let profileImageView = UIImageView()
        profileImageView.contentMode = .scaleAspectFill
       
        
        let profileImageSize = CGSize(width: 30, height: 30)
        profileImageView.frame = CGRect(origin: .zero, size: profileImageSize)
        
        profileImageView.layer.cornerRadius = profileImageSize.width / 2
        profileImageView.clipsToBounds = true

        let profileButton = UIButton(type: .custom)
        profileButton.addSubview(profileImageView)

        // Add a tap gesture to handle the profile button press
        profileButton.addTarget(self, action: #selector(didPressProfileButton(_:)), for: .touchUpInside)

        // Load and display user's profile image from Firebase Storage using SDWebImage
        if let user = Auth.auth().currentUser {
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
        }

        // Set the custom view as the titleView of the navigation item
        navigationItem.titleView = profileButton
    }
    
    @objc func didPressProfileButton(_ sender: Any) {
        // Handle the profile button press, navigate to the profile view controller
        let profileViewController = storyboard?.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController; // Replace with your profile view controller
                    navigationController?.pushViewController(profileViewController, animated: true)
        
        print("Navigated to profile")
    }
    
    func scheduleNotification(for reminder: Reminder) {
        let content = UNMutableNotificationContent()
        content.title = "Reminder: \(reminder.title)"
        content.body = "Don't forget to \(reminder.notes ?? "do something")!"
        content.sound = UNNotificationSound.default

        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)

        let request = UNNotificationRequest(identifier: reminder.id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully!")
            }
        }
    }
    
//    func scheduleNotification(for reminder: Reminder, with documentID: String) {
//        // Use the document ID to create a unique notification identifier
//        let notificationID = "ReminderNotification_\(documentID)"
//
//        // Rest of the notification scheduling logic...
//    }
}
