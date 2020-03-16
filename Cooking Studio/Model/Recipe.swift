//
//  Recipe.swift
//  Resturant
//
//  Created by Omer  on 8/19/19.
//  Copyright © 2019 Omer . All rights reserved.
//

import Foundation

struct Recipe {
    var title : String
    var instructions : String
    var imageName : String
    init(title: String, instructions: String, imageName: String) {
        self.title = title
        self.instructions = instructions
        self.imageName = imageName
    }
}
