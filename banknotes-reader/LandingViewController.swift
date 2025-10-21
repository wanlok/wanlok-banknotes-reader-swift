//
//  LandingViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 19/10/2025.
//

import UIKit

class LandingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let customView = Dummy(frame: CGRect(x: 20, y: 100, width: 300, height: 150))
        view.addSubview(customView)
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
