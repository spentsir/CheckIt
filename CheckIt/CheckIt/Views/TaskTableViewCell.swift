//
//  TaskTableViewCell.swift
//  CheckIt
//
//  Created by Spencer Cawley on 1/5/19.
//  Copyright © 2019 Spencer Cawley. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    
    private let categoryStripeView: UIView = {
        let v = UIView()
        v.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    private let labelDescription: UILabel = {
        let lbl = UILabel()
        lbl.font = .boldSystemFont(ofSize: 17)
        lbl.text = "Testing 1 2 3"
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.adjustsFontSizeToFitWidth = true
        return lbl
    }()
    
    private let labelCategory: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 11)
        lbl.text = "testing"
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .lightGray
        return lbl
    }()
    
    private let labelDueDate: UILabel = {
        let lbl = UILabel()
        lbl.font = UIFont.systemFont(ofSize: 11)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        lbl.textColor = .lightGray
        return lbl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayouts()
    }
    
    public func setCell(taskToShow: Task) {
        
        var dateWhenDone = Task.dateShouldBeDoneToString(date: taskToShow.completionDate)
        if dateWhenDone == "" {
            dateWhenDone = "Date not set"
        }
        var categoryName = ""
        if let categoryNameExist = taskToShow.category?.categoryName {
            categoryName = categoryNameExist
        } else {
            categoryName = "No category"
        }
        
        if taskToShow.isItDone {
            accessoryType = .checkmark
            tintColor = .black
            labelDescription.textColor = .lightGray
            let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: taskToShow.taskTitle)
            attributedString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributedString.length))
            labelDescription.attributedText = attributedString
        } else {
            accessoryType = .none
            labelDescription.textColor = .black
//            labelDescription.text = "Testing 1 2 3"
            let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: taskToShow.taskTitle)
            labelDescription.attributedText = attributeString
        }
        
        labelCategory.text = categoryName
        categoryStripeView.backgroundColor = taskToShow.category?.color
        labelDueDate.text = dateWhenDone
    }
    
    fileprivate func setupLayouts() {
        addSubview(categoryStripeView)
        addSubview(labelDescription)
        addSubview(labelCategory)
        addSubview(labelDueDate)
        
        categoryStripeView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        categoryStripeView.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        categoryStripeView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        categoryStripeView.widthAnchor.constraint(equalToConstant: 5).isActive = true
        
        labelDescription.leadingAnchor.constraint(equalTo: categoryStripeView.trailingAnchor, constant: 15).isActive = true
        labelDescription.topAnchor.constraint(equalTo: topAnchor, constant: 15).isActive = true
        labelDescription.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30).isActive = true
        
        labelCategory.leadingAnchor.constraint(equalTo: categoryStripeView.trailingAnchor, constant: 15).isActive = true
        labelCategory.topAnchor.constraint(equalTo: labelDescription.bottomAnchor, constant: 15).isActive = true
        labelCategory.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        labelCategory.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.3).isActive = true
        
        labelDueDate.leadingAnchor.constraint(equalTo: labelCategory.trailingAnchor, constant: 15).isActive = true
        labelDueDate.topAnchor.constraint(equalTo: labelDescription.bottomAnchor, constant: 15).isActive = true
        labelDueDate.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        labelDueDate.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
