//
//  SwifterSwiftUnityWrapper.swift
//  Swifter-Unity
//
//  Created by TeamTapas on 21/11/2018.
//  Copyright © 2018 TeamTapas. All rights reserved.
//

import Foundation
import UIKit

public typealias LoginSuccessCallback = (NSString, NSString, NSString) -> Swift.Void
public typealias LoginFailCallback = (NSString) -> Swift.Void

@objc public class SwifterLoginWrapper : NSObject {
    var swifter:Swifter?
    var consumerKeyCached:String?
    @objc public func Initialize(consumerKey:NSString, consumerSecret:NSString, appOnly:Bool = false)
    {
        let _consumerKey = self.NSStringToString(nsString:consumerKey)
        self.consumerKeyCached = _consumerKey
        let _consumerSecret = self.NSStringToString(nsString:consumerSecret)
        self.swifter = Swifter(consumerKey: _consumerKey, consumerSecret: _consumerSecret, appOnly:appOnly)
    }
    
    @objc public func Initialize(consumerKey:NSString, consumerSecret:NSString, oauthToken:NSString, oauthTokenSecret:NSString)
    {
        let _consumerKey = self.NSStringToString(nsString:consumerKey)
        let _consumerSecret = self.NSStringToString(nsString:consumerSecret)
        let _oauthToken = self.NSStringToString(nsString:oauthToken)
        let _oauthTokenSecret = self.NSStringToString(nsString:oauthTokenSecret)
        self.swifter = Swifter(consumerKey: _consumerKey, consumerSecret: _consumerSecret,
                               oauthToken: _oauthToken, oauthTokenSecret: _oauthTokenSecret)
    }
    
    @objc public func Login(caller:UIViewController, callback_success:LoginSuccessCallback?, callback_fail:LoginFailCallback?)
    {
        if self.swifter == nil {
            callback_fail!("Twitter Plugin Not Initialized!")
        }
        else {
            let failureHandler: (Error) -> Void = { error in
                print("Error!:\(error)")
                let NSErrorMSG = "Error:\(error.localizedDescription))" as NSString
                callback_fail!(NSErrorMSG)
            }
            let url = URL(string:"swifter-\(self.consumerKeyCached!)://success")!
            swifter!.authorize_cancellable(withCallback: url, presentingFrom: caller, success: { accessToken, _ in
                if accessToken == nil {
                    callback_fail!("AccessToken Empty!")
                    return
                }
                let NSAccessToken = accessToken!.key as NSString
                let NSAccessTokenSecret = accessToken!.secret as NSString
                var NSUserId = "" as NSString
                if accessToken!.userID != nil {
                    let userId = accessToken!.userID!
                    NSUserId = userId as NSString
                }
                callback_success!(NSAccessToken, NSAccessTokenSecret, NSUserId)
            }, failure: failureHandler)
        }
    }
    
    @objc public func HandleOpenURL(url:URL)
    {
        Swifter.handleOpenURL(url)
    }
    
    private func NSStringToString(nsString:NSString) -> String{
        let myNSData = nsString.data(using: String.Encoding.utf8.rawValue)!
        let myArray = [UInt8](myNSData)
        let resultNSData = NSData(bytes: myArray, length: myArray.count)
        let resultNSString = NSString(data: resultNSData as Data, encoding: String.Encoding.utf8.rawValue)!
        let resultString = resultNSString as String
        return resultString
    }
}
