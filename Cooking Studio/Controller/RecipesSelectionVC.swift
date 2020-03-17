//
//  RecipesSelectionVC.swift
//  Resturant
//
//  Created by Omer  on 8/21/19.
//  Copyright © 2019 Omer . All rights reserved.
//

import UIKit
//import CoreData

class RecipesSelectionVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
   
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectCategory: String!
    var recipes: [Recipe]!
    let data = DataSet()
    var recipeToPass: Recipe!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        loadSampleRecipes()
        recipes = data.getRecipes(forCategoryTitle: selectCategory)
        
        ///
        
         let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
         collectionView.addGestureRecognizer(longPressGesture)
    }
    
    
    
    @IBAction func editButtonTapped(_ sender: Any) {
        
    }
    
    
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
    
    
    private func loadSampleRecipes() {
        collectionView.delegate = self
        collectionView.dataSource = self        
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.bounds.width
        let cellDimension = (width / 2) - 15
        return CGSize(width: cellDimension, height: cellDimension)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailsVC = segue.destination as? RecipeDetailVC {
            detailsVC.selectedRecipe = recipeToPass
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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
    
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
       return true
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        print("Starting Index: \(sourceIndexPath.item)")
        print("Ending Index: \(destinationIndexPath.item)")
    }
    
}
