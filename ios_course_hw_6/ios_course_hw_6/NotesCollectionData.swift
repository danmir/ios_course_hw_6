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
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let notes = NotesManager.shared.getCachedNotes() else { return 0 }
        return notes.count
        //return dummyNotebook.notesCollection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NoteCollectionViewCell
        
        guard let noteIndex = indexPath.last, let notes = NotesManager.shared.getCachedNotes() else {
            cell.noteText.text = "Dummy text"
            cell.noteTitle.text = "Dummy title"
            return cell
        }
        
        let note = notes[noteIndex]
        //let note = dummyNotebook.notesCollection[noteIndex]
        
        cell.noteText.text = note.content
        cell.noteTitle.text = note.title
        cell.colorTriangle.color = note.color
        
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
            let note = NotesManager.shared.getCachedNotes()![indexPath[1]]
            NotesManager.shared.deleteNote(note: note) { error in
                if let error = error {
                    print("Can't delete note \(error)")
                } else {
                    DispatchQueue.main.async {
                        self.notesCollectionView.deleteItems(at: [indexPath])
                        self.notesCollectionView.reloadData()
                    }
                }
            }
        } else {
            performSegue(withIdentifier: "editNoteSegue", sender: indexPath)
        }
    }
}
