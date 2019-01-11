//
//  AddManageTaskViewController.swift
//  CheckIt
//
//  Created by Spencer Cawley on 1/8/19.
//  Copyright © 2019 Spencer Cawley. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

protocol AddManageTaskViewControllerDelegate: class {
    func addNewTasksToActive(newTask: Task)
    func modifyExistingTask(fromIndexPath: IndexPath, newTask: Task)
    func removeTask(fromIndexPath: IndexPath)
    
}

class AddManageTaskViewController: UIViewController {
    
    
    // Protocol Delegate
    weak var delegate: AddManageTaskViewControllerDelegate?
    
    // Contains reference to array, Task, positionInArray in TaskTableViewController
    public var categoryArray: [Category]!
    public var modifyTask: Task?
    public var indexPathOfmodifyTask: IndexPath?
    
    // Help Variable - temporary contain Category object
    private var chosenCategory: Category?
    
    // Notification center
    let notificationCenter = UNUserNotificationCenter.current()
    
    let options: UNAuthorizationOptions = [.alert, .sound, .badge];
    
    var notification: UNNotificationRequest?
    
    // Declaration of UI Items
    private let nameTaskLabel: UILabel = {
        let label = UILabel()
        label.text = "Task title"
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 13)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Add new task.."
        textField.borderStyle = .roundedRect;
        textField.autocorrectionType = .no
        textField.keyboardType = .asciiCapable
        textField.returnKeyType = .default
        textField.font = .boldSystemFont(ofSize: 17)
        return textField
    }()
    
    private let whenShouldDone: UILabel = {
        let label = UILabel()
        label.text = "Date task should be done"
        
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    private let dateShouldDoneTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Add a completion date..."
        textField.borderStyle = .roundedRect;
        textField.font = .boldSystemFont(ofSize: 17)
        textField.addTarget(self, action: #selector(handleActionDatePick), for: .editingDidBegin)
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private let chooseCategoryLabel: UILabel = {
        let label = UILabel()
        label.text = "Category"
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    private let categoryTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Add a category... "
        textField.borderStyle = .roundedRect;
        textField.font = .boldSystemFont(ofSize: 17)
        textField.addTarget(self, action: #selector(handleActionCategoryPick), for: .editingDidBegin)
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private let colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 15
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let  setNotificationOnLabel: UILabel = {
        let label = UILabel()
        label.text = "Turn notification on"
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    private let  notificationSwitch: UISwitch = {
        let notificationSwitch = UISwitch()
        notificationSwitch.isOn = false
        return notificationSwitch
    }()
    
    private let  setIsDoneTaskLabel: UILabel = {
        let label = UILabel()
        label.text = "Mark task as done"
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 13)
        label.isHidden = true
        return label
    }()
    private let  isDoneSwitch: UISwitch = {
        let isDoneSwitch = UISwitch()
        isDoneSwitch.isOn = false
        isDoneSwitch.isHidden = true
        return isDoneSwitch
    }()
    
    
    private let saveTaskButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setTitle("Save task", for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(displayP3Red: 0.0, green: 122.0/255.0, blue: 1.0, alpha: 1.0).cgColor
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(handleSaveButton), for: .touchUpInside)
        return button
    }()
    
    private let buttonDelete: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setTitle("Delete task", for: .normal)
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.red.cgColor
        button.setTitleColor(.red, for: .normal)
        button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(handleDeleteAction), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SetUpLayout()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setUIToNewOrModifyExists(modifyTask: modifyTask)
        
        checkNotificationIsSet()
        
        if modifyTask == nil {
            self.title = "Add New Task"
        } else {
            self.title = "Edit Task"
        }
    }
    
    // Checking if notification is in pending list, if so change notification switch
    fileprivate func checkNotificationIsSet() {
        notificationSwitch.isOn = false
        notification = nil
        // No point check notification is new one id added
        guard modifyTask != nil else { return }
        
        notificationCenter.getPendingNotificationRequests { (notifications) in
            
            for notification in notifications {
                if notification.identifier == self.modifyTask?.taskTitle {
                    DispatchQueue.main.async() {
                        self.notification = notification
                        self.notificationSwitch.isOn = true
                    }
                }
            }
        }
    }
    
    // Check request
    fileprivate func checkIfNotificationIsAllowed() {
        notificationCenter.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("Something went wrong")
                return
            }
        }
    }
    
    fileprivate func createRequstAndAddNotificationToNotificationCenter(_ task: Task) {
        let content = UNMutableNotificationContent()
        content.title = task.taskTitle
        content.body = "Click to complete your task!"
        content.sound = UNNotificationSound.default
        let date = task.completionDate!
        let triggerDate = Calendar.current.dateComponents([.month,.day,.hour,.minute,.second,], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let identifier = task.taskTitle
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        notificationCenter.add(request, withCompletionHandler: { (error) in
            if let error = error {
                print(error)
            }
        })
    }
    
    func notificationSetOn(task: Task)  {
        checkIfNotificationIsAllowed()
        if notificationSwitch.isOn {
            createRequstAndAddNotificationToNotificationCenter(task)
        } else {
            if let tempNotification = notification {
                notificationCenter.removePendingNotificationRequests(withIdentifiers: [tempNotification.identifier])
            }
        }
        
    }
    
    
    // Handle Add, Modify  Action
    @objc func handleSaveButton(sender: UIButton) {
        // Check if is task Title long enough
        if titleTextField.text!.count < 3 {
            showAlert(message: "Task name is need to be at least 3 letters long.")
            return
        }
        
        let newTask = Task(taskTitle: titleTextField.text!, completionDate: Task.dateShouldBeDoneFromString(dateString: dateShouldDoneTextField.text!), category: chosenCategory, isItDone: isDoneSwitch.isOn)
        
        // Notification check
        if notificationSwitch.isOn {
            // I remove old notification and set the new one
            if let tempNotification = notification {
                notificationCenter.removePendingNotificationRequests(withIdentifiers: [tempNotification.identifier])
            }
            // If notification is on and date not set, show warning
            guard newTask.completionDate != nil else {
                showAlert(message: "Please add date to turn on the notification.")
                notificationSwitch.isOn = false
                return
            }
            notificationSetOn(task: newTask)
        }
        
        if modifyTask == nil {
            // Add New Task
            if !newTask.doesExist() {
                newTask.saveToCoreData()
                delegate?.addNewTasksToActive(newTask: newTask)
                setUIToNewOrModifyExists(modifyTask: nil)
                
            } else {
                showAlert(message: "Task with name \"\(newTask.taskTitle)\" is already exists.")
                return
            }
            notificationSetOn(task: newTask)
        } else {
            // Modifing existing Task
            // Modify Core Data and Task
            modifyTask!.modifyTask(newTask: newTask)
            // Modify TableView
            // delegate?.modifyExistingTask(fromIndexPath: indexPathOfmodifyTask!, newTask: newTask)
            setUIToNewOrModifyExists(modifyTask: nil)
            
        }
        navigationController?.popToRootViewController(animated: true)
    }
    
    // Handle Delete Task
    @objc func handleDeleteAction(sender: UIButton) {
        
        // If notification exist, remove it
        if let tempNotification = notification {
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [tempNotification.identifier])
        }
        // Remove from table view first
        delegate?.removeTask(fromIndexPath: indexPathOfmodifyTask!)
        // Remove from core data next
        modifyTask?.deleteTaskFromCoreData()
        
        // Set button to new item add
        setUIToNewOrModifyExists(modifyTask: nil)
    }
}

