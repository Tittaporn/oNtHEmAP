//
//  UserInfo.swift
//  oNtHEmAP
//
//  Created by Tittaporn Saelee  on 11/21/20.
//

import Foundation
class UserInfo {
    static var user: User? = nil
    static var currentLocationId: String = ""
    static var studentLocations = [StudentLocation]()
    
    class func reset()
    {
        UserInfo.user?.firstName = ""
        UserInfo.user?.lastName = ""
        UserInfo.user?.userKey = ""
        currentLocationId = ""
    }
}

struct User : Codable
{
    var lastName:String
    var firstName:String
    var userKey:String
    
    enum CodingKeys : String, CodingKey
    {
        case lastName = "last_name"
        case firstName = "first_name"
        case userKey = "key"
        
    }
}
