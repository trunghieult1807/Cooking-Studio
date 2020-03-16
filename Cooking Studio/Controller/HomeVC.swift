//
//  ViewController.swift
//  Resturant
//
//  Created by Omer  on 8/19/19.
//  Copyright © 2019 Omer . All rights reserved.
//

import UIKit
import CoreData
import os.log

class HomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
   

    @IBOutlet weak var tableView: UITableView!
    var data = DataSet()
    var categortToPass: String!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        //tableView.delegate = self
        //tableView.dataSource = self
        loadSampleCategories()
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        let tableViewEditingMode = tableView.isEditing
        
        tableView.setEditing(!tableViewEditingMode, animated: true)
    }
    
    
    
    func createDataCategories(category: FoodCategory) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}

        let managedContext = appDelegate.persistentContainer.viewContext

        let entity = NSEntityDescription.entity(forEntityName: "Data", in: managedContext)!
        let categories = NSManagedObject(entity: entity, insertInto: managedContext)
        categories.setValue(category.title, forKeyPath: "title")
        categories.setValue(category.imageName, forKey: "imageName")
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    func retrieveDataCategories() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Data")
        do {
            let result = try managedContext.fetch(fetchRequest)
            for category in result as! [NSManagedObject] {
                data.categories.append(FoodCategory.init(title: category.value(forKey: "title") as! String, imageName: category.value(forKey: "imageName") as! String))
            }
        } catch {
            print("Failed to retrieve data!")
        }
    }
    
    
    private func loadSampleCategories() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func saveCategories() {
        
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as? CategoryCell {
            cell.configureCell(category: data.categories[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        categortToPass = data.categories[indexPath.row].title
        performSegue(withIdentifier: "toRecipeSelection", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let recipesVC = segue.destination as? RecipesSelectionVC {
            recipesVC.selectCategory = categortToPass
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            data.categories.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedCategory = data.categories.remove(at: fromIndexPath.row)
        data.categories.insert(movedCategory, at: to.row)
        tableView.reloadData()
    }
    

}


