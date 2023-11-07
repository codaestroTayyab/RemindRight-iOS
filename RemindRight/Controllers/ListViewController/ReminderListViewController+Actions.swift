//
//  ReminderListViewController+Actions.swift
//  RemindRight
//
//  Created by Dev on 07/11/2023.
//

import Foundation
import UIKit

extension ReminderListViewController {
    @objc func didPressDoneButton(_ sender: ReminderDoneButton) {
        guard let id = sender.id else { return }
        completeReminder(withId: id);
    }
}
