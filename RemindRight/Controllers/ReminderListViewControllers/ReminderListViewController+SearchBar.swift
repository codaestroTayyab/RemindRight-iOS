//
//  ReminderListViewController+SearchBar.swift
//  RemindRight
//
//  Created by Dev on 12/11/2023.
//

import Foundation
import UIKit

// Extension to handle search updates
extension ReminderListViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        if let searchText = searchBar.text, !searchText.isEmpty {
            isSearching = true
            // Filter your reminders based on the searchText
            // Update the snapshot with the filtered data
            filterRemindersAndReloadData(searchText: searchText)
        } else {
            isSearching = false
            // Update the snapshot with the original data
            updateSnapshot()
        }
    }
}


