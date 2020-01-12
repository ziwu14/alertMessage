//
//  Utilities.swift
//  AlertMessage
//
//  Created by ZIHAO WU on 11/10/19.
//  Copyright © 2019 ZIHAO WU. All rights reserved.
//

import Foundation
import Firebase

// Extension of NSRegularExpression
// convenience initializer that either creates a regex correctly or creates an assertion failure
extension NSRegularExpression {
    convenience init(_ pattern: String) {
        do {
            try self.init(pattern: pattern)
        } catch {
            preconditionFailure("Illegal regular expression: \(pattern).")
        }
    }
}



// match method
extension NSRegularExpression {
    func matches(_ string: String) -> Bool {
        let range = NSRange(location: 0, length: string.utf16.count)
        return firstMatch(in: string, options: [], range: range) != nil
    }
}

class Utility {
    static func sendEmailToFriend(victim: String,
                   victimEmail: String,
                   friend: String,
                   friendEmail: String) {
        let smtpSession = MCOSMTPSession()
        smtpSession.hostname = "smtp.gmail.com"
        smtpSession.username = "ece590.03@gmail.com"
        smtpSession.password = "Qwert12345!"
        smtpSession.port = 465
        smtpSession.authType = MCOAuthType.saslPlain
        smtpSession.connectionType = MCOConnectionType.TLS
        smtpSession.connectionLogger = {(connectionID, type, data) in
            if data != nil {
                if let string = NSString(data: data!, encoding: String.Encoding.utf8.rawValue){
                    NSLog("Connectionlogger: \(string)")
                }
            }
        }
        let builder = MCOMessageBuilder()
        builder.header.to = [MCOAddress(displayName: friend, mailbox: friendEmail)]
        builder.header.from = MCOAddress(displayName: "alertMessage", mailbox: "ece590.03@gmail.com")
        builder.header.subject = "Test Email"
        builder.htmlBody="<p>Your friend \(victim) (email: \(victimEmail) was under emergent </p>"
        
        
        let rfc822Data = builder.data()
        let sendOperation = smtpSession.sendOperation(with: rfc822Data)
        sendOperation?.start { (error) -> Void in
            if (error != nil) {
                NSLog("-----------[Error] sending email: \(error)--------------")
                
                
            } else {
                NSLog("-----------[Success] sent email!------------------------")
            }
        }
    }
}




