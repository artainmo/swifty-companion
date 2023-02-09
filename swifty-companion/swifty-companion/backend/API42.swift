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
        let UID = "u-s4t2ud-c3ba1c99b2d4dbd9d7b2b1b4f98d08db7efa34343f91cd069719b00af472ae5d"
        let secret = "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"
        
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
        //print(unixtime)
        //print(creationTime)
        //print((unixtime - creationTime))
        //print(lifeTimeWithMargin)
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
