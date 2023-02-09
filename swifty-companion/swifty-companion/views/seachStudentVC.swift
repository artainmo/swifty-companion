//
//  seachStudentVC.swift
//  swifty-companion
//
//  Created by Arthur Tainmont on 08/02/2023.
//

import UIKit

class seachStudentVC: UIViewController, UITextFieldDelegate {

    @IBOutlet var fieldSearchStudent: UITextField!
    @IBOutlet var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.isHidden = true
        fieldSearchStudent.delegate = self
    }
    
    @IBAction func viewStudent() {
        let login: String = fieldSearchStudent.text ?? ""
            
        if let student = searchStudent(searchInput: login) {
            errorLabel.isHidden = true
            let vc = storyboard?.instantiateViewController(identifier: "page")
                        as! studentPageVC
            vc.student = student
            navigationController?.pushViewController(vc, animated: true)
        } else {
            errorLabel.isHidden = false
        }
    }
    
    
    

}
