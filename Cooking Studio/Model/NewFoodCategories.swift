//
//  NewFoodCategories.swift
//  Cooking Studio
//
//  Created by Apple on 3/17/20.
//  Copyright © 2020 Hieu Le. All rights reserved.
//

import UIKit
import os.log

class NewFoodCategories: NSObject, NSCoding {
    let title : String
    let image : UIImage?
    init?(title: String, image: UIImage?) {
        
        guard !title.isEmpty else {
            return nil
        }
        
        self.title = title
        self.image = image
    }
    
    struct PropertyKey {
        static let title = "title"
        static let image = "image"
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(title, forKey: PropertyKey.title)
        aCoder.encode(image, forKey: PropertyKey.image)
    }
    
    required convenience init?(coder aCoder: NSCoder) {
        guard let title = aCoder.decodeObject(forKey: PropertyKey.title) as? String else {
            os_log("Unable to decode the title of category", log: OSLog.default, type: .debug)
            return nil
        }
        
        let image = aCoder.decodeObject(forKey: PropertyKey.image) as? UIImage
        
        self.init(title: title, image: image)
    }
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("Categories")
}
