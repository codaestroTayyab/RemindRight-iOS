//
//  ReminderListViewController+DataSource.swift
//  RemindRight
//
//  Created by Dev on 06/11/2023.
//

import Foundation
import UIKit
import SwipeCellKit
import UserNotifications

extension ReminderListViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Reminder.ID>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Reminder.ID>
    
    
    func updateSnapshot(reloading ids: [Reminder.ID] = []) {
        var snapshot = Snapshot()
        snapshot.appendSections([0])
        
        if isSearching {
            // Filter reminders based on the search text
            let filteredReminders = reminders.filter { $0.title.lowercased().contains(searchController.searchBar.text?.lowercased() ?? "") }
            snapshot.appendItems(filteredReminders.map { $0.id })
        } else {
            snapshot.appendItems(reminders.map { $0.id })
        }
        
        if !ids.isEmpty {
            snapshot.reloadItems(ids)
        }
        dataSource.apply(snapshot)
    }
    
    func fetchRemindersFromFirestore() {
        // Use Firebase authentication to get the current user's ID
        // Replace with your authentication logic
        
        // Create a reference to the Firestore collection
        let remindersCollection = db.collection("users").document(userId).collection("reminders").order(by: "addedDate", descending: true);
        
        // Add a snapshot listener to receive real-time updates
        remindersCollection.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching reminders: \(error.localizedDescription)")
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No documents found.")
                return
            }
            
            // Map Firestore documents to Reminder objects
            self.reminders = documents.compactMap { document in
                do {
                    return try document.data(as: Reminder.self)
                } catch {
                    print("Error decoding Reminder: \(error.localizedDescription)")
                    return nil
                }
            }
            print("Reminders array from FRFF: \(self.reminders.description)")
            
            // Update the snapshot with the fetched data
            self.updateSnapshot()
        }
    }
    
    func cellRegistrationHandler(cell: UICollectionViewListCell , indexPath: IndexPath, id: Reminder.ID) {
        let reminder = reminder(withId: id)
        var contentConfiguration = cell.defaultContentConfiguration()
        contentConfiguration.text = reminder.title
        contentConfiguration.secondaryText = reminder.dueDate.dayAndTimeText
        contentConfiguration.secondaryTextProperties.font = UIFont.preferredFont(
            forTextStyle: .caption1)
        cell.contentConfiguration = contentConfiguration
        //Done Button Configuration Intialization
//        var doneButtonConfiguration = doneButtonConfiguration(for: reminder)
//        doneButtonConfiguration.tintColor = UIColor(named: "TodayListCellDoneButtonTint")
        
        //Assigning to cell accessories
        cell.accessories = [ .disclosureIndicator(displayed: .always) ]
        
        
        //Setting Background Color for grouped cell
        var backgroundConfiguration = UIBackgroundConfiguration.listGroupedCell()
        backgroundConfiguration.backgroundColor = UIColor(named: "TodayListCellBackground")
        cell.backgroundConfiguration = backgroundConfiguration
    }
    
    func reminder(withId id: Reminder.ID) -> Reminder {
        let index = reminders.indexOfReminder(withId: id)
        return reminders[index]
    }
    
    func saveReminder(_ reminder: Reminder) {
        
        firebaseService.saveReminder(reminder, userId: userId) { error in
            if let error = error {
                print("Error saving reminder: \(error.localizedDescription)")
            } else {
                print("Reminder saved successfully")
            }
        }
    }
    
    func addReminder(_ reminder: Reminder) {
        scheduleNotification(for: reminder)
        saveReminder(reminder)
    }
    
    func updateReminder(_ reminder: Reminder) {
//        updateScheduledNotification(for: reminder)
        
        scheduleNotification(for: reminder)
        saveReminder(reminder)
    }
    
    
    //    func updateReminder(_ reminder: Reminder) {
    //        let index = reminders.indexOfReminder(withId: reminder.id)
    //        reminders[index] = reminder
    //    }
    
//    func completeReminder(withId id: Reminder.ID) {
//        var reminder = reminder(withId: id)
//        reminder.isComplete.toggle();
//        updateReminder(reminder);
//        updateSnapshot(reloading: [id]);
//    }
    
    //    func addReminder(_ reminder: Reminder) {
    //        reminders.append(reminder);
    //    }
    
    //    func deleteReminder (withId id: Reminder.ID) {
    //        let index = reminders.indexOfReminder(withId: id)
    //        reminders.remove(at: index)
    //    }
    
    func deleteReminder(withId id: Reminder.ID) {
        
        let reminderToDelete = self.reminder(withId: id)
        print("Reminder to delete: \(reminderToDelete)")
        self.deleteScheduledNotification(for: reminderToDelete)
        firebaseService.deleteReminder(withId: id, userId: userId) { error in
            if let error = error {
                print("Error deleting reminder: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    print("Reminder deleted successfully")
                }
            }
        }
    }
    
    func deleteScheduledNotification(for reminder: Reminder) {

        let notificationIds = [reminder.id] // Add logic to get notification identifiers for the reminder
        print("Notification Id from DSN: \(notificationIds)")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: notificationIds)
    }
//
//    func updateScheduledNotification(for reminder: Reminder) {
//        // Remove existing notification
//        deleteScheduledNotification(for: reminder)
//
//        // Add logic to reschedule the updated notification
//        scheduleNotification(for: reminder)
//    }


    // Method to filter reminders based on search text
    func filterRemindersAndReloadData(searchText: String) {
        let filteredReminders = reminders.filter { $0.title.lowercased().contains(searchText.lowercased()) }
        updateSnapshot(reloading: filteredReminders.map { $0.id })
    }
    
    
//
//    private func doneButtonConfiguration(for reminder: Reminder) -> UICellAccessory.CustomViewConfiguration {
//        let symbolName = reminder.isComplete ? "app.fill" : "app"
//        let symbolConfiguration = UIImage.SymbolConfiguration(textStyle: .title1)
//        let image = UIImage(systemName: symbolName, withConfiguration: symbolConfiguration)
//
//        let button = ReminderDoneButton();
//        button.addTarget(self, action: #selector(didPressDoneButton(_:)), for: .touchUpInside)
//        button.id = reminder.id;
//        button.setImage(image, for: .normal)
//
//        let customCellConfiguration = UICellAccessory.CustomViewConfiguration(customView: button, placement: .leading(displayed: .always))
//
//        return customCellConfiguration;
//    }
//
   

}
