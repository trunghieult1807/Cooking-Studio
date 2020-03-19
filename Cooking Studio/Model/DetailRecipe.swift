//
//  DetailRecipe.swift
//  Cooking Studio
//
//  Created by Apple on 3/17/20.
//  Copyright © 2020 Hieu Le. All rights reserved.
//

import UIKit
import os.log

class DetailRecipe: NSObject, NSCoding {
    var recipeID: String?
    var title: String
    var instructions: String?
    var image: UIImage?
    init?(recipeID: String?, title: String, instructions: String?, image: UIImage?) {
        guard !title.isEmpty else {
            return nil
        }
        self.recipeID = recipeID
        self.title = title
        self.instructions = instructions
        self.image = image
    }
    
    struct PropertyKey {
        static let recipeID = "recipeID"
        static let title = "title"
        static let instructions = "instructions"
        static let image = "image"
    }
    
    
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(recipeID, forKey: PropertyKey.recipeID)
        aCoder.encode(title, forKey: PropertyKey.title)
        aCoder.encode(instructions, forKey: PropertyKey.instructions)
        aCoder.encode(image, forKey: PropertyKey.image)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let title = aDecoder.decodeObject(forKey: PropertyKey.title) as? String else {
            os_log("Unable to decode the title of recipe", log: OSLog.default, type: .debug)
            return nil
        }
        let recipeID = aDecoder.decodeObject(forKey: PropertyKey.recipeID) as? String
        let instructions = aDecoder.decodeObject(forKey: PropertyKey.instructions) as? String
        let image = aDecoder.decodeObject(forKey: PropertyKey.image) as? UIImage
        self.init(recipeID: recipeID, title: title, instructions: instructions, image: image)
    }
    
    // Storing path
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("Recipes")
    
}
