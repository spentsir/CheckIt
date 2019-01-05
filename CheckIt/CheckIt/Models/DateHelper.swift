//
//  DateHelper.swift
//  CheckIt
//
//  Created by Spencer Cawley on 1/5/19.
//  Copyright © 2019 Spencer Cawley. All rights reserved.
//

import CoreData

extension Date {
    func stringValue() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        return formatter.string(from: self)
    }
}
