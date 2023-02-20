//
//  42API.swift
//  swifty-companion
//
//  Created by Arthur Tainmont on 08/02/2023.
//

import Foundation
import SwiftyJSON

class API42Class {
    var token: [String: Any]? = nil
    
    func generate_token() {
        var UID: String = ""
        var secret: String = ""
        
        if let _UID = ProcessInfo.processInfo.environment["API_UID"] {
            UID = String(_UID)
        } else {
            print("Missing environment variable: API_UID")
            exit(0)
        }
        if let _secret = ProcessInfo.processInfo.environment["API_SECRET"] {
            secret = String(_secret)
        } else {
            print("Missing environment variable: API_SECRET")
            exit(0)
        }
        
        let queryParams = "?"
            + "grant_type=client_credentials&"
            + "client_id=\(UID)&"
            + "client_secret=\(secret)"
        let url = URL(string: "https://api.intra.42.fr/oauth/token" + queryParams)!
        var httpRequest = URLRequest(url: url)
        httpRequest.httpMethod = "POST"
        httpRequest.setValue("application/x-www-form-urlencoded",
                             forHTTPHeaderField: "Content-Type")
        
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: httpRequest,
                    completionHandler: {(data, response, error) in
            if error != nil {
                print("Error: error generating 42api token")
                return
            }
            if let datas = data {
                do {
                    if let json = try JSONSerialization.jsonObject(
                        with: datas, options: .mutableContainers)
                        as? [String: Any] {
                            self.token = json
                            print("token generated")
                         }
                } catch let error {
                        print("Error: " + error.localizedDescription)
                }
            } else {
                print("Error: no datas returned when trying to generate 42api token")
                return
            }
            semaphore.signal()
        })
        task.resume()
        semaphore.wait()
    }
    
    func recreate_token_if_expired() {
        let date = NSDate() // current date
        
        if token == nil {
            print("token does not exist yet")
            generate_token()
        }
        let unixtime = date.timeIntervalSince1970 as Double
        let creationTime = (token?["created_at"] as! Double)
        let lifeTimeWithMargin = ((token?["expires_in"] as! Double) + 100)
        print("Token creation time")
        print(creationTime)
        print("Now")
        print(unixtime)
        print("Now minus creationTime")
        print((unixtime - creationTime))
        print("Token total life time")
        print(lifeTimeWithMargin)
        if ((unixtime - creationTime) > lifeTimeWithMargin) {
            print("token expired regenerate")
            generate_token()
            return
        }
        print("token not expired")
    }
    
    func http_get(_ route: String) -> JSON? {
        recreate_token_if_expired()
        var result: JSON? = nil
        let url = URL(string: "https://api.intra.42.fr" + route)!
        var httpRequest = URLRequest(url: url)
        httpRequest.addValue("Bearer \(token?["access_token"] as! String)",
                             forHTTPHeaderField: "Authorization")
    
        let semaphore = DispatchSemaphore(value: 0)
        let task = URLSession.shared.dataTask(with: httpRequest,
                    completionHandler: {(data, response, error) in
            if error != nil {
                print("Error: error making 42api request")
                return
            }
            if let datas = data {
                result = JSON(datas)
            }
            semaphore.signal()
        })
        task.resume()
        semaphore.wait()
        return result
    }
}

let API42 = API42Class()
