//
//  SettingsTableViewController.swift
//  CheckIt
//
//  Created by Spencer Cawley on 1/6/19.
//  Copyright © 2019 Spencer Cawley. All rights reserved.
//

import UIKit
import UserNotifications

protocol SettingsTableViewControllerDelegate: class {
    func setHowShouldBeTasksSorted(indexHowToSort: Int)
    func saveNewCategory(newCategory: Category)
    func updateCategoryInExistingTasks(categoryToDelete: Category, newCategory: Category)
    
}

class SettingsTableViewController: UITableViewController, CategoryShowCellDelegate, SwitchCellDelegate {
    // Protocol Delegate
    weak var delegate: SettingsTableViewControllerDelegate?
    
    // IDs for Cells
    private let categoryShowID = "categoryShowID"
    private let swichCellID = "switchID"
    
    // Notification center
    let notificationCenter = UNUserNotificationCenter.current()
    
    // List of categories
    var arrayOfCategory = [Category]()
    // Titles Section
    private let titleSectionArray = ["Category list:", "Sorting by:"]
    // Sorting section
    private let orderBySettingsTitle = ["Order by name", "Order by date"]
    private var orderBy = [true, false]
    
    // Keep selected row, remember actual and last one row.
    private var selectedRowToExpand = -1
    private var rowExpandedLastTime = -1
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 160))
        tableView.tableFooterView = footerView
        tableView.register(CategoryTableViewCell.self, forCellReuseIdentifier: categoryShowID)
        tableView.register(SwitchTableViewCell.self, forCellReuseIdentifier: swichCellID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.title = "Settings"
        tableView.reloadData()
    }
    
    // Handle Notification and sorting Switches
    func switchCellTableViewValueChanged(_ sender: SwitchTableViewCell) {
        guard let switchIndexPath = tableView.indexPath(for: sender) else { return }
        
        // When switch in OrderBy Cells is changed to on is necessary set other switch to off. Next is notigy main TaskTableViewController that order must be changed
        if switchIndexPath.section == 2 {
            for index in 0...orderBy.count - 1 {
                if index == switchIndexPath.row {
                    orderBy[index] = true
                    // set variable responsible for sorting
                    delegate?.setHowShouldBeTasksSorted(indexHowToSort: index)
                } else {
                    orderBy[index] = false
                }
            }
            tableView.reloadData()
            
        }
    }
    
    // Save category to Core Data, next modify local array and modify in dictionary in rootViewController
    func categoryShowCellSafeButtonTapped(_ sender: CategoryTableViewCell) {
        guard let indexPathTappedCell = tableView.indexPath(for: sender) else  { return }
        
        // Check if category is not nil (name less than three characters)
        guard let category = sender.getCategory() else {
            showAlert(message: "Too short category name. Try type at least 3 characters.")
            return
        }
        // Checking if category already exist - same name
        guard arrayOfCategory.contains(where: { tempCategory in tempCategory.categoryName != category.categoryName }) else {
            showAlert(message: "Category with same name already exists")
            return
        }
        // If button in last row tapped, new category created
        if indexPathTappedCell.row == arrayOfCategory.count {
            // Check if category name is not already occupied
            for tempCategory in arrayOfCategory {
                if tempCategory.categoryName == category.categoryName {
                    showAlert(message: "Category with same name already exists")
                    return
                }
            }
            // append into local array
            arrayOfCategory.append(category)
            // add to dictionary in controller
            delegate?.saveNewCategory(newCategory: category)
        } else {
            // Modify existing category
            let oldCategory = arrayOfCategory[indexPathTappedCell.row]
            let newCategory = category
            // switch old category to new one in Core Data
            delegate?.updateCategoryInExistingTasks(categoryToDelete: oldCategory, newCategory: newCategory)
            
        }
        // Deselect row
        selectedRowToExpand = -1
        tableView.reloadData()
    }
    
    func showAlert(message: String) {
        let allertController = UIAlertController(title: "Warning", message: message, preferredStyle: UIAlertController.Style.alert)
        allertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: nil)
        }))
        self.present(allertController, animated: true, completion: nil)
    }
    override internal func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
}

// Table View method related
extension SettingsTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return titleSectionArray.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleSectionArray[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            // +1 mean blank row for add new category
            return arrayOfCategory.count + 1
//        case 1:
//            return notificationSettingsTitle.count
        default:
            return orderBySettingsTitle.count
        }
    }
    
    // If section = 0 - categorySection, i set variable  to row
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            // If selected row is equal indexpath.row - other tap on already expanded cell, variable is set to -1 - it shrink again.
            rowExpandedLastTime = selectedRowToExpand
            selectedRowToExpand = selectedRowToExpand == indexPath.row ? -1 : indexPath.row
            // Variable rowExpandedLastTime remember last selected index, if other cell is selected is necessary update cell selected before
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath], with: .automatic)
            if rowExpandedLastTime >= 0 {
                let indexPathrowExpandedLastTime = IndexPath(item: rowExpandedLastTime, section: 0)
                tableView.reloadRows(at: [indexPathrowExpandedLastTime], with: .automatic)
            }
            tableView.endUpdates()
        }
    }
    
    // Used for dropdown cell in category section. I check variable and if variable is same as row, the row get bigger height.
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if selectedRowToExpand == indexPath.row {
                return 95
            } else {
                return 45
            }
        } else {
            return 45
        }
        
    }
    
    // Return cell for CategorySection
    fileprivate func getCellCategorySection(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: categoryShowID, for: indexPath) as! CategoryTableViewCell
        // cell show category, if it is last cell in category section - cell containt only text to add new one.
        if indexPath.row < arrayOfCategory.count {
            cell.setCell(category: arrayOfCategory[indexPath.row])
        } else {
            cell.setCell(category: Category(nameOfCategory: "", colorOfCategory: .white))
        }
        // Handle dropdown menu
        selectedRowToExpand == indexPath.row ? cell.editViewIsHidden(isHidden: false) : cell.editViewIsHidden(isHidden: true)
        
        cell.delegate = self
        return cell
    }
    

    // Return cell for sorting section
    fileprivate func getCellSortingSection(_ tableView: UITableView, _ indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: swichCellID, for: indexPath) as! SwitchTableViewCell
        cell.setTitleOfSwitch(switchDescription: orderBySettingsTitle[indexPath.row])
        cell.setSwitch(isEnabled: !orderBy[indexPath.row], isOn: orderBy[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            return getCellCategorySection(tableView, indexPath)
        default:
            return getCellSortingSection(tableView, indexPath)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.contentView.backgroundColor = #colorLiteral(red: 1, green: 0.7436284034, blue: 0.4364852532, alpha: 1)
            headerView.textLabel?.textColor = .white
            headerView.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: .heavy)
        }
    }
}
