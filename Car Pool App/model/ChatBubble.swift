//
//  ChatBubble.swift
//  Car Pool App
//
//  Created by Swapnil Patel on 11/7/22.
//

import Foundation
import FirebaseFirestore

struct ChatBubble{
    var message: String
    var at: Timestamp
    var from: String
    
    init(message: String, at: Timestamp, from: String) {
        self.message = message
        self.at = at
        self.from = from
    }
    
    init(dictionary: NSDictionary){
        self.from = (dictionary["from"] as? String ?? "")
        self.at = (dictionary["at"] as! Timestamp)
        self.message = (dictionary["message"] as? String ?? "")
    }
    
    func toDictionary()-> NSDictionary{
        return ["at":self.at,"from":self.from,"message":self.message]
    }
}
