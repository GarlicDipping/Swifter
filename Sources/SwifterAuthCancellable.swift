//
//  SwifterCancellableAuth.swift
//  SwifterDemoiOS
//
//  Created by TeamTapas on 02/07/2019.
//  Copyright © 2019 Matt Donnelly. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit
import SafariServices
#elseif os(macOS)
import AppKit
#endif

extension Notification.Name {
    static let swifterAuthCancelCallback = Notification.Name(rawValue: "Swifter.AuthCancelCallbackNotificationName")
}

public extension Swifter {
    
    class TwitterLoginSafariDelegate: NSObject, SFSafariViewControllerDelegate
    {
        @available(iOS 9.0, *)
        public func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
            Swifter.handleSafariViewDone()
            controller.dismiss(animated: true, completion: nil)
        }
    }
    
    /**
     Begin Authorization with a Callback URL
     
     - Parameter presentFromViewController: The viewController used to present the SFSafariViewController.
     The UIViewController must inherit SFSafariViewControllerDelegate
     
     */
    #if os(iOS)
    func authorize_cancellable(withCallback callbackURL: URL,
                               presentingFrom presenting: UIViewController?,
                               forceLogin: Bool = false,
                               success: TokenSuccessHandler?,
                               failure: FailureHandler? = nil) {
        resetObserver()
        
        //User Pressed 'Done' Button
        self.authCancelObserver = NotificationCenter.default.addObserver(forName: .swifterAuthCancelCallback, object: nil, queue: .main){notification in
            self.resetObserver()
            let error = SwifterError.init(message: "Authentication Cancelled!", kind: SwifterError.ErrorKind.AuthCancelled)
            failure?(error)
        }
        
        self.postOAuthRequestToken(with: callbackURL, success: { token, response in
            var requestToken = token!
            self.swifterCallbackToken = NotificationCenter.default.addObserver(forName: .swifterCallback, object: nil, queue: .main) { notification in
                self.swifterCallbackToken = nil
                presenting?.presentedViewController?.dismiss(animated: true, completion: nil)
                let url = notification.userInfo![CallbackNotification.optionsURLKey] as! URL
                
                let parameters = url.query!.queryStringParameters
                requestToken.verifier = parameters["oauth_verifier"]
                
                self.postOAuthAccessToken(with: requestToken, success: { accessToken, response in
                    self.client.credential = Credential(accessToken: accessToken!)
                    success?(accessToken!, response)
                }, failure: failure)
            }
            
            let forceLogin = forceLogin ? "&force_login=true" : ""
            let query = "oauth/authorize?oauth_token=\(token!.key)\(forceLogin)"
            let queryUrl = URL(string: query, relativeTo: TwitterURL.oauth.url)!
            let safariDelegate = TwitterLoginSafariDelegate()
            let safariView = SFSafariViewController(url: queryUrl)
            safariView.delegate = safariDelegate
            safariView.modalTransitionStyle = .coverVertical
            safariView.modalPresentationStyle = .overFullScreen
            presenting?.present(safariView, animated: true, completion: nil)
        }, failure: failure)
    }
    #endif
    
    class func handleSafariViewDone() {
        let notification = Notification(name: .swifterAuthCancelCallback, object: nil)
        NotificationCenter.default.post(notification)
    }
    
    private func resetObserver() {
        if(self.authCancelObserver != nil) {
            NotificationCenter.default.removeObserver(self.authCancelObserver!)
            self.authCancelObserver = nil
        }
    }
}
