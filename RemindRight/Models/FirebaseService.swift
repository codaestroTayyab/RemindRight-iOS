//
//  FirebaseService.swift
//  RemindRight
//
//  Created by Dev on 10/11/2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class FirebaseService {

    let db = Firestore.firestore()

    func saveReminder(_ reminder: Reminder, userId: String, completion: @escaping (Error?) -> Void) {
        do {
            try db.collection("users").document(userId).collection("reminders").document(reminder.id).setData(from: reminder) { error in
                completion(error)
            }
        } catch {
            completion(error)
        }
    }

    func addReminder(_ reminder: Reminder, userId: String, completion: @escaping (Error?) -> Void) {
        saveReminder(reminder, userId: userId, completion: completion)
    }

    func updateReminder(_ reminder: Reminder, userId: String, completion: @escaping (Error?) -> Void) {
        saveReminder(reminder, userId: userId, completion: completion)
    }

    func deleteReminder(withId id: Reminder.ID, userId: String, completion: @escaping (Error?) -> Void) {
        db.collection("users").document(userId).collection("reminders").document(id).delete { error in
            completion(error)
        }
    }
}
