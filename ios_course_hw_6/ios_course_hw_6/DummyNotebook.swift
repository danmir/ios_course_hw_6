//
//  DummyNotebook.swift
//  ios_course_hw_5
//
//  Created by Danil Mironov on 09.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation

class DummyNotebook {
    private(set) var notesCollection: [Note] = []
    
    init(withSize size: Int) {
        for _ in 0..<size {
            let titleLen = randomInt(min: 5, max: 15)
            let contentLen = randomInt(min: 10, max: 60)
            self.addNote(note: Note.generateNote(withTitleLen: titleLen, contentLen: contentLen))
        }
    }
    
    init(notesCollection: [Note]) {
        for note in notesCollection {
            self.addNote(note: note)
        }
    }
    
    init?(fileName: String) {
        do {
            let docsurl = try FileManager.default.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let url = docsurl.appendingPathComponent(fileName)
            do {
                let data = try Data(contentsOf: url)
                let jsonResult = try JSONSerialization.jsonObject(with: data)
                if let jsonResult = jsonResult as? [[String: Any]] {
                    for note in jsonResult {
                        if let note = Note.parse(json: note) {
                            self.addNote(note: note)
                        }
                    }
                }
            } catch {
                print("Unable to parse \(fileName)");
                return nil
            }
        } catch {
            print("Unable to open \(fileName)")
            return nil
        }
    }
    
    func addNote(note: Note) {
        notesCollection.append(note)
        if let expireDate = note.expireDate {
            let deadline = expireDate.timeIntervalSinceNow < 0 ? 0 : expireDate.timeIntervalSinceNow
            DispatchQueue.main.asyncAfter(deadline: .now() + deadline, execute: {
                self.removeNote(byUid: note.uid)
            })
            //            DispatchQueue.main.asyncAfter(deadline: .now() + deadline, execute: { [weak self] in
            //                if let sself = self {
            //                    sself.removeNote(byUid: note.uid)
            //                }
            //            })
        }
    }
    
    func removeNote(byUid uid: String) {
        notesCollection = notesCollection.filter() {$0.uid != uid}
    }
    
    func writeToFile(fileName: String) throws {
        guard let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            else {
                throw DummyNotebookError.WriteToFileError
        }
        
        let path = dir.appendingPathComponent(fileName)
        var preJsonCollection: [[String: Any]] = []
        for note in notesCollection {
            preJsonCollection.append(note.json)
        }
        
        let jsonData = try JSONSerialization.data(withJSONObject: preJsonCollection, options: JSONSerialization.WritingOptions.prettyPrinted)
        try jsonData.write(to: path)
    }
}

