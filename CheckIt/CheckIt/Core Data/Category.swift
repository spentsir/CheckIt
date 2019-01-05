//
//  Category.swift
//  CheckIt
//
//  Created by Spencer Cawley on 1/5/19.
//  Copyright © 2019 Spencer Cawley. All rights reserved.
//

import UIKit
import CoreData

class Category {
    var name: String
    var color: UIColor
    
    init(nameOfCategory: String, colorOfCategory: UIColor) {
        self.name = nameOfCategory
        self.color = colorOfCategory
    }
    
    fileprivate func loadCategoryFromCoreData () -> [String : Category?] {
        
        var categoryDictionary = [String : Category?]()
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Categories")
        request.returnsObjectsAsFaults = false
        
        do {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let results = try context.fetch(request)
            if results.count > 0 {
                
                for result in results as! [NSManagedObject] {
                    var tempNameOfCategories: String!
                    var tempColorOfCategories: UIColor!
                    
                    if let nameCategory = result.value(forKey: "nameCategory") as? String {
                        tempNameOfCategories = nameCategory
                    }
                    if let colorData = result.value(forKey: "color") as? Data {
                        let color = UIColor.color(withData: colorData)
                        tempColorOfCategories = color
                    }
                    
                    categoryDictionary.updateValue(Category(nameOfCategory: tempNameOfCategories, colorOfCategory: tempColorOfCategories), forKey: tempNameOfCategories)
                }
            } else {
                print("No Results...")
            }
        } catch  {
            print("Couldn't fetch results")
        }
        return categoryDictionary
    }
    
    // Saving a new Category to Core Data
    func saveCategoryToCoreData () {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newTask = NSEntityDescription.insertNewObject(forEntityName: "Categories", into: context)
        newTask.setValue(self.name, forKey: "nameCategory")
        let colorData = self.color.encode()
        newTask.setValue(colorData, forKey: "color")
        
        do {
            try context.save()
            print("Saved new Category!")
        } catch {
            print("Error saving new category!: \(error)")
        }
        context.refreshAllObjects()
    }
    
    // Replacing an old category with a new one
    func modifyCategory(newCategory: Category) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Categories")
        request.returnsObjectsAsFaults = false
        request.predicate = NSPredicate(format: "nameCategory == %@", self.name)
        
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                
                let result = results[0] as! NSManagedObject
                result.setValue(newCategory.name, forKey: "nameCategory")
                let colorData = newCategory.color.encode()
                result.setValue(colorData, forKey: "color")
                do {
                    try context.save()
                }
                catch {
                    print("Failed replacing an old category!")
                }
                
            } else {
                print("No results")
            }
        } catch {
            print("Couldn't fetch results")
        }
        self.name = newCategory.name
        self.color = newCategory.color
    }
}
