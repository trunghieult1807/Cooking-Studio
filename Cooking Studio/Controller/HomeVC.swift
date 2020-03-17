//
//  ViewController.swift
//  Resturant
//
//  Created by Omer  on 8/19/19.
//  Copyright © 2019 Omer . All rights reserved.
//

import UIKit
//import CoreData
import os.log

class HomeVC: UITableViewController {
   
    var categories = [NewFoodCategories]()

    //@IBOutlet weak var tableView: UITableView!
    //var data = DataSet()
    var categortToPass: String!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        //tableView.delegate = self
        //tableView.dataSource = self
        //loadSampleCategories()
        
        if let savedCategories = loadCategories() {
            categories += savedCategories
        }
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        let tableViewEditingMode = tableView.isEditing
        
        tableView.setEditing(!tableViewEditingMode, animated: true)
    }
    
    
    
//-------------------------------------------------------
    private func saveCategories() {
        let fullPath = getDocumentsDirectory().appendingPathComponent("Categories")
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: categories, requiringSecureCoding: false)
                try data.write(to: fullPath)
                os_log("Categories successfully saved.", log: OSLog.default, type: .debug)
            } catch {
                os_log("Failed to save categories...", log: OSLog.default, type: .error)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func loadCategories() -> [NewFoodCategories]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: NewFoodCategories.ArchiveURL.path) as? [NewFoodCategories]
//        let fullPath = getDocumentsDirectory().appendingPathComponent("Categories")
//        if let nsData = NSData(contentsOf: fullPath) {
//            do {
//
//                let data = Data.init(referencing:nsData)
//
//                if let loadedCategories = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Array<NewFoodCategories> {
//                    return loadedCategories
//                }
//            } catch {
//                print("Couldn't read file.")
//                return nil
//            }
//        }
//        return nil
    }
    
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? CategoryViewController, let category = sourceViewController.categories {
            if let selectedIndexPath = tableView.indexPathForSelectedRow{
                categories[selectedIndexPath.row] = category
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
                // luu cac bua an
            
                let newIndexPath = IndexPath(row: categories.count, section: 0)
                // Add a new meal.
                categories.append(category)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
        }
        saveCategories()
    }
    
    
    
    
//-------------------------------------------------------
    
//    func createDataCategories(category: FoodCategory) {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
//
//        let managedContext = appDelegate.persistentContainer.viewContext
//
//        let entity = NSEntityDescription.entity(forEntityName: "Data", in: managedContext)!
//        let categories = NSManagedObject(entity: entity, insertInto: managedContext)
//        categories.setValue(category.title, forKeyPath: "title")
//        categories.setValue(category.imageName, forKey: "imageName")
//        do {
//            try managedContext.save()
//        } catch let error as NSError {
//            print("Could not save. \(error), \(error.userInfo)")
//        }
//    }
//
//    func retrieveDataCategories() {
//        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Data")
//        do {
//            let result = try managedContext.fetch(fetchRequest)
//            for category in result as! [NSManagedObject] {
//                data.categories.append(FoodCategory.init(title: category.value(forKey: "title") as! String, imageName: category.value(forKey: "imageName") as! String))
//            }
//        } catch {
//            print("Failed to retrieve data!")
//        }
//    }
//
//
//    private func loadSampleCategories() {
//        tableView.delegate = self
//        tableView.dataSource = self
//    }
//
//    func saveCategories() {
//
//    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return data.categories.count
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as? CategoryCell {
            cell.configureCell(category: categories[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //categortToPass = data.categories[indexPath.row].title
        categortToPass = categories[indexPath.row].title
        performSegue(withIdentifier: "toRecipeSelection", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let recipesVC = segue.destination as? RecipesSelectionVC {
            recipesVC.selectCategory = categortToPass
        }
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            categories.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedCategory = categories.remove(at: fromIndexPath.row)
        categories.insert(movedCategory, at: to.row)
        tableView.reloadData()
    }
    

}


