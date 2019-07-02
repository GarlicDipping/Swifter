//
//  AuthViewController.swift
//  SwifterDemoiOS
//
//  Copyright (c) 2014 Matt Donnelly.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit
import Accounts
import Social
import SwifteriOS
import SafariServices

class AuthViewController: UIViewController {
    
    var swifter: Swifter
    
    // Default to using the iOS account framework for handling twitter auth
    let useACAccount = false
    
    required init?(coder aDecoder: NSCoder) {
        self.swifter = Swifter(consumerKey: "nLl1mNYc25avPPF4oIzMyQzft",
                               consumerSecret: "Qm3e5JTXDhbbLl44cq6WdK00tSUwa17tWlO8Bf70douE4dcJe2")
        super.init(coder: aDecoder)
    }
    
    @IBAction func didTouchUpInsideLoginButton(_ sender: AnyObject) {
        self.OnClickLoginButton(swifter: swifter)
    }
    
    public func OnClickLoginButton(swifter:Swifter) {
        let failureHandler: (Error) -> Void = { error in
            print("Error!:\(error)")
            self.alert(title: "Error", message: error.localizedDescription)
        }
        
        let url = URL(string: "swifter://success")!
        swifter.authorize_cancellable(withCallback: url, presentingFrom: self, forceLogin: false, success: { accessToken, _ in
            self.alert(title:"authorized", message:"AccessToken:\(accessToken!.key), AccessTokenSecret:\(accessToken!.secret)")
        }, failure: failureHandler)
        /*swifter.authorize(withCallback: url, presentingFrom: self, safariDelegate: self.safariViewDelegate, success: { accessToken, _ in
            self.alert(title:"authorized", message:"AccessToken:\(accessToken!.key), AccessTokenSecret:\(accessToken!.secret)")
        }, failure: failureHandler)*/
    }
    
    func alert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
