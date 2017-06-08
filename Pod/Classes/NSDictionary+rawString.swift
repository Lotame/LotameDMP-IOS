//
//  NSDictionary+rawString.swift
//  Pods
//
//  Created by Robert Chen on 5/24/17.
//
//

import Foundation

extension NSDictionary {
    open func rawString() -> String? {
        var jsonDataOptional: Data?
        do {
            jsonDataOptional = try JSONSerialization.data(withJSONObject: self, options: .prettyPrinted)
        } catch {
            return nil
        }
        guard let jsonData = jsonDataOptional else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
}
