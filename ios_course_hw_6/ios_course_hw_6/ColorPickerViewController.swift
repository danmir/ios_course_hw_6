//
//  ColorPickerViewController.swift
//  ios_course_hw_4
//
//  Created by Danil Mironov on 01.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import UIKit

protocol ColorPickerViewControllerProtocol {
    func colorPickerColorChanged(color: UIColor)
}

class ColorPickerViewController: UIViewController {
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var colorPickerView: ColorPickerView!
    
    static let defaultColor = UIColor.green
    
    var delegate: ColorPickerViewControllerProtocol?
    var color = ColorPickerViewController.defaultColor {
        didSet {
            colorPickerView.color = color
        }
    }
    
    init(withColor color: UIColor) {
        super.init(nibName: nil, bundle: nil)
        self.color = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        colorPickerView.color = color
        colorPickerView.addTarget(self, action: #selector(colorChangedInColorPicker(_:)), for: UIControlEvents.valueChanged)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func returnToEditNote(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        delegate?.colorPickerColorChanged(color: colorPickerView.color)
    }
    
    func colorChangedInColorPicker(_ sender: ColorPickerView) {
        //print("colorChangedInColorPicker")
        //delegate?.colorPickerColorChanged(color: sender.color)
    }
}
