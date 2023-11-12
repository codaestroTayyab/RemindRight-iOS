//
//  Date+Today.swift
//  RemindRight
//
//  Created by Dev on 06/11/2023.
//

import Foundation
extension Date {
    
    var dayAndTimeText: String {
        let timeText = formatted(date: .omitted, time: .shortened);
        if Locale.current.calendar.isDateInToday(self) {
            let timeFormat = NSLocalizedString("Due: Today at %@", comment: "Today at time format string")
            return String(format: timeFormat, timeText);
        } else {
            let dateText = formatted(.dateTime.month(.abbreviated).day())
            let dateAndTimeFormat = NSLocalizedString("Due: %@ at %@", comment: "Date and time format string")
            return String(format: dateAndTimeFormat, dateText, timeText)
        }
    }
    
    
}
