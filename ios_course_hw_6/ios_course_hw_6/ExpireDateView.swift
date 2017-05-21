//
//  ExpireDateView.swift
//  ios_course_hw_4
//
//  Created by Danil Mironov on 29.04.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class ExpireDateView: CommonView {
    
    @IBAction func destroyDateSwitchChanged(_ sender: UISwitch) {
        destroyDatePickerIsOn(state: sender.isOn)
//        destroyDatePicker.isHidden = !sender.isOn
//        setNeedsLayout()
    }
    
    @IBOutlet weak var destroyDatePicker: UIDatePicker!
    @IBOutlet weak var destroyDateSwitch: UISwitch!
    @IBOutlet weak var stack: UIStackView!
    @IBOutlet weak var innerStack: UIStackView!
    
    override func layoutSubviews() {
        print("Layout ExpireDateView \(frame)")
    }
    
    override func commonInit() {
        super.commonInit()
        clipsToBounds = true
    }
    
    func destroyDatePickerIsOn(state: Bool) {
        destroyDatePicker.isHidden = !state
        setNeedsLayout()
    }
}
