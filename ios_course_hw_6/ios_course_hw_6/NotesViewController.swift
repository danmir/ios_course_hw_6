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
    
    var dataFetchRequested = false
    let oauthViewController = OauthViewController()
    
    let tmpContext = CoreDataManager.instance.managedObjectContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        self.notesCollectionView.delegate = self
        self.notesCollectionView.dataSource = self
        
        self.oauthViewController.delegate = self
        
        self.notesCollectionView.register(UINib(nibName: "NoteCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        
        initWidthCellCalc()
        widthChangeSlider.addTarget(self, action: #selector(widthSliderChange), for: UIControlEvents.valueChanged)
        
        navigationItem.leftBarButtonItem?.target = self
        navigationItem.leftBarButtonItem?.action = #selector(editButtonPressed(_:))
        
//        let loadModelOperation = LoadModelOperation { context in
//            DispatchQueue.main.async {
//                let request: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
//                request.sortDescriptors = [NSSortDescriptor(key: "uid", ascending: false)]
//                request.fetchLimit = 100
//                
//                let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
//                controller.managedObjectContext.mergePolicy = NSOverwriteMergePolicy
//                //controller.delegate = self
//                self.fetchedResultsController = controller
//                self.updateUI()
//                
//                //self.executeUpdateData()
//                self.dataFetchRequested = true
//                let isOauth = self.updateOauthTokenRequest()
//                if isOauth {
//                    self.executeUpdateData()
//                }
//            }
//        }
//        
//        loadModelOperation.taskQOS = .cache
//        Dispatcher.shared.addOperation(operation: loadModelOperation)
        
        DispatchQueue.main.async {
            self.updateUI()
            
            self.dataFetchRequested = true
            let isOauth = self.updateOauthTokenRequest()
            if isOauth {
                self.executeUpdateData()
            }
        }
        
//        NotesManager.shared.updateCache { error in
//            if let error = error {
//                print("Can't update notes on start \(error)")
//            }
//            DispatchQueue.main.async {
//                self.notesCollectionView.reloadData()
//            }
//        }
    }
    
    func noTokenAlert() {
        let alert = UIAlertController(title: "Oauth token", message: "Не удалось получить Oauth token. Нажмите 'Auth' чтобы попытаться еще раз", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Хорошо", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func updateOauthTokenRequest() -> Bool {
        let defaults = UserDefaults.standard
        guard let token = defaults.string(forKey: "token") else {
            present(oauthViewController, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func executeUpdateData() {
        NotesManager.shared.updateCache { error in
            if let error = error {
                print("Can't update notes \(error)")
            }
            DispatchQueue.main.async {
                self.updateUI()
            }
        }
    }
    
    func updateUI() {
        Store.instance.performFetch()
//        do {
//            try fetchedResultsController?.performFetch()
//        }
//        catch {
//            print("Error in the fetched results controller: \(error).")
//        }
//        
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
        let isToken = updateOauthTokenRequest()
        if !isToken {
            noTokenAlert()
            return
        }
        
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
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        let isToken = updateOauthTokenRequest()
        if !isToken {
            noTokenAlert()
            return false
        }
        
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editNoteSegue" {
            let editNoteViewController = segue.destination as! EditNoteViewController
            
            let indexPath = sender as! IndexPath
            let noteIndex = indexPath.last!
            
            guard let note = Store.instance.notesCache?[noteIndex] else {
                fatalError("No such note to edit \(indexPath)")
            }
            
//            guard let noteEntity = fetchedResultsController?.object(at: indexPath) else {
//                fatalError("No such note to edit \(indexPath)")
//            }
            
//            guard let noteIndex = indexPath.last, let notes = NotesManager.shared.getCachedNotes() else {
//                fatalError("No such note to edit \(indexPath)")
//            }
//            
//            let note = notes[noteIndex]
           // let note = NoteEntity.entityToNote(noteEntity: noteEntity)
            
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
        dataFetchRequested = true
        let isOauth = updateOauthTokenRequest()
        if isOauth {
            executeUpdateData()
        }
    }

    @IBAction func authButton(_ sender: Any) {
        updateOauthTokenRequest()
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
                    NotesManager.shared.addNote(note: editedNote) { error in
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
                NotesManager.shared.editNote(note: editedNote) { error in
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
