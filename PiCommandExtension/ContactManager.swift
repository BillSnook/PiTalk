//
//  ContactManager.swift
//  YellAt
//
//  Created by William Snook on 1/12/17.
//  Copyright © 2017 billsnook. All rights reserved.
//

import Foundation

struct ContactManager {
    
    static let allContacts = [Contact(name: "Sylvia", nickName: "zerowpi2", favorite: false),
                       Contact(name: "Mars", nickName: "zerowpi2", favorite: false),
                       Contact(name: "Zero", nickName: "zerowpi2", favorite: false),
                       Contact(name: "Venus", nickName: "zerowpi2", favorite: false)]
    
    static func matching( _ name: String ) -> Array<Contact> {
        
        var matches = [Contact]()
        for contact in allContacts {
            if contact.name.contains( name ) {
                matches.append( contact )
            }
        }
        return matches
    }
    
}
