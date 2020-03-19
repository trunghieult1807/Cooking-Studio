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
    func loadSampleRecipes() {
        let recipe = [
            DetailRecipe(recipeID: "Burgers", title: "a", instructions: "Hello", image: UIImage(named: "burger4"))
        ]
        for data in recipe {
            Nrecipes.append(data!)
        }
    }
}
