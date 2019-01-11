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
        categoryDictionary.updateValue(category, forKey: category.categoryName)
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
        
        let addButton = UIBarButtonItem.init(barButtonSystemItem: .add, target: self, action: #selector(handleActionNavigationButton(sender:)))
        addButton.tag = 1
        navigationItem.rightBarButtonItem = addButton
        
        let settingsButton = UIBarButtonItem.init(image: #imageLiteral(resourceName: "settingsButton"), style: .plain, target: self, action: #selector(handleActionNavigationButton(sender:)))
        settingsButton.tag = 0
        navigationItem.leftBarButtonItem = settingsButton
    }
    
    // Used for save Category
    var categoryDictionary = [String : Category?]()
    // Used for store Tasks - [0] = Active and [1 ]Done
    var tasks = [[Task](),[Task()]]
    // Sorting 0 = name, 1 = date
    var sortBy = 0
    
    // Cell identificator
    private let cellID = "cellID"
    
    // Controllers
    private let addManageTaskViewController = AddManageTaskViewController()
    private let settingsTableViewController = SettingsTableViewController()
    
    // Notification center
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryDictionary = Category.loadCategoryFromCoreData()
        // if dictionary list is empty = first launch, add default data
        if categoryDictionary.count == 0 {
            loadMockData()
        }
        
        // Fill array from CoreData
        tasks = Task.loadTaskFromCoreData(categoryDictionary: categoryDictionary)
        sortListOfTasks()
        
        tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: cellID)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
        sortListOfTasks()
        tableView.reloadData()
    }
    
    
    public func appendTaskAndSort(section: Int, task: Task) {
        tasks[section].append(task)
        sortListOfTasks()
    }
    
    // Sorting array by name or date
    public func sortListOfTasks()  {
        if sortBy == 0 {
            tasks[0] = tasks[0].sorted(by: { $0.taskTitle.lowercased() < $1.taskTitle.lowercased() })
            tasks[1] = tasks[1].sorted(by: { $0.taskTitle.lowercased() < $1.taskTitle.lowercased() })
        } else {
            tasks[0] = tasks[0].sorted { (item1, item2) -> Bool in
                let t1 = item1.completionDate ?? Date(timeIntervalSince1970: 0)
                let t2 = item2.completionDate ?? Date(timeIntervalSince1970: 0)
                return t1 < t2
            }
            tasks[1] = tasks[1].sorted { (item1, item2) -> Bool in
                let t1 = item1.completionDate ?? Date(timeIntervalSince1970: 0)
                let t2 = item2.completionDate ?? Date(timeIntervalSince1970: 0)
                return t1 < t2
            }
        }
    }
    
    
    
    // Handle Navigation bar buttons action
    @objc private func handleActionNavigationButton(sender: UIButton)  {
        
        var temporaryCategoryArray = [Category]()
        for categoryDictionary in categoryDictionary {
            if let category = categoryDictionary.value {
                temporaryCategoryArray.append(category)
            }
        }
        if sender.tag == 0 {
            // Action when Setting Bar Button tapped
            settingsTableViewController.arrayOfCategory = temporaryCategoryArray
            settingsTableViewController.delegate = self
            navigationController?.pushViewController(settingsTableViewController, animated: true)
            
        } else {
            // Action when Add Task Button tapped
            
            // If not nil - it is detail / edit
            addManageTaskViewController.modifyTask = nil
            addManageTaskViewController.categoryArray = temporaryCategoryArray
            addManageTaskViewController.delegate = self
            navigationController?.pushViewController(addManageTaskViewController, animated: true)
        }
    }
}

extension TaskTableViewController: SettingsTableViewControllerDelegate, AddManageTaskViewControllerDelegate {
    
    // 0 = name, 1 = date
    func setHowShouldBeTasksSorted(indexHowToSort: Int) {
        sortBy = indexHowToSort
    }
    
