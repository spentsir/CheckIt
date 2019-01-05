//
//  TaskTableViewController.swift
//  CheckIt
//
//  Created by Spencer Cawley on 1/5/19.
//  Copyright © 2019 Spencer Cawley. All rights reserved.
//

import UIKit

class TaskTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
    }
    
    fileprivate func setupNavBar() {
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 1, green: 0.7436284034, blue: 0.4364852532, alpha: 1)
        navigationController?.navigationBar.barStyle = .blackTranslucent
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 40, weight: .heavy)]
        navigationItem.title = "Tasks To-Do"
        
        let addButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(handleAddButton))
        navigationItem.rightBarButtonItem = addButton
        
        let settingsButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "settingsButton"), style: .plain, target: self, action: #selector(handleSettingsButton))
        navigationItem.leftBarButtonItem = settingsButton
    }
    
    @objc fileprivate func handleSettingsButton() {
        print("Handling settings button")
    }
    
    @objc fileprivate func handleAddButton() {
        print("Handling add button")
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
