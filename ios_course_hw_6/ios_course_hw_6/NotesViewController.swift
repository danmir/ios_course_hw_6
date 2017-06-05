//
//  NotesViewController.swift
//  ios_course_hw_5
//
//  Created by Danil Mironov on 10.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import UIKit
import CoreData

class NotesViewController: UIViewController, UICollectionViewDelegate {

    @IBOutlet weak var notesCollectionView: UICollectionView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var widthChangeSlider: UISlider!
    let step: CGFloat = 0.05
    
    var initWidthPerItem = CGFloat(0)
    var currentWidthPerItem = CGFloat(0)
    var currentMultiplier = CGFloat(1)
    
    let sectionInsets = UIEdgeInsets(top: 10, left: 20.0, bottom: 50.0, right: 20.0)
    let minItemsPerRow: CGFloat = 3
    let maxItemsPerRow: CGFloat = 1
    
    let reuseIdentifier = "NoteCell"
    var isEditingState = false
    
    let dummyNotebook = DummyNotebook.init(withSize: 15)
    var fetchedResultsController: NSFetchedResultsController<NoteEntity>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        self.notesCollectionView.delegate = self
        self.notesCollectionView.dataSource = self
        
        self.notesCollectionView.register(UINib(nibName: "NoteCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        initWidthCellCalc()
        widthChangeSlider.addTarget(self, action: #selector(widthSliderChange), for: UIControlEvents.valueChanged)
        
        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(editButtonPressed(_:))
        
        let loadModelOperation = LoadModelOperation { context in
            DispatchQueue.main.async {
                let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(key: "uid", ascending: false)]
                request.fetchLimit = 100
                
                let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
                controller.managedObjectContext.mergePolicy = NSOverwriteMergePolicy
                //controller.delegate = self
                self.fetchedResultsController = controller
                self.updateUI()
                
                self.executeUpdateData();
            }
        }
        
        loadModelOperation.taskQOS = .cache
        Dispatcher.shared.addOperation(operation: loadModelOperation)
            
//        NotesManager.shared.updateCache { error in
//            if let error = error {
//                print("Can't update notes on start \(error)")
//            }
//            DispatchQueue.main.async {
//                self.notesCollectionView.reloadData()
//            }
//        }
    }
    
    func executeUpdateData() {
        NotesManager.shared.updateCache(context: (fetchedResultsController?.managedObjectContext)!) { error in
            if let error = error {
                print("Can't update notes \(error)")
            }
            DispatchQueue.main.async {
                self.updateUI()
            }
        }
    }
    
    func updateUI() {
        do {
            try fetchedResultsController?.performFetch()
        }
        catch {
            print("Error in the fetched results controller: \(error).")
        }
        
        notesCollectionView.reloadData()
    }
    
    func calcCellSizes(withSize size: CGSize) -> (maxMultiplier: CGFloat, minWidthPerItem: CGFloat) {
        let minPaddingSpace = sectionInsets.left * (minItemsPerRow + 1)
        let minAvailableWidth = size.width - minPaddingSpace
        
        let maxPaddingSpace = sectionInsets.left * (maxItemsPerRow + 1)
        let maxAvailableWidth = size.width - maxPaddingSpace
        
        let minWidthPerItem = minAvailableWidth / minItemsPerRow
        let maxWidthPerItem = maxAvailableWidth / maxItemsPerRow
        
        let maxMultiplier = maxWidthPerItem / minWidthPerItem
        
        return (maxMultiplier, minWidthPerItem)
    }
    
    func initWidthCellCalc() {
        let (maxMultiplier, minWidthPerItem) = calcCellSizes(withSize: view.frame.size)
        
        initWidthPerItem = minWidthPerItem
        currentWidthPerItem = initWidthPerItem * round(((maxMultiplier + 1) / 2) / step) * step
        currentMultiplier = CGFloat(Float(round((CGFloat(maxMultiplier + 1) / 2) / step)) * Float(step))
        
        widthChangeSlider.minimumValue = 1
        widthChangeSlider.maximumValue = Float(maxMultiplier)
        widthChangeSlider.value = Float(currentMultiplier)
    }
    
    func recalcCell() {
        let (maxMultiplier, minWidthPerItem) = calcCellSizes(withSize: view.frame.size)
        
        let currentPercentMultiplier = currentMultiplier / CGFloat(widthChangeSlider.maximumValue)
        currentMultiplier = (maxMultiplier) * CGFloat(currentPercentMultiplier)
        currentMultiplier = CGFloat(round(Float(currentMultiplier) / Float(step)) * Float(step))
        
        initWidthPerItem = minWidthPerItem
        currentWidthPerItem = initWidthPerItem * currentMultiplier
        
        widthChangeSlider.minimumValue = 1
        widthChangeSlider.maximumValue = Float(maxMultiplier)
        widthChangeSlider.value = Float(currentMultiplier)
    }
    
    func editButtonPressed(_ sender: UIBarButtonItem) {
        isEditingState = !isEditingState
        
        let newButton = UIBarButtonItem(barButtonSystemItem: (isEditingState) ? .done : .edit, target: self, action: #selector(editButtonPressed(_:)))
        navigationItem.setLeftBarButton(newButton, animated: true)
        
        notesCollectionView.visibleCells.forEach {cell in
            let myCell = cell as! NoteCollectionViewCell
            myCell.editing = isEditingState
        }
        
        notesCollectionView.performBatchUpdates({}, completion: nil)
    }
    
    func widthSliderChange(_ sender: UISlider) {
        let roundedValue = round(sender.value / Float(step)) * Float(step)
        sender.value = roundedValue
        
        currentWidthPerItem = initWidthPerItem * CGFloat(sender.value)
        currentMultiplier = CGFloat(sender.value)
        
        notesCollectionView.visibleCells.forEach {cell in
            let myCell = cell as! NoteCollectionViewCell
            myCell.editParanja.setNeedsDisplay()
        }
        
        notesCollectionView.performBatchUpdates({}, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        recalcCell()
        notesCollectionView.collectionViewLayout.invalidateLayout()
        notesCollectionView.performBatchUpdates({}, completion: nil)
        
        notesCollectionView.visibleCells.forEach {cell in
            let myCell = cell as! NoteCollectionViewCell
            myCell.editParanja.setNeedsDisplay()
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editNoteSegue" {
            let editNoteViewController = segue.destination as! EditNoteViewController
            let indexPath = sender as! IndexPath
            
            guard let noteEntity = fetchedResultsController?.object(at: indexPath) else {
                fatalError("No such note to edit \(indexPath)")
            }
            
//            guard let noteIndex = indexPath.last, let notes = NotesManager.shared.getCachedNotes() else {
//                fatalError("No such note to edit \(indexPath)")
//            }
//            
//            let note = notes[noteIndex]
            let note = NoteEntity.entityToNote(noteEntity: noteEntity)
            
            editNoteViewController.note = note
            
            let backItem = UIBarButtonItem()
            backItem.title = "Notes"
            navigationItem.backBarButtonItem = backItem
        } else if segue.identifier == "addNoteSegue" {
            print("addNoteSegue")
        }
    }
    
    
    // MARK: UICollectionViewDelegate
    
    /*
     // Uncomment this method to specify if the specified item should be highlighted during tracking
     override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment this method to specify if the specified item should be selected
     override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
     return true
     }
     */
    
    /*
     // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
     return false
     }
     
     override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
     
     }
     */
    @IBAction func retryButton(_ sender: Any) {
        executeUpdateData()
    }
    
    func getEditedNoteFrom(editNoteViewController: EditNoteViewController) -> Note? {
        if let editNoteView = editNoteViewController.editNoteView,
            let noteContent = editNoteView.noteTitle.text {

            var date: Date?
            if editNoteView.expireDateView.destroyDateSwitch.isOn {
                date = editNoteView.expireDateView.destroyDatePicker.date
            }
            
            if let uid = editNoteViewController.note?.uid {
                return Note(title: noteContent, content: editNoteView.noteText.text, color: editNoteView.colorPickerPreview.currentColor, uid: uid, expireDate: date)
            } else {
                return Note(title: noteContent, content: editNoteView.noteText.text, color: editNoteView.colorPickerPreview.currentColor, expireDate: date)
            }
        } else {
            return nil
        }
    }
    
    @IBAction func unwindToMenu(_ segue: UIStoryboardSegue) {
        if segue.identifier == "saveButton" {
            let editNoteViewController = segue.source as! EditNoteViewController
            if let editedNote = getEditedNoteFrom(editNoteViewController: editNoteViewController) {
                // Так отличаем новую от редактируемой
                if editNoteViewController.note == nil {
                    NotesManager.shared.addNote(context: (fetchedResultsController?.managedObjectContext)!, note: editedNote) { error in
                        if let error = error {
                            print("Can't add new note \(error)")
                        }
                        DispatchQueue.main.async {
                            self.updateUI()
//                            print(NotesManager.shared.getCachedNotes())
//                            self.notesCollectionView.reloadData()
                        }
                    }
                    return
                }
                NotesManager.shared.editNote(context: (fetchedResultsController?.managedObjectContext)!, note: editedNote) { error in
                    if let error = error {
                        print("Can't edit note \(error)")
                    }
                    DispatchQueue.main.async {
                        self.updateUI()
//                        print(NotesManager.shared.getCachedNotes())
//                        self.notesCollectionView.reloadData()
                    }
                }
            }
        }
    }
}
