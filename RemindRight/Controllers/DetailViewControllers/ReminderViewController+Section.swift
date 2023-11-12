//
//  ReminderViewController+Section.swift
//  RemindRight
//
//  Created by Dev on 08/11/2023.
//

import Foundation
extension ReminderViewController {
    enum Section: Int, Hashable {
        case view
        case title
        case date
        case notes
        
        var name: String {
            switch self {
            case .view: return ""
                
            case .title:
                return "Title"
            case .date:
                return "Date"
            case .notes:
                return "Notes"
            }
        }
    }
}