    // saveNewCategory
    func saveNewCategory(newCategory: Category) {
        newCategory.saveCategoryToCoreData()
        categoryDictionary.updateValue(newCategory, forKey: newCategory.categoryName)
    }
    
    // Replace old category to new one, Loop throuh old task and replace old category to new one
    func updateCategoryInExistingTasks(categoryToDelete: Category, newCategory: Category) {
        categoryToDelete.modifyCategory(newCategory: newCategory)
        
        // It is necessary change loop throuh all task and change category
        // Loop through array - firt loop - active tasks, second loop done tasks
        for rightArray in tasks {
            for task in rightArray {
                let task = task
                if task.category?.categoryName == categoryToDelete.categoryName {
                    task.category = newCategory
                    task.modifyTask(newTask: task)
                }
            }
        }
        categoryDictionary = Category.loadCategoryFromCoreData()
        tasks = Task.loadTaskFromCoreData(categoryDictionary: categoryDictionary)
    }
    
    func addNewTasksToActive(newTask: Task) {
        tasks[0].append(newTask)
    }
    
    func modifyExistingTask(fromIndexPath: IndexPath, newTask: Task) {
        tasks[fromIndexPath.section][fromIndexPath.row] = newTask
    }
    
    func removeTask(fromIndexPath: IndexPath) {
        tasks[fromIndexPath.section].remove(at: fromIndexPath.row)
    }
    
    
}



// Method related to TableView
extension TaskTableViewController {
    
    // Active and Done Task - 2 section
    override internal func numberOfSections(in tableView: UITableView) -> Int {
        return  tasks.count
    }
    
    override internal func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasks[section].count
    }
    
    // When row selected, detail is showed
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // If not nil - it is detail / edit
        addManageTaskViewController.modifyTask = nil
        var temporaryCategoryArray = [Category]()
        for categoryDictionary in categoryDictionary {
            if let category = categoryDictionary.value {
                temporaryCategoryArray.append(category)
            }
        }
        addManageTaskViewController.indexPathOfmodifyTask = indexPath
        addManageTaskViewController.modifyTask = tasks[indexPath.section][indexPath.row]
        addManageTaskViewController.categoryArray = temporaryCategoryArray
        addManageTaskViewController.delegate = self
        navigationController?.pushViewController(addManageTaskViewController, animated: true)
        
    }
    
    // Handle Leading Swipe
    override internal func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let done = doneAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [done])
    }
    
    // Handle done action - remove from list of active task and inser to list of done task, safe to coredata bool value if it is done
    func doneAction(at indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Done") { (action, view, completion) in
            if indexPath.section == 0 {
                self.tasks[0][indexPath.row].isItDone = true
                self.tasks[0][indexPath.row].modifyTask(newTask: self.self.tasks[0][indexPath.row])
                self.appendTaskAndSort(section: 1, task: self.tasks[0][indexPath.row])
                self.tasks[0].remove(at: indexPath.row)
            } else  {
                self.tasks[1][indexPath.row].isItDone = false
                self.tasks[1][indexPath.row].modifyTask(newTask: self.self.tasks[1][indexPath.row])
                self.appendTaskAndSort(section: 0, task: self.tasks[1][indexPath.row])
                self.tasks[1].remove(at: indexPath.row)
            }
            self.sortListOfTasks()
            self.tableView.reloadData()
            completion(true)
        }
        action.backgroundColor = .green
        return action
    }
    
    // Sets trailing Swipe
    override internal func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    // Used for delete action from array
    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            self.tasks[indexPath.section][indexPath.row].deleteTaskFromCoreData()
            self.tasks[indexPath.section].remove(at: indexPath.row)
            self.tableView.reloadData()
            completion(true)
        }
        action.backgroundColor = .red
        return action
    }
    
    
    
    override internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath) as! TaskTableViewCell
        cell.setCell(taskToShow: tasks[indexPath.section][indexPath.row])
        return cell
    }

}
