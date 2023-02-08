//
//  searchStudents.swift
//  swifty-companion
//
//  Created by Arthur Tainmont on 08/02/2023.
//

import Foundation
import SwiftyJSON

func searchStudent(searchInput: String) -> JSON? {
    if let user = API42.http_get("/v2/users/\(searchInput)") {
        if user.isEmpty {
            return nil
        }
        return user
    } else {
        return nil
    }
}
