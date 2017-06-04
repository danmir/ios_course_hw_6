//
//  EditNoteViewController.swift
//  ios_course_hw_5
//
//  Created by Danil Mironov on 09.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import UIKit

class EditNoteViewController: UIViewController, EditNoteViewProtocol, ColorPickerViewControllerProtocol {
    @IBOutlet var editNoteView: EditNoteView!
    
    var colorPicker: ColorPickerViewController?
    lazy var colorPickerPresentationManager = ColorPickerPresentationManager()
    
    // Data for note
    var note: Note?
    var editedNote: Note?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editNoteView.delegate = self
        colorPicker?.delegate = self
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(keyBoardDidShow(notification:)), name: Notification.Name.UIKeyboardDidShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        
        if let note = self.note {
            editNoteView.noteTitle.text = note.title
            editNoteView.noteText.text = note.content
            if let date = note.expireDate {
                editNoteView.expireDateView.destroyDatePicker.setDate(date, animated: true)
            } else {
                editNoteView.expireDateView.destroyDateSwitch.isOn = false
                editNoteView.expireDateView.destroyDatePickerIsOn(state: false)
            }
            editNoteView.colorPickerPreview.currentColor = note.color
        } else {
            editNoteView.noteTitle.text = "New Note Title"
            editNoteView.expireDateView.destroyDateSwitch.isOn = false
            editNoteView.expireDateView.destroyDatePickerIsOn(state: false)
        }
    }
    
    func keyBoardDidShow(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        guard let kbFrame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }
        let kbSize = kbFrame.cgRectValue.size
        
        let contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0)
        editNoteView.scrollView.contentInset = contentInsets
        editNoteView.scrollView.scrollIndicatorInsets = contentInsets
    }
    
    func keyBoardWillHide(notification: Notification) {
        let contentInsets = UIEdgeInsets.zero
        editNoteView.scrollView.contentInset = contentInsets
        editNoteView.scrollView.scrollIndicatorInsets = contentInsets
        
    }
    
//    override func viewWillDisappear(_ animated: Bool) {
//        print("Edit view will disappear")
//        if let uid = note?.uid, let noteContent = editNoteView.noteTitle.text {
//            editedNote = Note(title: noteContent, content: editNoteView.noteText.text, color: editNoteView.colorPickerPreview.currentColor, uid: uid, expireDate: editNoteView.expireDateView.destroyDatePicker.date)
//        }
//    }
    
    // EditNoteViewProtocol
    func showColorPicker() {
        if colorPicker == nil {
            colorPicker = ColorPickerViewController(withColor: UIColor.green)
        }
        guard let colorPicker = colorPicker else { return }
        colorPicker.delegate = self
        
        colorPickerPresentationManager.disableCompactHeight = true
        colorPicker.transitioningDelegate = colorPickerPresentationManager
        colorPicker.modalPresentationStyle = .custom
        
        present(colorPicker, animated: true, completion: nil)
    }
    
    func setupInitGradiendColor(withColor color: UIColor) {
        if colorPicker == nil {
            colorPicker = ColorPickerViewController(withColor: color)
        }
        colorPicker?.delegate = self
    }
    
    // ColorPickerViewControllerProtocol
    func colorPickerColorChanged(color: UIColor) {
        editNoteView.colorPickerPreview.gradientColor = color
    }
    
}
