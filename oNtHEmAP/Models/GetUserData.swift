//
//  GetUserData.swift
//  oNtHEmAP
//
//  Created by Tittaporn Saelee  on 11/18/20.
//

import Foundation
struct GetUserData: Codable {
    let lastName: String
    let firstName: String
    let key: String
    
    enum CodingKeys : String, CodingKey {
        case lastName = "last_name"
        case firstName = "first_name"
        case key
    }
}
