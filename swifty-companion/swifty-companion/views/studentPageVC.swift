//
//  studentPageVC.swift
//  swifty-companion
//
//  Created by Arthur Tainmont on 09/02/2023.
//

import UIKit
import SwiftyJSON

class studentPageVC: UIViewController {
    
    var student: JSON!
    var cursus: (index: Int, id: Int) = (1, 21)  // c-piscine = 0,9

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(student["login"])
        print(student["usual_full_name"])
        print(student["cursus_users"][cursus.index]["level"])
        print(student["email"])
        print(student["image"]["versions"]["small"])
        print(student["correction_point"])
        print(student["wallet"])
        print("Past projects")
        for (_,project) in student["projects_users"]
                where project["final_mark"].stringValue != "" &&
                project["cursus_ids"][0].intValue == cursus.id {
            print("")
            print(project["project"]["slug"])
            print(project["final_mark"])
        }
        print("Projects in progress")
        for (_,project) in student["projects_users"]
                where project["final_mark"].stringValue == "" &&
                project["cursus_ids"][0].intValue == cursus.id {
            print("")
            print(project["project"]["name"])
        }
        print("Skills")
        for (_,skill) in student["cursus_users"][cursus.index]["skills"] {
            print("")
            print(skill["name"])
            print(skill["level"])
        }
        
    }

}
