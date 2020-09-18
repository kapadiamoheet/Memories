//
//  Response.swift
//  SafeAndOpen
//

import Foundation

protocol APIResponse {
/**
     Use this for adding common properties to web service resonse eg.
     var status:Int? { get set }
*/
}

struct ServiceResponse<T:Decodable>: Decodable, APIResponse {
   var data: T?
    
    enum CodingKeys: String, CodingKey {
        case status
        case errorCode
        case errorLine
        case message
        case data
        case versionErrorCode
        case versionErrorLine
        case versionMessage
        case isUnderMaintenance
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        do {
            self.data = try container.decode(T.self, forKey: .data)
        } catch let error {
            print("Unable to parse data model Error -: \(error)")
        }
    }
}
