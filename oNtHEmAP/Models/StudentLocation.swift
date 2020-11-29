//
//  StudentLocation.swift
//  oNtHEmAP
//
//  Created by Tittaporn Saelee  on 11/18/20.
//

import Foundation

struct StudentLocation: Codable {
    let objectId: String?
    let uniqueKey: String
    let firstName: String
    let lastName: String
    let mapString: String
    let mediaURL: String
    let latitude: Double
    let longitude: Double
    let createdAt: String?
    let updatedAt: String?
}

struct StudentInfoList {
    static var studentInfoList = [StudentLocation]()
}
