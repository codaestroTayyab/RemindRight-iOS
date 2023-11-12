//
//  DatePickerContentView.swift
//  RemindRight
//
//  Created by Dev on 10/11/2023.
//

import Foundation
import UIKit

class DatePickerContentView: UIView, UIContentView {
    struct Configuration: UIContentConfiguration {
        var date = Date.now
        
        var onChange: (Date) -> Void = {_ in}
        
        func makeContentView() -> UIView & UIContentView {
            return DatePickerContentView(self)
        }
        
    }
    
    let datePicker = UIDatePicker()
    
    var configuration: UIContentConfiguration {
        didSet {
            configure(configuration);
        }
    }
    
    @objc private func didPick(_ sender: UIDatePicker) {
        guard let configuration = configuration as? DatePickerContentView.Configuration else {return}
        configuration.onChange(sender.date);
    }
    
    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration;
        super.init(frame: .zero)
        addPinnedSubView(datePicker)
        datePicker.preferredDatePickerStyle = .inline
        datePicker.addTarget(self, action: #selector(didPick(_:)), for: .valueChanged)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) hasn't been implemented")
    }
    
    func configure(_ configuration: UIContentConfiguration) {
        guard let configuration = configuration as? Configuration else {return}
        datePicker.date = configuration.date
    }
}

extension UICollectionViewListCell {
    func datePickerConfiguration() -> DatePickerContentView.Configuration {
        DatePickerContentView.Configuration()
    }
}
