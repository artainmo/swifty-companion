//
//  seachStudentVC.swift
//  swifty-companion
//
//  Created by Arthur Tainmont on 08/02/2023.
//

import UIKit

class seachStudentVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print(API42.call("/v2/campus")?[0]["active"] ?? "nil")
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
