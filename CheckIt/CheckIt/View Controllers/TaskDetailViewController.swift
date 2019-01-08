//
//  TaskDetailViewController.swift
//  CheckIt
//
//  Created by Spencer Cawley on 1/6/19.
//  Copyright © 2019 Spencer Cawley. All rights reserved.
//

import UIKit

class TaskDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavBar()
    }
    
    func setupNavBar() {
//        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 1, green: 0.7436284034, blue: 0.4364852532, alpha: 1)
//        navigationController?.navigationBar.barStyle = .blackTranslucent
//        navigationController?.navigationBar.tintColor = .white
//        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 40, weight: .heavy)]
        navigationItem.title = "Add New Task"
    }

}
