//
//  NoteCellCollectionViewCell.swift
//  ios_course_hw_5
//
//  Created by Danil Mironov on 07.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import UIKit

class NoteCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var noteText: UILabel!
    @IBOutlet weak var noteTitle: UILabel!
    @IBOutlet weak var colorTriangle: NoteCellColor!
    @IBOutlet weak var editParanja: NoteEditMark!
    
    var editing = false {
        didSet {
            if editing {
                bringSubview(toFront: editParanja)
                editParanja.alpha = 0.5
            } else {
                sendSubview(toBack: editParanja)
                editParanja.alpha = 0
            }
        }
    }
}
