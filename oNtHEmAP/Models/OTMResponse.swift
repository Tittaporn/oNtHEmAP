//
//  OTMResponse.swift
//  oNtHEmAP
//
//  Created by Tittaporn Saelee  on 11/18/20.
//

import Foundation
import UIKit

struct OTMResponse: Codable {
    let statusCode: Int
    let statusMessage: String
    
    enum CodingKeys: String, CodingKey {
        case statusCode = "status_code"
        case statusMessage = "status_message"
    }
}

extension OTMResponse: LocalizedError {
    var errorDescription: String? {
        return statusMessage
    }
}
