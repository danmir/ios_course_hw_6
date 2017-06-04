//
//  NotesCollectionViewController+DataSource.swift
//  ios_course_hw_5
//
//  Created by Danil Mironov on 09.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import UIKit


extension NotesViewController: UICollectionViewDataSource {
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1
        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        guard let notes = NotesManager.shared.getCachedNotes() else { return 0 }
//        return notes.count
        
        let section = fetchedResultsController?.sections?[section]
        return section?.numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NoteCollectionViewCell
        
        guard let noteEntity = fetchedResultsController?.object(at: indexPath) else {
            cell.noteText.text = "Dummy text"
            cell.noteTitle.text = "Dummy title"
            cell.colorTriangle.color = UIColor.white
            return cell
        }
        
        cell.noteText.text = noteEntity.content
        cell.noteTitle.text = noteEntity.title
        cell.colorTriangle.color = UIColor(hexString: noteEntity.color!)!
//        guard let noteIndex = indexPath.last, let notes = NotesManager.shared.getCachedNotes() else {
//            cell.noteText.text = "Dummy text"
//            cell.noteTitle.text = "Dummy title"
//            return cell
//        }
        
//        let note = notes[noteIndex]
//        
//        cell.noteText.text = note.content
//        cell.noteTitle.text = note.title
//        cell.colorTriangle.color = note.color
        
        if isEditingState {
            cell.editing = true
        } else {
            cell.editing = false
        }
        
        cell.editParanja.setNeedsDisplay()
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isEditingState {
            let noteEntity = fetchedResultsController?.object(at: indexPath)
            let note = NoteEntity.entityToNote(noteEntity: noteEntity!)
            
            
            //let note = NotesManager.shared.getCachedNotes()![indexPath[1]]
            NotesManager.shared.deleteNote(context: (fetchedResultsController?.managedObjectContext)!, note: note) { error in
                if let error = error {
                    print("Can't delete note \(error)")
                } else {
                    DispatchQueue.main.async {
                        self.fetchedResultsController?.managedObjectContext.delete(noteEntity!)
                        do {
                            try self.fetchedResultsController?.managedObjectContext.save()
                        } catch let error as NSError  {
                            print("Could not save \(error), \(error.userInfo)")
                        }
                        self.updateUI()
//                        self.notesCollectionView.deleteItems(at: [indexPath])
//                        self.notesCollectionView.reloadData()
                    }
                }
            }
        } else {
            performSegue(withIdentifier: "editNoteSegue", sender: indexPath)
        }
    }
}
