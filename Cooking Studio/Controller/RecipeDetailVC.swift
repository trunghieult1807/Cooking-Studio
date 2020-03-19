//
//  RecipeDetailVC.swift
//  Resturant
//
//  Created by Omer  on 8/22/19.
//  Copyright © 2019 Omer . All rights reserved.
//

import UIKit

class RecipeDetailVC: UIViewController {

    @IBOutlet weak var recipeImg: UIImageView!
    @IBOutlet weak var recipeTitle: UILabel!
    @IBOutlet weak var recipeInstructions: UILabel!
    
    var selectedRecipe: DetailRecipe!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light

        recipeImg.image = selectedRecipe.image
        recipeTitle.text = selectedRecipe.title
        recipeInstructions.text = selectedRecipe.instructions
    }
    

}
