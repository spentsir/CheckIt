//
//  TaskTableViewController.swift
//  CheckIt
//
//  Created by Spencer Cawley on 1/5/19.
//  Copyright © 2019 Spencer Cawley. All rights reserved.
//

import UIKit
import CoreData


class TaskTableViewController: UITableViewController {
    
    let cellID = "cellID"
    var tasks = [[Task](),[Task]()]
    var categoryDictionary = [String : Category?]()
    var sortBy = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavBar()
        
        categoryDictionary = Category.loadCategoryFromCoreData()
        if categoryDictionary.count == 0 {
            
        }
        loadMockData()
        tasks = Task.loadTaskFromCoreData(categoryDictionary: categoryDictionary)
    }
    
    func loadMockData() {
        categoryMockData(categoryName: "Work", categoryColor: #colorLiteral(red: 0.5823521081, green: 0.5717214529, blue: 1, alpha: 1))
        categoryMockData(categoryName: "Private", categoryColor: #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1))
        categoryMockData(categoryName: "Hobby", categoryColor: #colorLiteral(red: 0.2281630055, green: 1, blue: 0.5805700408, alpha: 1))
        categoryMockData(categoryName: "Errands", categoryColor: #colorLiteral(red: 0.312566155, green: 0.6381099265, blue: 1, alpha: 1))

        taskMockData(taskTitle: "Swipe right to complete a task", completionDate: nil, category: categoryDictionary["Work"]!, isItDone: false)
        taskMockData(taskTitle: "Swipe left to delete", completionDate: nil, category: categoryDictionary["Private"]!, isItDone: false)
        taskMockData(taskTitle: "Tap for details", completionDate: nil, category: categoryDictionary["Hobby"]!, isItDone: false)
        taskMockData(taskTitle: "Change color of categories in settings", completionDate: nil, category: categoryDictionary["Errands"]!, isItDone: false)
    }
    
    func categoryMockData(categoryName: String, categoryColor: UIColor) {
        let category = Category(nameOfCategory: categoryName, colorOfCategory: categoryColor)
        category.saveCategoryToCoreData()
        categoryDictionary.updateValue(category, forKey: category.name)
    }
    
    func taskMockData(taskTitle: String, completionDate: Date?, category: Category?, isItDone: Bool) {
        let task = Task(taskTitle: taskTitle, completionDate: nil, category: category, isItDone: false)
        task.saveToCoreData()
        tasks[0].append(task)
    }
    
    fileprivate func setupNavBar() {
        navigationController?.navigationBar.barTintColor = #colorLiteral(red: 1, green: 0.7436284034, blue: 0.4364852532, alpha: 1)
        navigationController?.navigationBar.barStyle = .blackTranslucent
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 40, weight: .heavy)]
        navigationItem.title = "Tasks To-Do"
        
        let addButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(handleAddButton))
        addButton.tag = 1
        navigationItem.rightBarButtonItem = addButton
        
        let settingsButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "settingsButton"), style: .plain, target: self, action: #selector(handleSettingsButton))
        settingsButton.tag = 0
        navigationItem.leftBarButtonItem = settingsButton
    }
    
    @objc fileprivate func handleSettingsButton() {
        navigationController?.pushViewController(SettingsTableViewController(), animated: true)
    }
    
    @objc fileprivate func handleAddButton() {
        navigationController?.pushViewController(TaskDetailViewController(), animated: true)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return tasks.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks[section].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! TaskTableViewCell
        cell.setCell(taskToShow: tasks[indexPath.section][indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func deleteAction( at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Delete") { (_, _, completion) in
            self.tasks[indexPath.section][indexPath.row].deleteTaskFromCoreData()
            self.tasks[indexPath.section].remove(at: indexPath.row)
            self.tableView.reloadData()
            completion(true)
        }
        action.backgroundColor = #colorLiteral(red: 0.8354771788, green: 0.232243972, blue: 0.1611536262, alpha: 1)
        return action
    }
 

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
