//
//  EditNoteView.swift
//  ios_course_hw_4
//
//  Created by Danil Mironov on 29.04.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation
import UIKit

protocol EditNoteViewProtocol {
    func showColorPicker()
    func setupInitGradiendColor(withColor color: UIColor)
}

@IBDesignable class EditNoteView: CommonView, ColorPickerPreviewViewProtocol {
    
    @IBOutlet weak var noteText: UITextView!
    @IBOutlet weak var noteTitle: UITextField!
    @IBOutlet weak var colorPickerPreview: ColorPickerPreviewView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var expireDateView: ExpireDateView!
    
    var delegate: EditNoteViewProtocol?
    
    override func commonInit() {
        super.commonInit()
        colorPickerPreview.delegate = self
    }
    
    override func awakeFromNib() {
        print("EditNoteView awakeFromNib")
//        let contentSize = noteText.sizeThatFits(noteText.bounds.size)
//        var frame = noteText.frame
//        frame.size.height = contentSize.height
//        noteText.frame = frame
    }
    
    // ColorPickerPreviewViewProtocol
    func gradientInitPressed(atIndex index: Int) {
        delegate?.showColorPicker()
    }
    
    func setupInitGradiendColor(withColor color: UIColor) {
        delegate?.setupInitGradiendColor(withColor: color)
    }
}
