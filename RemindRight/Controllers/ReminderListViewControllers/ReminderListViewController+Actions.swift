//
//  ReminderListViewController+Actions.swift
//  RemindRight
//
//  Created by Dev on 07/11/2023.
//

import Foundation
import UIKit

extension ReminderListViewController {
//    @objc func didPressDoneButton(_ sender: ReminderDoneButton) {
//        guard let id = sender.id else {
//            return }
//        completeReminder(withId: id);
//    }
    
    @objc func didPressAddButton(_ sender: UIBarButtonItem) {
        let reminder = Reminder(title: "", dueDate: Date.now)
        let viewController = ReminderViewController(reminder: reminder) { [weak self] reminder in
            self?.addReminder(reminder);
            self?.updateSnapshot()
            self?.navigationController?.popViewController(animated: true)
        }
        viewController.isAddingNewReminder = true;
        viewController.setEditing(true, animated: false)
        viewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
                    barButtonSystemItem: .cancel, target: self, action: #selector(didCancelAdd(_:)))
        viewController.navigationItem.title = "Add Reminder"
        navigationController?.pushViewController(viewController, animated: true);
    }
    
    @objc func didCancelAdd (_ sender: UIBarButtonItem) {
        navigationController?.popViewController(animated: true);
    }
}
