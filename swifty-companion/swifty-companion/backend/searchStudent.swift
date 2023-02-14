//
//  searchStudents.swift
//  swifty-companion
//
//  Created by Arthur Tainmont on 08/02/2023.
//

import Foundation
import SwiftyJSON

extension String {
    func containsWhitespaceAndNewlines() -> Bool {
        return rangeOfCharacter(from: .whitespacesAndNewlines) != nil
    }
}

func containsSpecialCharacters(searchTerm: String) -> Bool {
    let characterset = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
    if searchTerm.rangeOfCharacter(from: characterset.inverted) != nil {
        return true
    }
    return false
}

func searchStudent(searchInput: String) -> JSON? {
    if searchInput.containsWhitespaceAndNewlines() ||
                containsSpecialCharacters(searchTerm: searchInput) ||
                searchInput.count == 0 {
        return nil
    }
    if var user = API42.http_get("/v2/users/\(searchInput)") {
        if user.isEmpty {
            return nil
        }
        if let events = API42.http_get("/v2/users/\(searchInput)/events") {
            user["events"] = events
            return user
        } else {
            return nil
        }
    } else {
        return nil
    }
}
