//
//  RecipesSelectionVC.swift
//  Resturant
//
//  Created by Omer  on 8/21/19.
//  Copyright © 2019 Omer . All rights reserved.
//

import UIKit
import os.log

class RecipesSelectionVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectCategory: String?
    var recipes: [DetailRecipe] = []
    var recipeToPass: DetailRecipe!
    var Nrecipes = [DetailRecipe]()
    
    override func viewDidAppear(_ animated: Bool) {
        collectionView.delegate = self
        collectionView.dataSource = self
        print(selectCategory)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        collectionView.delegate = self
        collectionView.dataSource = self
        
        
        
        print("First: \(Nrecipes)")
        
        
        if let savedCategories = loadRecipes() {
            Nrecipes += savedCategories
        } else {
            loadSampleRecipes()
        }
        
        print("Here: \(Nrecipes)")
        for data in Nrecipes {
            if data.recipeID == selectCategory {
                recipes.append(data)
            }
        }
        
        // Long press to reorder
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        collectionView.addGestureRecognizer(longPressGesture)
    }
    
    
    
    
    // Long press to reorder
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        
        switch(gesture.state) {
            
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else {
                break
                
            }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case UIGestureRecognizerState.changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case UIGestureRecognizerState.ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
            
            
        }
    }
    
    
    
    @IBAction func unwindToRecipeList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? RecipesViewController, let recipe = sourceViewController.recipe {
            let newIndexPath = IndexPath(item: recipes.count, section: 0)//IndexPath(row: recipes.count, section: 0)
            print("newidx: \(newIndexPath)")
            recipes.append(recipe)
            Nrecipes.append(recipe)
            collectionView.insertItems(at: [newIndexPath])
            collectionView.reloadData()
        }
        
        print("Next: \(Nrecipes)")
        saveRecipes()
        print("Next: \(Nrecipes)")
    }
    
    
    // MARK: Core data
    
    private func saveRecipes() {
        
        let fullPath = getDocumentsDirectory().appendingPathComponent("Recipes")
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: Nrecipes, requiringSecureCoding: false)
            try data.write(to: fullPath)
            os_log("Recipes successfully saved.", log: OSLog.default, type: .debug)
        } catch {
            os_log("Failed to save recipes...", log: OSLog.default, type: .error)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func loadRecipes() -> [DetailRecipe]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: DetailRecipe.ArchiveURL.path) as? [DetailRecipe]
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recipeCell", for: indexPath) as? RecipeCell {
            let recipe = recipes[indexPath.item]
            cell.configureCell(recipe: recipe)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        let questionController = UIAlertController(title: "What u wanna do?", message: nil, preferredStyle: .alert)
        
        questionController.addAction(UIAlertAction(title: "Detail", style: .default, handler: {
            (action: UIAlertAction!) in
            self.recipeToPass = self.recipes[indexPath.item]
            self.performSegue(withIdentifier: "toRecipeDetail", sender: self)
        }))
        
        questionController.addAction(UIAlertAction(title: "Delete Person", style: .default, handler: {
            
            (action:UIAlertAction!) -> Void in
            self.collectionView.deleteItems(at: [indexPath])
            self.recipes.remove(at: indexPath.item)
            //self.collectionView.reloadData()
            
        }))
        
        present(questionController, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.bounds.width
        let cellDimension = (width / 2) - 15
        return CGSize(width: cellDimension, height: cellDimension)
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var index1: Int = 0
        var index2: Int = 0
        var count = 0
        for data in Nrecipes {
            if data == recipes[Int(sourceIndexPath.item)]{
                index1 = count
            }
            if data == recipes[Int(destinationIndexPath.item)] {
                index2 = count
            }
            count += 1
        }
        if index1 > index2 {
            let temp = Nrecipes[index1]
            for i in (index2...(index1-1)).reversed() {
                Nrecipes[i+1] = Nrecipes[i]
            }
            Nrecipes[index2] = temp
        } else if index1 < index2 {
            let temp = Nrecipes[index1]
            for i in (index1 + 1)...index2 {
                Nrecipes[i - 1] = Nrecipes[i]
            }
            Nrecipes[index2] = temp
        }
        
        let nIndex1 = Int(sourceIndexPath.item)
        let nIndex2 = Int(destinationIndexPath.item)
        if nIndex1 > nIndex2 {
            let temp = recipes[nIndex1]
            for i in (nIndex2...(nIndex1 - 1)).reversed() {
                recipes[i+1] = recipes[i]
            }
            recipes[nIndex2] = temp
        } else if nIndex1 < nIndex2 {
            let temp = recipes[nIndex1]
            for i in (nIndex1 + 1)...nIndex2 {
                recipes[i - 1] = recipes[i]
            }
            recipes[nIndex2] = temp
        }
        collectionView.reloadData()
        saveRecipes()
        print("Starting Index: \(sourceIndexPath.item)")
        print("Ending Index: \(destinationIndexPath.item)")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailsVC = segue.destination as? RecipeDetailVC {
            detailsVC.selectedRecipe = recipeToPass
        }
        if let detailsVC = segue.destination as? RecipesViewController {
            detailsVC.selectCategory = selectCategory
        }
    }
    
    // MARK: Sample recipes
    func loadSampleRecipes() {
        let recipe = [
            // MARK: Burgers
            DetailRecipe(recipeID: "Burgers", title: "Bacon Cheeseburger", instructions: "1 1/2 pounds ground beef chuck. \n4 1/2-inch cubes pepper jack cheese (about 1 ounce total) \nKosher salt and freshly ground pepper.\n1/2 tablespoon vegetable oil. \n4 slices cheddar cheese (about 2 ounces) \n4 hamburger buns. \nKetchup, mustard and/or mayonnaise, for spreading (optional)", image: UIImage(named: "burger0")),
            DetailRecipe(recipeID: "Burgers", title: "Open Face Onionator", instructions: "1 1/2 pounds ground beef chuck. \n4 1/2-inch cubes pepper jack cheese (about 1 ounce total) \nKosher salt and freshly ground pepper.\n1/2 tablespoon vegetable oil. \n4 slices cheddar cheese (about 2 ounces) \n4 hamburger buns. \nKetchup, mustard and/or mayonnaise, for spreading (optional)", image: UIImage(named: "burger1")),
            DetailRecipe(recipeID: "Burgers", title: "Classic Cheeseburger", instructions: "1 1/2 pounds ground beef chuck. \n4 1/2-inch cubes pepper jack cheese (about 1 ounce total) \nKosher salt and freshly ground pepper.\n1/2 tablespoon vegetable oil. \n4 slices cheddar cheese (about 2 ounces) \n4 hamburger buns. \nKetchup, mustard and/or mayonnaise, for spreading (optional)", image: UIImage(named: "burger2")),
            DetailRecipe(recipeID: "Burgers", title: "Red Onion Burger", instructions: "1 1/2 pounds ground beef chuck. \n4 1/2-inch cubes pepper jack cheese (about 1 ounce total) \nKosher salt and freshly ground pepper.\n1/2 tablespoon vegetable oil. \n4 slices cheddar cheese (about 2 ounces) \n4 hamburger buns. \nKetchup, mustard and/or mayonnaise, for spreading (optional)", image: UIImage(named: "burger3")),
            DetailRecipe(recipeID: "Burgers", title: "Artisanal Veggieburger", instructions: "1 1/2 pounds ground beef chuck. \n4 1/2-inch cubes pepper jack cheese (about 1 ounce total) \nKosher salt and freshly ground pepper.\n1/2 tablespoon vegetable oil. \n4 slices cheddar cheese (about 2 ounces) \n4 hamburger buns. \nKetchup, mustard and/or mayonnaise, for spreading (optional)", image: UIImage(named: "burger4")),
            DetailRecipe(recipeID: "Burgers", title: "Breakfast Cheeseburger", instructions: "1 1/2 pounds ground beef chuck. \n4 1/2-inch cubes pepper jack cheese (about 1 ounce total) \nKosher salt and freshly ground pepper.\n1/2 tablespoon vegetable oil. \n4 slices cheddar cheese (about 2 ounces) \n4 hamburger buns. \nKetchup, mustard and/or mayonnaise, for spreading (optional)", image: UIImage(named: "burger5")),
            DetailRecipe(recipeID: "Burgers", title: "Double Cheeseburger", instructions: "1 1/2 pounds ground beef chuck. \n4 1/2-inch cubes pepper jack cheese (about 1 ounce total) \nKosher salt and freshly ground pepper.\n1/2 tablespoon vegetable oil. \n4 slices cheddar cheese (about 2 ounces) \n4 hamburger buns. \nKetchup, mustard and/or mayonnaise, for spreading (optional)", image: UIImage(named: "burger6")),
            DetailRecipe(recipeID: "Burgers", title: "Bacon Cheeseburger", instructions: "1 1/2 pounds ground beef chuck. \n4 1/2-inch cubes pepper jack cheese (about 1 ounce total) \nKosher salt and freshly ground pepper.\n1/2 tablespoon vegetable oil. \n4 slices cheddar cheese (about 2 ounces) \n4 hamburger buns. \nKetchup, mustard and/or mayonnaise, for spreading (optional)", image: UIImage(named: "burger0")),
            DetailRecipe(recipeID: "Burgers", title: "Open Face Onionator", instructions: "1 1/2 pounds ground beef chuck. \n4 1/2-inch cubes pepper jack cheese (about 1 ounce total) \nKosher salt and freshly ground pepper.\n1/2 tablespoon vegetable oil. \n4 slices cheddar cheese (about 2 ounces) \n4 hamburger buns. \nKetchup, mustard and/or mayonnaise, for spreading (optional)", image: UIImage(named: "burger1")),
            DetailRecipe(recipeID: "Burgers", title: "Classic Cheeseburger", instructions: "1 1/2 pounds ground beef chuck. \n4 1/2-inch cubes pepper jack cheese (about 1 ounce total) \nKosher salt and freshly ground pepper.\n1/2 tablespoon vegetable oil. \n4 slices cheddar cheese (about 2 ounces) \n4 hamburger buns. \nKetchup, mustard and/or mayonnaise, for spreading (optional)", image: UIImage(named: "burger2")),
            DetailRecipe(recipeID: "Burgers", title: "Red Onion Burger", instructions: "1 1/2 pounds ground beef chuck. \n4 1/2-inch cubes pepper jack cheese (about 1 ounce total) \nKosher salt and freshly ground pepper.\n1/2 tablespoon vegetable oil. \n4 slices cheddar cheese (about 2 ounces) \n4 hamburger buns. \nKetchup, mustard and/or mayonnaise, for spreading (optional)", image: UIImage(named: "burger3")),
            DetailRecipe(recipeID: "Burgers", title: "Artisanal Veggieburger", instructions: "1 1/2 pounds ground beef chuck. \n4 1/2-inch cubes pepper jack cheese (about 1 ounce total) \nKosher salt and freshly ground pepper.\n1/2 tablespoon vegetable oil. \n4 slices cheddar cheese (about 2 ounces) \n4 hamburger buns. \nKetchup, mustard and/or mayonnaise, for spreading (optional)", image: UIImage(named: "burger4")),
            DetailRecipe(recipeID: "Burgers", title: "Breakfast Cheeseburger", instructions: "1 1/2 pounds ground beef chuck. \n4 1/2-inch cubes pepper jack cheese (about 1 ounce total) \nKosher salt and freshly ground pepper.\n1/2 tablespoon vegetable oil. \n4 slices cheddar cheese (about 2 ounces) \n4 hamburger buns. \nKetchup, mustard and/or mayonnaise, for spreading (optional)", image: UIImage(named: "burger5")),
            DetailRecipe(recipeID: "Burgers", title: "Double Cheeseburger", instructions: "1 1/2 pounds ground beef chuck. \n4 1/2-inch cubes pepper jack cheese (about 1 ounce total) \nKosher salt and freshly ground pepper.\n1/2 tablespoon vegetable oil. \n4 slices cheddar cheese (about 2 ounces) \n4 hamburger buns. \nKetchup, mustard and/or mayonnaise, for spreading (optional)", image: UIImage(named: "burger6")),
            
            // MARK: Pasta
            
            DetailRecipe(recipeID: "Pasta", title: "Spaghetti", instructions: "Melt butter in medium saucepan with olive oil over medium/low heat. \nAdd the garlic, cream, white pepper and bring mixture to a simmer. \nStir often. \nAdd the Parmesan cheese and simmer sauce for 8-10 minutes or until sauce has thickened and is smooth.", image: UIImage(named: "pasta0")),
            DetailRecipe(recipeID: "Pasta", title: "Tortellini", instructions: "Melt butter in medium saucepan with olive oil over medium/low heat. \nAdd the garlic, cream, white pepper and bring mixture to a simmer. \nStir often. \nAdd the Parmesan cheese and simmer sauce for 8-10 minutes or until sauce has thickened and is smooth.", image: UIImage(named: "pasta1")),
            DetailRecipe(recipeID: "Pasta", title: "Penne", instructions: "Melt butter in medium saucepan with olive oil over medium/low heat. \nAdd the garlic, cream, white pepper and bring mixture to a simmer. \nStir often. \nAdd the Parmesan cheese and simmer sauce for 8-10 minutes or until sauce has thickened and is smooth.", image: UIImage(named: "pasta2")),
            DetailRecipe(recipeID: "Pasta", title: "Ravioli", instructions: "Melt butter in medium saucepan with olive oil over medium/low heat. \nAdd the garlic, cream, white pepper and bring mixture to a simmer. \nStir often. \nAdd the Parmesan cheese and simmer sauce for 8-10 minutes or until sauce has thickened and is smooth.", image: UIImage(named: "pasta3")),
            DetailRecipe(recipeID: "Pasta", title: "Calamarata", instructions: "Melt butter in medium saucepan with olive oil over medium/low heat. \nAdd the garlic, cream, white pepper and bring mixture to a simmer. \nStir often. \nAdd the Parmesan cheese and simmer sauce for 8-10 minutes or until sauce has thickened and is smooth.", image: UIImage(named: "pasta4")),
            DetailRecipe(recipeID: "Pasta", title: "Bigoli", instructions: "Melt butter in medium saucepan with olive oil over medium/low heat. \nAdd the garlic, cream, white pepper and bring mixture to a simmer. \nStir often. \nAdd the Parmesan cheese and simmer sauce for 8-10 minutes or until sauce has thickened and is smooth.", image: UIImage(named: "pasta5")),
            DetailRecipe(recipeID: "Pasta", title: "Mezzulene", instructions: "Melt butter in medium saucepan with olive oil over medium/low heat. \nAdd the garlic, cream, white pepper and bring mixture to a simmer. \nStir often. \nAdd the Parmesan cheese and simmer sauce for 8-10 minutes or until sauce has thickened and is smooth.", image: UIImage(named: "pasta6")),
            DetailRecipe(recipeID: "Pasta", title: "Spaghetti", instructions: "Melt butter in medium saucepan with olive oil over medium/low heat. \nAdd the garlic, cream, white pepper and bring mixture to a simmer. \nStir often. \nAdd the Parmesan cheese and simmer sauce for 8-10 minutes or until sauce has thickened and is smooth.", image: UIImage(named: "pasta0")),
            DetailRecipe(recipeID: "Pasta", title: "Tortellini", instructions: "Melt butter in medium saucepan with olive oil over medium/low heat. \nAdd the garlic, cream, white pepper and bring mixture to a simmer. \nStir often. \nAdd the Parmesan cheese and simmer sauce for 8-10 minutes or until sauce has thickened and is smooth.", image: UIImage(named: "pasta1")),
            DetailRecipe(recipeID: "Pasta", title: "Penne", instructions: "Melt butter in medium saucepan with olive oil over medium/low heat. \nAdd the garlic, cream, white pepper and bring mixture to a simmer. \nStir often. \nAdd the Parmesan cheese and simmer sauce for 8-10 minutes or until sauce has thickened and is smooth.", image: UIImage(named: "pasta2")),
            DetailRecipe(recipeID: "Pasta", title: "Ravioli", instructions: "Melt butter in medium saucepan with olive oil over medium/low heat. \nAdd the garlic, cream, white pepper and bring mixture to a simmer. \nStir often. \nAdd the Parmesan cheese and simmer sauce for 8-10 minutes or until sauce has thickened and is smooth.", image: UIImage(named: "pasta3")),
            DetailRecipe(recipeID: "Pasta", title: "Calamarata", instructions: "Melt butter in medium saucepan with olive oil over medium/low heat. \nAdd the garlic, cream, white pepper and bring mixture to a simmer. \nStir often. \nAdd the Parmesan cheese and simmer sauce for 8-10 minutes or until sauce has thickened and is smooth.", image: UIImage(named: "pasta4")),
            DetailRecipe(recipeID: "Pasta", title: "Bigoli", instructions: "Melt butter in medium saucepan with olive oil over medium/low heat. \nAdd the garlic, cream, white pepper and bring mixture to a simmer. \nStir often. \nAdd the Parmesan cheese and simmer sauce for 8-10 minutes or until sauce has thickened and is smooth.", image: UIImage(named: "pasta5")),
            DetailRecipe(recipeID: "Pasta", title: "Mezzulene", instructions: "Melt butter in medium saucepan with olive oil over medium/low heat. \nAdd the garlic, cream, white pepper and bring mixture to a simmer. \nStir often. \nAdd the Parmesan cheese and simmer sauce for 8-10 minutes or until sauce has thickened and is smooth.", image: UIImage(named: "pasta6")),
            
            // MARK: Pizza
            
            DetailRecipe(recipeID: "Pizza", title: "Neapolitan Pizza", instructions: "1 1/2 cups (355 ml) warm water (105°F-115°F) \n1 package (2 1/4 teaspoons) of active dry yeast \n3 3/4 cups (490 g) bread flour \n2 Tbsp olive oil (omit if cooking pizza in a wood-fired pizza oven) \n2 teaspoons salt \n1 teaspoon sugar", image: UIImage(named: "pizza0")),
            DetailRecipe(recipeID: "Pizza", title: "Salad Pizza", instructions: "1 1/2 cups (355 ml) warm water (105°F-115°F) \n1 package (2 1/4 teaspoons) of active dry yeast \n3 3/4 cups (490 g) bread flour \n2 Tbsp olive oil (omit if cooking pizza in a wood-fired pizza oven) \n2 teaspoons salt \n1 teaspoon sugar", image: UIImage(named: "pizza1")),
            DetailRecipe(recipeID: "Pizza", title: "Thinslice Pizza", instructions: "1 1/2 cups (355 ml) warm water (105°F-115°F) \n1 package (2 1/4 teaspoons) of active dry yeast \n3 3/4 cups (490 g) bread flour \n2 Tbsp olive oil (omit if cooking pizza in a wood-fired pizza oven) \n2 teaspoons salt \n1 teaspoon sugar", image: UIImage(named: "pizza2")),
            DetailRecipe(recipeID: "Pizza", title: "Meat Lovers", instructions: "1 1/2 cups (355 ml) warm water (105°F-115°F) \n1 package (2 1/4 teaspoons) of active dry yeast \n3 3/4 cups (490 g) bread flour \n2 Tbsp olive oil (omit if cooking pizza in a wood-fired pizza oven) \n2 teaspoons salt \n1 teaspoon sugar", image: UIImage(named: "pizza3")),
            DetailRecipe(recipeID: "Pizza", title: "Pepperoni and Ham Pizza", instructions: "1 1/2 cups (355 ml) warm water (105°F-115°F) \n1 package (2 1/4 teaspoons) of active dry yeast \n3 3/4 cups (490 g) bread flour \n2 Tbsp olive oil (omit if cooking pizza in a wood-fired pizza oven) \n2 teaspoons salt \n1 teaspoon sugar", image: UIImage(named: "pizza4")),
            DetailRecipe(recipeID: "Pizza", title: "Grilled Pizza", instructions: "1 1/2 cups (355 ml) warm water (105°F-115°F) \n1 package (2 1/4 teaspoons) of active dry yeast \n3 3/4 cups (490 g) bread flour \n2 Tbsp olive oil (omit if cooking pizza in a wood-fired pizza oven) \n2 teaspoons salt \n1 teaspoon sugar", image: UIImage(named: "pizza5")),
            DetailRecipe(recipeID: "Pizza", title: "Veggies Pizza", instructions: "1 1/2 cups (355 ml) warm water (105°F-115°F) \n1 package (2 1/4 teaspoons) of active dry yeast \n3 3/4 cups (490 g) bread flour \n2 Tbsp olive oil (omit if cooking pizza in a wood-fired pizza oven) \n2 teaspoons salt \n1 teaspoon sugar", image: UIImage(named: "pizza6")),
            DetailRecipe(recipeID: "Pizza", title: "Neapolitan Pizza", instructions: "1 1/2 cups (355 ml) warm water (105°F-115°F) \n1 package (2 1/4 teaspoons) of active dry yeast \n3 3/4 cups (490 g) bread flour \n2 Tbsp olive oil (omit if cooking pizza in a wood-fired pizza oven) \n2 teaspoons salt \n1 teaspoon sugar", image: UIImage(named: "pizza0")),
            DetailRecipe(recipeID: "Pizza", title: "Salad Pizza", instructions: "1 1/2 cups (355 ml) warm water (105°F-115°F) \n1 package (2 1/4 teaspoons) of active dry yeast \n3 3/4 cups (490 g) bread flour \n2 Tbsp olive oil (omit if cooking pizza in a wood-fired pizza oven) \n2 teaspoons salt \n1 teaspoon sugar", image: UIImage(named: "pizza1")),
            DetailRecipe(recipeID: "Pizza", title: "Thinslice Pizza", instructions: "1 1/2 cups (355 ml) warm water (105°F-115°F) \n1 package (2 1/4 teaspoons) of active dry yeast \n3 3/4 cups (490 g) bread flour \n2 Tbsp olive oil (omit if cooking pizza in a wood-fired pizza oven) \n2 teaspoons salt \n1 teaspoon sugar", image: UIImage(named: "pizza2")),
            DetailRecipe(recipeID: "Pizza", title: "Meat Lovers", instructions: "1 1/2 cups (355 ml) warm water (105°F-115°F) \n1 package (2 1/4 teaspoons) of active dry yeast \n3 3/4 cups (490 g) bread flour \n2 Tbsp olive oil (omit if cooking pizza in a wood-fired pizza oven) \n2 teaspoons salt \n1 teaspoon sugar", image: UIImage(named: "pizza3")),
            DetailRecipe(recipeID: "Pizza", title: "Pepperoni and Ham Pizza", instructions: "1 1/2 cups (355 ml) warm water (105°F-115°F) \n1 package (2 1/4 teaspoons) of active dry yeast \n3 3/4 cups (490 g) bread flour \n2 Tbsp olive oil (omit if cooking pizza in a wood-fired pizza oven) \n2 teaspoons salt \n1 teaspoon sugar", image: UIImage(named: "pizza4")),
            DetailRecipe(recipeID: "Pizza", title: "Grilled Pizza", instructions: "1 1/2 cups (355 ml) warm water (105°F-115°F) \n1 package (2 1/4 teaspoons) of active dry yeast \n3 3/4 cups (490 g) bread flour \n2 Tbsp olive oil (omit if cooking pizza in a wood-fired pizza oven) \n2 teaspoons salt \n1 teaspoon sugar", image: UIImage(named: "pizza5")),
            DetailRecipe(recipeID: "Pizza", title: "Veggies Pizza", instructions: "1 1/2 cups (355 ml) warm water (105°F-115°F) \n1 package (2 1/4 teaspoons) of active dry yeast \n3 3/4 cups (490 g) bread flour \n2 Tbsp olive oil (omit if cooking pizza in a wood-fired pizza oven) \n2 teaspoons salt \n1 teaspoon sugar", image: UIImage(named: "pizza6")),
            
            // MARK: Salads
            
            DetailRecipe(recipeID: "Salads", title: "Cobb Salad", instructions: "In a jar with tight-fitting lid, combine the oil, lemon juice, garlic, salt and pepper; cover and shake well. Chill. \nIn a large serving bowl, toss the romaine, tomatoes, Swiss cheese, almonds if desired, Parmesan cheese and bacon. \nShake dressing; pour over salad and toss. Add croutons and serve immediately.", image: UIImage(named: "salad0")),
            DetailRecipe(recipeID: "Salads", title: "Salmon Salad", instructions: "In a jar with tight-fitting lid, combine the oil, lemon juice, garlic, salt and pepper; cover and shake well. Chill. \nIn a large serving bowl, toss the romaine, tomatoes, Swiss cheese, almonds if desired, Parmesan cheese and bacon. \nShake dressing; pour over salad and toss. Add croutons and serve immediately.", image: UIImage(named: "salad1")),
            DetailRecipe(recipeID: "Salads", title: "Fruit Salad", instructions: "In a jar with tight-fitting lid, combine the oil, lemon juice, garlic, salt and pepper; cover and shake well. Chill. \nIn a large serving bowl, toss the romaine, tomatoes, Swiss cheese, almonds if desired, Parmesan cheese and bacon. \nShake dressing; pour over salad and toss. Add croutons and serve immediately.", image: UIImage(named: "salad2")),
            DetailRecipe(recipeID: "Salads", title: "Fiambre", instructions: "In a jar with tight-fitting lid, combine the oil, lemon juice, garlic, salt and pepper; cover and shake well. Chill. \nIn a large serving bowl, toss the romaine, tomatoes, Swiss cheese, almonds if desired, Parmesan cheese and bacon. \nShake dressing; pour over salad and toss. Add croutons and serve immediately.", image: UIImage(named: "salad3")),
            DetailRecipe(recipeID: "Salads", title: "Purple Lettuce Salad", instructions: "In a jar with tight-fitting lid, combine the oil, lemon juice, garlic, salt and pepper; cover and shake well. Chill. \nIn a large serving bowl, toss the romaine, tomatoes, Swiss cheese, almonds if desired, Parmesan cheese and bacon. \nShake dressing; pour over salad and toss. Add croutons and serve immediately.", image: UIImage(named: "salad4")),
            DetailRecipe(recipeID: "Salads", title: "Caesar Pizza", instructions: "In a jar with tight-fitting lid, combine the oil, lemon juice, garlic, salt and pepper; cover and shake well. Chill. \nIn a large serving bowl, toss the romaine, tomatoes, Swiss cheese, almonds if desired, Parmesan cheese and bacon. \nShake dressing; pour over salad and toss. Add croutons and serve immediately.", image: UIImage(named: "salad5")),
            DetailRecipe(recipeID: "Salads", title: "Garden Salad", instructions: "In a jar with tight-fitting lid, combine the oil, lemon juice, garlic, salt and pepper; cover and shake well. Chill. \nIn a large serving bowl, toss the romaine, tomatoes, Swiss cheese, almonds if desired, Parmesan cheese and bacon. \nShake dressing; pour over salad and toss. Add croutons and serve immediately.", image: UIImage(named: "salad6")),
            DetailRecipe(recipeID: "Salads", title: "Cobb Salad", instructions: "In a jar with tight-fitting lid, combine the oil, lemon juice, garlic, salt and pepper; cover and shake well. Chill. \nIn a large serving bowl, toss the romaine, tomatoes, Swiss cheese, almonds if desired, Parmesan cheese and bacon. \nShake dressing; pour over salad and toss. Add croutons and serve immediately.", image: UIImage(named: "salad0")),
            DetailRecipe(recipeID: "Salads", title: "Salmon Salad", instructions: "In a jar with tight-fitting lid, combine the oil, lemon juice, garlic, salt and pepper; cover and shake well. Chill. \nIn a large serving bowl, toss the romaine, tomatoes, Swiss cheese, almonds if desired, Parmesan cheese and bacon. \nShake dressing; pour over salad and toss. Add croutons and serve immediately.", image: UIImage(named: "salad1")),
            DetailRecipe(recipeID: "Salads", title: "Fruit Salad", instructions: "In a jar with tight-fitting lid, combine the oil, lemon juice, garlic, salt and pepper; cover and shake well. Chill. \nIn a large serving bowl, toss the romaine, tomatoes, Swiss cheese, almonds if desired, Parmesan cheese and bacon. \nShake dressing; pour over salad and toss. Add croutons and serve immediately.", image: UIImage(named: "salad2")),
            DetailRecipe(recipeID: "Salads", title: "Fiambre", instructions: "In a jar with tight-fitting lid, combine the oil, lemon juice, garlic, salt and pepper; cover and shake well. Chill. \nIn a large serving bowl, toss the romaine, tomatoes, Swiss cheese, almonds if desired, Parmesan cheese and bacon. \nShake dressing; pour over salad and toss. Add croutons and serve immediately.", image: UIImage(named: "salad3")),
            DetailRecipe(recipeID: "Salads", title: "Purple Lettuce Salad", instructions: "In a jar with tight-fitting lid, combine the oil, lemon juice, garlic, salt and pepper; cover and shake well. Chill. \nIn a large serving bowl, toss the romaine, tomatoes, Swiss cheese, almonds if desired, Parmesan cheese and bacon. \nShake dressing; pour over salad and toss. Add croutons and serve immediately.", image: UIImage(named: "salad4")),
            DetailRecipe(recipeID: "Salads", title: "Caesar Pizza", instructions: "In a jar with tight-fitting lid, combine the oil, lemon juice, garlic, salt and pepper; cover and shake well. Chill. \nIn a large serving bowl, toss the romaine, tomatoes, Swiss cheese, almonds if desired, Parmesan cheese and bacon. \nShake dressing; pour over salad and toss. Add croutons and serve immediately.", image: UIImage(named: "salad5")),
            DetailRecipe(recipeID: "Salads", title: "Garden Salad", instructions: "In a jar with tight-fitting lid, combine the oil, lemon juice, garlic, salt and pepper; cover and shake well. Chill. \nIn a large serving bowl, toss the romaine, tomatoes, Swiss cheese, almonds if desired, Parmesan cheese and bacon. \nShake dressing; pour over salad and toss. Add croutons and serve immediately.", image: UIImage(named: "salad6")),
            
            // MARK: Sandwiches
            
            DetailRecipe(recipeID: "Sandwiches", title: "Deli Sub", instructions: "Toast the bread in a toaster, or under a broiler on both sides. Cut the lettuce leaves in half crosswise and form into 8 neat stacks. \nTo make a double-decker club: On a clean work surface, arrange 3 bread slices in a row. Spread 1 tablespoon mayonnaise over 1 side of each bread slice. Place a lettuce stack on top of the first bread slice, top with 2 tomato slices, and season with salt and pepper, to taste.", image: UIImage(named: "sandwich0")),
            DetailRecipe(recipeID: "Sandwiches", title: "Tuna Bagel", instructions: "Toast the bread in a toaster, or under a broiler on both sides. Cut the lettuce leaves in half crosswise and form into 8 neat stacks. \nTo make a double-decker club: On a clean work surface, arrange 3 bread slices in a row. Spread 1 tablespoon mayonnaise over 1 side of each bread slice. Place a lettuce stack on top of the first bread slice, top with 2 tomato slices, and season with salt and pepper, to taste.", image: UIImage(named: "sandwich1")),
            DetailRecipe(recipeID: "Sandwiches", title: "Flatbread BLT", instructions: "Toast the bread in a toaster, or under a broiler on both sides. Cut the lettuce leaves in half crosswise and form into 8 neat stacks. \nTo make a double-decker club: On a clean work surface, arrange 3 bread slices in a row. Spread 1 tablespoon mayonnaise over 1 side of each bread slice. Place a lettuce stack on top of the first bread slice, top with 2 tomato slices, and season with salt and pepper, to taste.", image: UIImage(named: "sandwich2")),
            DetailRecipe(recipeID: "Sandwiches", title: "Veggie Sandwich", instructions: "Toast the bread in a toaster, or under a broiler on both sides. Cut the lettuce leaves in half crosswise and form into 8 neat stacks. \nTo make a double-decker club: On a clean work surface, arrange 3 bread slices in a row. Spread 1 tablespoon mayonnaise over 1 side of each bread slice. Place a lettuce stack on top of the first bread slice, top with 2 tomato slices, and season with salt and pepper, to taste.", image: UIImage(named: "sandwich3")),
            DetailRecipe(recipeID: "Sandwiches", title: "Veggie Sandwich", instructions: "Toast the bread in a toaster, or under a broiler on both sides. Cut the lettuce leaves in half crosswise and form into 8 neat stacks. \nTo make a double-decker club: On a clean work surface, arrange 3 bread slices in a row. Spread 1 tablespoon mayonnaise over 1 side of each bread slice. Place a lettuce stack on top of the first bread slice, top with 2 tomato slices, and season with salt and pepper, to taste.", image: UIImage(named: "sandwich4")),
            DetailRecipe(recipeID: "Sandwiches", title: "Grilled Panini", instructions: "Toast the bread in a toaster, or under a broiler on both sides. Cut the lettuce leaves in half crosswise and form into 8 neat stacks. \nTo make a double-decker club: On a clean work surface, arrange 3 bread slices in a row. Spread 1 tablespoon mayonnaise over 1 side of each bread slice. Place a lettuce stack on top of the first bread slice, top with 2 tomato slices, and season with salt and pepper, to taste.", image: UIImage(named: "sandwich5")),
            DetailRecipe(recipeID: "Sandwiches", title: "Club Sandwich", instructions: "Toast the bread in a toaster, or under a broiler on both sides. Cut the lettuce leaves in half crosswise and form into 8 neat stacks. \nTo make a double-decker club: On a clean work surface, arrange 3 bread slices in a row. Spread 1 tablespoon mayonnaise over 1 side of each bread slice. Place a lettuce stack on top of the first bread slice, top with 2 tomato slices, and season with salt and pepper, to taste.", image: UIImage(named: "sandwich6")),
        ]
        
        
        for data in recipe {
            Nrecipes.append(data!)
        }
    }
}
