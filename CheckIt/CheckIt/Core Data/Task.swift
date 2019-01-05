//
//  Task.swift
//  CheckIt
//
//  Created by Spencer Cawley on 1/5/19.
//  Copyright © 2019 Spencer Cawley. All rights reserved.
//

import UIKit
import CoreData

class Task {
    var taskTitle: String
    var completionDate: Date?
    var category: Category?
    var isItDone: Bool
    
    init() {
        self.taskTitle = ""
        self.completionDate = nil
        self.category = nil
        self.isItDone = false
    }
    
    init(taskTitle: String, completionDate: Date?, category: Category?, isItDone: Bool) {
        self.taskTitle = taskTitle
        self.completionDate = completionDate
        self.category = category
        self.isItDone = isItDone
    }
    
    class func loadTaskFromCoreData(categoryDictionary: [String : Category?]) -> [[Task]] {
        
        var listOfTasks = [[Task](), [Task]()]
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        request.returnsObjectsAsFaults = false
        
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    var tempTaskTitle = ""
                    var tempIsItDone = false
                    var tempDate: Date?
                    var tempCategory: Category?
                    
                    if let taskTitle = result.value(forKey: "taskTitle") as? String {
                        tempTaskTitle = taskTitle
                    }
                    if let isItDone = result.value(forKey: "isItDone") as? Bool {
                        tempIsItDone = isItDone
                    }
                    if let dueDate = result.value(forKey: "dueDate") as? String {
                        tempDate = Task.dateShouldBeDoneFromString(dateString: dueDate)
                    }
                    if let categoryName = result.value(forKey: "categoryName") as? String {
                        tempCategory = categoryDictionary[categoryName] ?? nil
                    }
                    let task = Task(taskTitle: tempTaskTitle, completionDate: tempDate, category: tempCategory, isItDone: tempIsItDone)
                    if task.isItDone == false {
                        listOfTasks[0].append(task)
                    } else {
                        listOfTasks[1].append(task)
                    }
                }
            } else {
                print("No Results: \(#function.description)")
            }
        } catch  {
            print("Couldn't fetch results: \(#function.description)")
        }
        return listOfTasks
    }
    
    static func dateShouldBeDoneToString(date: Date?) -> String {
        if let tempDate = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy, HH:mm"
            return dateFormatter.string(from: tempDate)
        } else {
            return ""
        }
    }
    
    
    class func dateShouldBeDoneFromString(dateString: String?) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy, HH:mm"
        if let tempDateString = dateString {
            if let date = dateFormatter.date(from: tempDateString) {
                return date
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func doesExist() -> Bool {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "taskTitle == %@", self.taskTitle)
        
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                return true
            } else {
                return false
            }
        } catch  {
            print("Couldn't fetch results: \(#function.description)")
        }
        return false
    }
    
    func deleteTaskFromCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "taskTitle == %@", self.taskTitle)
        
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if (result.value(forKey: "taskTitle") as? String) != nil {
                        context.delete(result)
                    }
                    do {
                        try context.save()
                    } catch {
                        print("Delete failed!: \(#function.description)")
                    }
                }
            } else {
                print("No results: \(#function.description)")
            }
        } catch {
            print("Couldn't fetch results!: \(#function.description)")
        }
    }
    
    func modifyTask(newTask: Task) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Tasks")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "taskTitle == %@", self.taskTitle)
        
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                
                let result = results[0] as! NSManagedObject
                result.setValue(newTask.isItDone, forKey: "isItDone")
                result.setValue(newTask.taskTitle, forKey: "taskTitle")
                result.setValue(Task.dateShouldBeDoneToString(date: newTask.completionDate), forKey: "dueDate")
                result.setValue(newTask.category?.name, forKey: "categoryName")
                
                do {
                    try context.save()
                } catch {
                    print("Modifiying task failed!: \(#function.description)")
                }
            } else {
                print("No results!: \(#function.description)")
            }
        } catch {
            print("Couldn't fetch results!: \(#function.description)")
        }
        self.taskTitle = newTask.taskTitle
        self.completionDate = newTask.completionDate
        self.category = newTask.category
        self.isItDone = newTask.isItDone
    }
    
    func saveToCoreData() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newTask = NSEntityDescription.insertNewObject(forEntityName: "Task", into: context)
        newTask.setValue(self.taskTitle, forKey: "taskTitle")
        newTask.setValue(Task.dateShouldBeDoneToString(date: self.completionDate), forKey: "dueDate")
        newTask.setValue(self.category?.name, forKey: "categoryName")
        newTask.setValue(self.isItDone, forKey: "isItDone")
        do {
            try context.save()
        } catch {
            print("Error saving to core data!: \(error.localizedDescription)")
        }
        context.refreshAllObjects()
    }
}

