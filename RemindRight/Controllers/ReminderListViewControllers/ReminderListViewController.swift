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

private let reuseIdentifier = "Cell"

class ReminderListViewController: UICollectionViewController {

   
    
    var dataSource: DataSource!
    var reminders: [Reminder] = []
    let db = Firestore.firestore();
    let firebaseService = FirebaseService();
    var userId: String = "user123"
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Tasks"
        
        //Checking user signed-in using Firebase Auth
        guard let currentUser = Auth.auth().currentUser else {
            print("No user signed in")
            return}
        
        self.userId = currentUser.uid;
        
        
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
        DispatchQueue.main.async {
            self.updateSnapshot()
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
            self?.updateSnapshot(reloading: [reminder.id]);
        }
        navigationController?.pushViewController(detailViewController, animated: true);
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

}
