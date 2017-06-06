//
//  NotesViewController+OauthViewControllerProtocol.swift
//  ios_course_hw_6
//
//  Created by Danil Mironov on 06.06.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import Foundation
import UIKit

extension NotesViewController: OauthViewControllerProtocol {
    func setOauthToken(token: String?) {
        if let token = token {
            let defaults = UserDefaults.standard
            defaults.set(token, forKey: "token")
            
            if dataFetchRequested {
                self.executeUpdateData()
                dataFetchRequested = false
            }
        } else {
            let alert = UIAlertController(title: "Oauth token", message: "Не удалось получить Oauth token. Нажмите 'Auth' чтобы попытаться еще раз", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Хорошо", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