// Methods responsible for UI
extension AddManageTaskViewController {
    
    // showing Allert
    func showAlert(message: String) {
        
        let allertController = UIAlertController(title: "Warning", message: message, preferredStyle: UIAlertController.Style.alert)
        allertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            print("OK")
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(allertController, animated: true, completion: nil)
    }
    
    // Switch between appearance for new Task and Managing Task
    func setUIToNewOrModifyExists(modifyTask: Task?) {
        if let taskExist = modifyTask {
            prepareItemForManageExistingTask(taskExist)
        } else {
            prepareItemForSaveNewTask()
        }
    }
    
    // Layout Methods
    private func SetUpLayout() {
        view.backgroundColor = .white
        let stack = UIStackView(arrangedSubviews: [nameTaskLabel,
                                                   titleTextField,
                                                   whenShouldDone,
                                                   dateShouldDoneTextField,
                                                   chooseCategoryLabel,
                                                   setUpCategoryTextFieldAndcolorView(),
                                                   setUpNotificationIsDoneLabel(),
                                                   setUpNotificationIsDoneSwitch(),
                                                   setUpSaveDeleteButton()])
        stack.axis = .vertical
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.spacing = 8
        view.addSubview(stack)
        stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        stack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15).isActive = true
        stack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15).isActive = true
        titleTextField.delegate = self
        
    }
    
    func setUpCategoryTextFieldAndcolorView() -> UIView {
        let view = UIView()
        view.addSubview(categoryTextField)
        view.addSubview(colorView)
        
        colorView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        colorView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        colorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        colorView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        categoryTextField.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        categoryTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        categoryTextField.trailingAnchor.constraint(equalTo: colorView.leadingAnchor, constant: -10).isActive = true
        categoryTextField.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        
        return view
    }
    
    fileprivate func prepareItemForSaveNewTask() {
        titleTextField.text = ""
        titleTextField.borderStyle = .roundedRect
        dateShouldDoneTextField.text = ""
        dateShouldDoneTextField.borderStyle = .roundedRect
        chosenCategory = nil
        categoryTextField.text = ""
        categoryTextField.borderStyle = .roundedRect
        colorView.backgroundColor = .white
        saveTaskButton.setTitle("Save task", for: .normal)
        buttonDelete.isHidden = true
        setIsDoneTaskLabel.isHidden = true
        isDoneSwitch.isHidden = true
        isDoneSwitch.isOn = false
    }
    
    fileprivate func prepareItemForManageExistingTask(_ taskExist: Task) {
        titleTextField.text = taskExist.taskTitle
        titleTextField.borderStyle = .none
        
        let dateString = Task.dateShouldBeDoneToString(date: taskExist.completionDate)
        dateShouldDoneTextField.text = dateString
        dateShouldDoneTextField.borderStyle = .none
        chosenCategory = taskExist.category
        categoryTextField.text = taskExist.category?.categoryName
        categoryTextField.borderStyle = .none
        colorView.backgroundColor = taskExist.category?.color
        saveTaskButton.setTitle("Save Task", for: .normal)
        buttonDelete.isHidden = false
        setIsDoneTaskLabel.isHidden = true
        isDoneSwitch.isHidden = true
        isDoneSwitch.isOn = taskExist.isItDone
        
    }
    
    func setUpSaveDeleteButton() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [saveTaskButton, buttonDelete])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }
    
    func setUpNotificationIsDoneLabel() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [setNotificationOnLabel, setIsDoneTaskLabel])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }
    func setUpNotificationIsDoneSwitch() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: [notificationSwitch, isDoneSwitch])
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = 8
        return stackView
    }
    
}


// Methods with dataPicker and PickerView and TextField related
extension AddManageTaskViewController: UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    
    
    // Handle return button in keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @objc func handleActionDatePick(sender: UITextField) {
        
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.dateAndTime
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: UIControl.Event.valueChanged)
    }
    
    @objc func datePickerValueChanged(sender: UIDatePicker) {
        dateShouldDoneTextField.text = Task.dateShouldBeDoneToString(date: sender.date)
    }
    
    @objc func handleActionCategoryPick(sender: UITextField) {
        
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        sender.inputView = pickerView
    }
    
    // Hide keyboard after tap outside
    override internal func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Return number of rows in picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return categoryArray.count + 1
    }
    
    // name for category pickern
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return "No Category"
        } else
        {
            return categoryArray[row-1].categoryName
        }
    }
    // Actions when row is selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row > 0 {
            categoryTextField.text = categoryArray[row-1].categoryName
            colorView.backgroundColor = categoryArray[row-1].color
            chosenCategory = categoryArray[row-1]
        }
    }
}
