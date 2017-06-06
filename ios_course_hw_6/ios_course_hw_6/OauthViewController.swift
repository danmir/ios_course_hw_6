//
//  OauthViewController.swift
//  ios_course_hw_6
//
//  Created by Danil Mironov on 06.06.17.
//  Copyright © 2017 Danil Mironov. All rights reserved.
//

import UIKit

extension NSRange {
    func range(for str: String) -> Range<String.Index>? {
        guard location != NSNotFound else { return nil }
        
        guard let fromUTFIndex = str.utf16.index(str.utf16.startIndex, offsetBy: location, limitedBy: str.utf16.endIndex) else { return nil }
        guard let toUTFIndex = str.utf16.index(fromUTFIndex, offsetBy: length, limitedBy: str.utf16.endIndex) else { return nil }
        guard let fromIndex = String.Index(fromUTFIndex, within: str) else { return nil }
        guard let toIndex = String.Index(toUTFIndex, within: str) else { return nil }
        
        return fromIndex ..< toIndex
    }
}

protocol OauthViewControllerProtocol {
    func setOauthToken(token: String?)
}

class OauthViewController: UIViewController, UIWebViewDelegate {
    @IBOutlet weak var webView: UIWebView!
    
    var token: String?
    var delegate: OauthViewControllerProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.delegate = self
        let url = URL(string: "https://oauth.yandex.ru/authorize?response_type=token&client_id=0d0970774e284fa8ba9ff70b6b06479a")
        webView.loadRequest(URLRequest(url: url!))
        
    }
    
    func gotUserToken(token: String) {
        self.token = token
        self.dismiss(animated: true) {
            self.delegate?.setOauthToken(token: self.token)
        }
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if let text = webView.request?.url?.absoluteString {
            let pat = ".*access_token=(.*?)&token_type.*"
            let regex = try! NSRegularExpression(pattern: pat, options: [])
            let matches = regex.matches(in: text, options: [], range: NSRange(location: 0, length: text.characters.count))
            if let match = matches.first {
                if let range = match.rangeAt(1).range(for: text) {
                    let token = text.substring(with: range)
                    print(token)
                    gotUserToken(token: token)
                }
            }
        }
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        self.dismiss(animated: true) {
            self.delegate?.setOauthToken(token: self.token)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
