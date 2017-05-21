//
//  FetchCacheOperation.swift
//  ios_course_hw_6
//
//  Created by Danil Mironov on 18.05.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation

class FetachCacheOperation: AsyncOperation {
    let loadHandler: (Void) -> Void
    
    init(loadHandler: @escaping (Void) -> Void) {
        self.loadHandler = loadHandler
        super.init()
    }
    
    override func main() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let sself = self else { return }
            print("FetachCacheOperation")
            
            sself.loadHandler()
            sself.finish()
        }
    }
}
