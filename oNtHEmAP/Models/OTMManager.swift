//
//  OTMManager.swift
//  oNtHEmAP
//
//  Created by Lee McCormick on 11/26/20.
//

import Foundation
class OTMManager {
    static let otmManager = OTMManager()
    
    var userId: String!
    var objectId: String!
    var userData: GetUserData!
    var studentLocations = [StudentLocation]()
}
