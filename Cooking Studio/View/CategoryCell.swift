//
//  CategoryCell.swift
//  Resturant
//
//  Created by Omer  on 8/21/19.
//  Copyright © 2019 Omer . All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {
    
    @IBOutlet weak var categoryImg: UIImageView!
    
    @IBOutlet weak var categoryTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

        categoryImg.layer.cornerRadius = 8
    }

    func configureCell(category : FoodCategory) {
        
        categoryImg.image = UIImage (named: category.imageName)
        categoryTitle.text = category.title
    }
}
