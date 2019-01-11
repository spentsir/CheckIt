//
//  TestViewController.swift
//  CheckIt
//
//  Created by Spencer Cawley on 1/10/19.
//  Copyright © 2019 Spencer Cawley. All rights reserved.
//

import UIKit

class TestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(image)
        
        image.heightAnchor.constraint(equalToConstant: 150).isActive = true
        image.widthAnchor.constraint(equalToConstant: 150).isActive = true
        image.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        image.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        

        view.backgroundColor = #colorLiteral(red: 1, green: 0.7436284034, blue: 0.4364852532, alpha: 1)
    }
    
    let image: UIImageView = {
        let v = UIImageView()
        v.translatesAutoresizingMaskIntoConstraints = false
        v.image = #imageLiteral(resourceName: "checkMarkImage").withRenderingMode(.alwaysOriginal)
        return v
    }()
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
