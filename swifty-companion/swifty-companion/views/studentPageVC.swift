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
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var loginLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var levelLabel: UILabel!
    @IBOutlet var emailLabel: UILabel!
    @IBOutlet var correctionPointsLabel: UILabel!
    @IBOutlet var walletLabel: UILabel!
    
    @IBOutlet var cursusSC: UISegmentedControl!
    
    @IBOutlet var pastProjectsTableView: UITableView!
    @IBOutlet var currentProjectsTableView: UITableView!
    @IBOutlet var skillsTableView: UITableView!
    @IBOutlet var eventsTableView: UITableView!

    override func viewDidLoad() {
        filterPastProjects()
        filterCurrentProjects()
        print_all()
        
        super.viewDidLoad()
        fetchImage(url: student["image"]["versions"]["small"].stringValue)
        
        loginLabel.text = "Login: " + student["login"].stringValue
        nameLabel.text = "Name: " + student["usual_full_name"].stringValue
        levelLabel.text = "Level: " +
            student["cursus_users"][cursus.index]["level"].stringValue[0..<4]
        emailLabel.text = "Email: " + student["email"].stringValue
        correctionPointsLabel.text = "Evaluation points: " +
            student["correction_point"].stringValue
        walletLabel.text = "Wallets: " + student["wallet"].stringValue
        
        cursusSC.setTitle("42cursus", forSegmentAt: 0)
        cursusSC.setTitle("C Piscine", forSegmentAt: 1)
        
        pastProjectsTableView.delegate = self
        pastProjectsTableView.dataSource = self
        currentProjectsTableView.delegate = self
        currentProjectsTableView.dataSource = self
        skillsTableView.delegate = self
        skillsTableView.dataSource = self
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
    }
    
    func print_all() {
        print(student["login"].stringValue)
        print(student["usual_full_name"])
        print(student["cursus_users"][cursus.index]["level"])
        print(student["email"])
        print(student["image"]["versions"]["small"])
        print(student["correction_point"])
        print(student["wallet"])
        print("Past projects")
        for (_,project) in student["past_projects"] {
            print("")
            print(project["project"]["slug"])
            print(project["final_mark"])
        }
        print("Projects in progress")
        for (_,project) in student["current_projects"] {
            print("")
            print(project["project"]["name"])
        }
        print("Skills")
        for (_,skill) in student["cursus_users"][cursus.index]["skills"] {
            print("")
            print(skill["name"])
            print(skill["level"])
        }
        print("Attended events")
        for (_,event) in student["events"] {
            print("")
            print(event["name"])
            var eventDate: String = event["begin_at"].stringValue
            eventDate = String(eventDate.prefix(10))
            print(eventDate)
        }
    }
    
    @IBAction func changeCursus(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 1 {
            cursus.index = 0
            cursus.id = 9
        } else {
            cursus.index = 1
            cursus.id = 21
        }
        updatePage()
    }
    
    func updatePage() {
        filterPastProjects()
        filterCurrentProjects()
        levelLabel.text = "Level: " +
            student["cursus_users"][cursus.index]["level"].stringValue[0..<4]
        pastProjectsTableView.reloadData()
        currentProjectsTableView.reloadData()
        skillsTableView.reloadData()
        eventsTableView.reloadData()
    }
    
    private func filter_project_name(_ project: inout JSON,
                                     _ past_project: Bool) -> Bool {
        let pn = project["project"]["slug"].stringValue
        if pn.contains("42cursus-") {
            project["project"]["slug"] = JSON(pn[9...])
        }
        if pn.contains("internship-i-internship-i") {
            if pn.count > 24 && past_project {
                return false
            }
            project["project"]["slug"] = JSON(pn[13...])
        }
        if pn.contains("internship-ii-internship-ii") {
            if pn.count > 26 && past_project {
                return false
            }
            project["project"]["slug"] = JSON(pn[14...])
        }
        if (pn.contains("-day-") || pn.contains("-rush-")) && past_project {
            return false
        }
        return true
    }
    
    private func filterPastProjects() {
        var past_projects = [JSON]()
        for (_,var project) in student["projects_users"]
                where project["final_mark"].stringValue != "" &&
                project["cursus_ids"][0].intValue == cursus.id {
            if filter_project_name(&project, true) {
                past_projects.append(project)
            }
        }
        student["past_projects"] = JSON(past_projects)
    }
    
    private func filterCurrentProjects() {
        var current_projects = [JSON]()
        for (_,var project) in student["projects_users"]
                where project["final_mark"].stringValue == "" &&
                project["cursus_ids"][0].intValue == cursus.id {
            if filter_project_name(&project, false) {
                current_projects.append(project)
            }
        }
        student["current_projects"] = JSON(current_projects)
    }
    
    private func fetchImage(url: String) {
        let imageURL = URL(string: url)
        var image: UIImage?
        if let url = imageURL {
            //All network operations has to run on different thread(not on main thread).
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = NSData(contentsOf: url)
                //All UI operations has to run on main thread.
                DispatchQueue.main.async {
                    if imageData != nil {
                        image = UIImage(data: imageData! as Data)
                        self.imageView.image = image
                        self.imageView.sizeToFit()
                    } else {
                        image = nil
                    }
                }
            }
        }
    }

}

extension studentPageVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case pastProjectsTableView:
            return student["past_projects"].count
        case currentProjectsTableView:
            return student["current_projects"].count
        case skillsTableView:
            return student["cursus_users"][cursus.index]["skills"].count
        case eventsTableView:
            return student["events"].count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch tableView {
        case pastProjectsTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "past_project_cell")!
            let project = student["past_projects"][indexPath.row]
            cell.textLabel?.text = project["project"]["slug"].stringValue + " " +
                        project["final_mark"].stringValue
            return cell
        case currentProjectsTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "current_project_cell")!
            let project = student["current_projects"][indexPath.row]
            cell.textLabel?.text = project["project"]["slug"].stringValue
            return cell
        case skillsTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "skill_cell")!
            let skill = student["cursus_users"][cursus.index]["skills"][indexPath.row]
            cell.textLabel?.text = skill["name"].stringValue + " " + skill["level"].stringValue
            return cell
        case eventsTableView:
            let cell = tableView.dequeueReusableCell(withIdentifier: "event_cell")!
            let event = student["events"][indexPath.row]
            var eventDate: String = event["begin_at"].stringValue
            eventDate = String(eventDate.prefix(10))
            cell.textLabel?.text = event["name"].stringValue + " " + eventDate
            return cell
        default:
            return UITableViewCell()
        }
    }
}
