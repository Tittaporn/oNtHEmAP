//
//  LoginError.swift
//  oNtHEmAP
//
//  Created by Tittaporn Saelee  on 11/21/20.
//

import Foundation
struct LoginError : Error, Codable
{
    let status:Int
    let error:String
    
    enum CodingKeys:String,CodingKey
    {
        case status
        case error
    }
}

extension LoginError : LocalizedError
{
    var errorDescription: String?
    {
        return error
    }
}
