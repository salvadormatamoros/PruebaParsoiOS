//
//  JSONUsers.swift
//  PruebaParsoiOS
//
//  Created by Innova Media on 26/03/2018.
//  Copyright © 2018 Parso. All rights reserved.
//

import UIKit

class JSONUserData
{
    var name: String = ""
    var email: String
    var picture: String
    
    init(name: String, email: String, picture: String) {
        self.name = name
        self.email = email
        self.picture = picture
    }
    
}
