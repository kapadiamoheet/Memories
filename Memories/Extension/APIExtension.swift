//
//  APIExtension.swift
//  Memories
//
//  Created by Mohit Kapadia on 17/09/20.
//  Copyright © 2020 Mohit Kapadia. All rights reserved.
//

import Foundation

extension Dictionary {
    var jsonData: Data? {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
            let jsonStr = String(bytes: jsonData, encoding: String.Encoding.utf8)
            return jsonStr?.data(using: .utf8)
        } catch {
            return nil
        }
    }
}
