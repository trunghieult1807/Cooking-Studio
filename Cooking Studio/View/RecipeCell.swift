//
//  RecipeCell.swift
//  Resturant
//
//  Created by Omer  on 8/21/19.
//  Copyright © 2019 Omer . All rights reserved.
//

import UIKit

class RecipeCell: UICollectionViewCell {
    
    @IBOutlet weak var recipeImg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        recipeImg.layer.cornerRadius = 10
    }
    
    func configureCell(recipe: Recipe){
        recipeImg.image = UIImage(named: recipe.imageName)
    }
}
