//
//  RecipesList.swift
//  Cooking Studio
//
//  Created by Apple on 3/19/20.
//  Copyright © 2020 Hieu Le. All rights reserved.
//

import UIKit
import os.log

class RecipesList: NSObject, NSCoding {
    var category: String?
    var recipeID: String?
    init?(category: String?, recipeID: String?) {
//        guard !title.isEmpty else {
//            return nil
//        }
        self.category = category
        self.recipeID = recipeID
    }
    
    struct PropertyKey {
        static let category = "category"
        static let recipeID = "recipeID"
    }
    
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(category, forKey: PropertyKey.category)
        aCoder.encode(recipeID, forKey: PropertyKey.recipeID)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
//        guard let title = aDecoder.decodeObject(forKey: PropertyKey.title) as? String else {
//            os_log("Unable to decode the title of recipe", log: OSLog.default, type: .debug)
//            return nil
//        }
        let category = aDecoder.decodeObject(forKey: PropertyKey.category) as? String
        let recipeID = aDecoder.decodeObject(forKey: PropertyKey.recipeID) as? String
        self.init(category: category, recipeID: recipeID)
    }
    
    // Storing path
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("Recipes")
}
