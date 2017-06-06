//
//  NotesCollectionViewController+DataSource.swift
//  ios_course_hw_5
//
//  Created by Danil Mironov on 09.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import UIKit
import CoreData

extension NotesViewController: UICollectionViewDataSource {
    // MARK: UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
//        return fetchedResultsController?.sections?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        guard let notes = NotesManager.shared.getCachedNotes() else { return 0 }
//        return notes.count
        
        return Store.instance.notesCache?.count ?? 0
        
//        let section = fetchedResultsController?.sections?[section]
//        return section?.numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NoteCollectionViewCell
        
        guard let noteIndex = indexPath.last else {
            cell.noteText.text = "Dummy text"
            cell.noteTitle.text = "Dummy title"
            return cell
        }
        
        guard let note = Store.instance.notesCache?[noteIndex] else {
            print("No such cell in cache")
            cell.noteText.text = "Dummy text"
            cell.noteTitle.text = "Dummy title"
            return cell
        }
        
//        guard let noteEntity = fetchedResultsController?.object(at: indexPath) else {
//            cell.noteText.text = "Dummy text"
//            cell.noteTitle.text = "Dummy title"
//            cell.colorTriangle.color = UIColor.white
//            return cell
//        }
        
        cell.noteText.text = note.content
        cell.noteTitle.text = note.title
        cell.colorTriangle.color = note.color
        
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
            guard let noteIndex = indexPath.last, let note = Store.instance.notesCache?[noteIndex] else {
                print("No such index in cache")
                return
            }
            
            //let noteEntity = fetchedResultsController?.object(at: indexPath)
            //let note = NoteEntity.entityToNote(noteEntity: noteEntity)
            
            
            //let note = NotesManager.shared.getCachedNotes()![indexPath[1]]
            NotesManager.shared.deleteNote(note: note) { error in
                if let error = error {
                    print("Can't delete note \(error)")
                } else {
                    DispatchQueue.main.async {
                        Store.instance.notesCache?.remove(at: noteIndex)
                        let context = CoreDataManager.instance.getBackgroundContext()
                        let pred = NSPredicate(format: "uid == %@", note.uid)
                        let sort = NSSortDescriptor(key: "uid", ascending: true)
                        
                        let req: NSFetchRequest<NoteEntity> = NoteEntity.fetchRequest()
                        req.predicate = pred
                        req.sortDescriptors = [sort]
                        
                        do {
                            let res = try context.fetch(req)
                            print("Res to delete \(res)")
                            if let noteEntity = res.first {
                                context.delete(noteEntity)
                            } else {
                                print("Nothing to delete")
                            }
                        } catch {
                            
                        }
                        
                        //self.fetchedResultsController?.managedObjectContext.delete(noteEntity!)
                        do {
                            //try self.fetchedResultsController?.managedObjectContext.save()
                            try context.save()
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
