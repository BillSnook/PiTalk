//
//  Contact.swift
//  YellAt
//
//  Created by William Snook on 1/12/17.
//  Copyright © 2017 billsnook. All rights reserved.
//

import Foundation
import Intents


struct Contact {
    
    var name: String
    var nickName: String
    
    var favorite: Bool
    
    func inPerson() -> INPerson {
        
        let handle = INPersonHandle( value: nickName, type: .unknown )
        return INPerson( personHandle: handle, nameComponents: nil, displayName: name, image: nil, contactIdentifier: nickName, customIdentifier: nil )
    }
}
