//
//  LoginRequest.swift
//  oNtHEmAP
//
//  Created by Tittaporn Saelee  on 11/21/20.
//

import Foundation
struct LoginRequest : Codable
{
    let udacity:[String:String]
    
    enum CodingKeys : String, CodingKey
    {
        case udacity
    }
}
