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
    
    var categortToPass: String!
    
    var signal: Int = 0
    
    var dragInitialIndexPath: IndexPath?
    var dragCellSnapshot: UIView?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        if let savedCategories = loadCategories() {
            categories += savedCategories
        } else {
            loadSampleCotegories()
        }
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGesture(sender:)))
        longPress.minimumPressDuration = 0.3 // optional
        tableView.addGestureRecognizer(longPress)
        
    }
    
    @IBAction func editButtonTapped(_ sender: Any) {
        //let tableViewEditingMode = tableView.isEditing
        //tableView.setEditing(!tableViewEditingMode, animated: true)
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
    }
    
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? CategoryViewController, let category = sourceViewController.categories {
            if let selectedIndexPath = tableView.indexPathForSelectedRow{
                categories[selectedIndexPath.row] = category
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            } else {
            
                let newIndexPath = IndexPath(row: categories.count, section: 0)

                categories.append(category)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            
        }
        saveCategories()
    }
    
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
        categortToPass = categories[indexPath.row].title
        performSegue(withIdentifier: "toRecipeSelection", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let recipesVC = segue.destination as? RecipesSelectionVC {
            recipesVC.selectCategory = categortToPass
        }
    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            categories.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveCategories()
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let movedCategory = categories.remove(at: fromIndexPath.row)
        categories.insert(movedCategory, at: to.row)
        saveCategories()
        tableView.reloadData()
    }
    

    
    
    func loadSampleCotegories() {
        let category = [
            NewFoodCategories(title: "Burgers", image: UIImage(named: "burger0")),
            NewFoodCategories(title: "Pasta", image: UIImage(named: "pasta0")),
            NewFoodCategories(title: "Pizza", image: UIImage(named: "pizza0")),
            NewFoodCategories(title: "Salads", image: UIImage(named: "salad0")),
            NewFoodCategories(title: "Sandwiches", image: UIImage(named: "sandwich0"))
        ]
        for data in category {
            categories.append(data!)
        }
    }
    
    
    func tapEdit(recognizer: UITapGestureRecognizer)  {
        if recognizer.state == UIGestureRecognizer.State.ended {
            let tapLocation = recognizer.location(in: self.tableView)
            if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
                if (self.tableView.cellForRow(at: tapIndexPath) as? CategoryCell) != nil {
                    //do what you want to cell here

                }
            }
        }
    }

    
    // MARK: cell reorder / long press

    @objc func onLongPressGesture(sender: UILongPressGestureRecognizer) {
      let locationInView = sender.location(in: tableView)
      let indexPath = tableView.indexPathForRow(at: locationInView)

      if sender.state == .began {
        if indexPath != nil {
          dragInitialIndexPath = indexPath
          let cell = tableView.cellForRow(at: indexPath!)
          dragCellSnapshot = snapshotOfCell(inputView: cell!)
          var center = cell?.center
          dragCellSnapshot?.center = center!
          dragCellSnapshot?.alpha = 0.0
          tableView.addSubview(dragCellSnapshot!)

          UIView.animate(withDuration: 0.25, animations: { () -> Void in
            center?.y = locationInView.y
            self.dragCellSnapshot?.center = center!
            self.dragCellSnapshot?.transform = (self.dragCellSnapshot?.transform.scaledBy(x: 1.05, y: 1.05))!
            self.dragCellSnapshot?.alpha = 0.99
            cell?.alpha = 0.0
          }, completion: { (finished) -> Void in
            if finished {
              cell?.isHidden = true
            }
          })
        }
      } else if sender.state == .changed && dragInitialIndexPath != nil {
        var center = dragCellSnapshot?.center
        center?.y = locationInView.y
        dragCellSnapshot?.center = center!

        // to lock dragging to same section add: "&& indexPath?.section == dragInitialIndexPath?.section" to the if below
        if indexPath != nil && indexPath != dragInitialIndexPath {
          // update your data model
          let dataToMove = categories[dragInitialIndexPath!.row]
          categories.remove(at: dragInitialIndexPath!.row)
          categories.insert(dataToMove, at: indexPath!.row)

          tableView.moveRow(at: dragInitialIndexPath!, to: indexPath!)
          dragInitialIndexPath = indexPath
        }
      } else if sender.state == .ended && dragInitialIndexPath != nil {
        let cell = tableView.cellForRow(at: dragInitialIndexPath!)
        cell?.isHidden = false
        cell?.alpha = 0.0
        UIView.animate(withDuration: 0.25, animations: { () -> Void in
          self.dragCellSnapshot?.center = (cell?.center)!
          self.dragCellSnapshot?.transform = CGAffineTransform.identity
          self.dragCellSnapshot?.alpha = 0.0
          cell?.alpha = 1.0
        }, completion: { (finished) -> Void in
          if finished {
            self.dragInitialIndexPath = nil
            self.dragCellSnapshot?.removeFromSuperview()
            self.dragCellSnapshot = nil
          }
        })
      }
        saveCategories()
    }

    func snapshotOfCell(inputView: UIView) -> UIView {
      UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
      inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
      let image = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()

      let cellSnapshot = UIImageView(image: image)
      cellSnapshot.layer.masksToBounds = false
      cellSnapshot.layer.cornerRadius = 0.0
      cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
      cellSnapshot.layer.shadowRadius = 5.0
      cellSnapshot.layer.shadowOpacity = 0.4
      return cellSnapshot
    }
    
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let closeAction = UIContextualAction(style: .normal, title:  "Edit", handler: { (ac:UIContextualAction, view:UIView, success:(Bool) -> Void) in
                //print("OK, marked as Closed")
                self.performSegue(withIdentifier: "edit", sender: self)
                success(true)
            })
        
            //closeAction.image = UIImage(named: "pasta0")
            closeAction.backgroundColor = UIColor(red: 19/256, green: 161/256, blue: 3/256, alpha: 1)

            return UISwipeActionsConfiguration(actions: [closeAction])

    }
    
    
    
//    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
//
//            switch(gesture.state) {
//
//            case UIGestureRecognizerState.began:
//                guard let selectedIndexPath =  else {
//            break
//
//            }
//            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
//            case UIGestureRecognizerState.changed:
//                collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
//            case UIGestureRecognizerState.ended:
//            collectionView.endInteractiveMovement()
//            default:
//            collectionView.cancelInteractiveMovement()
//
//
//           }
//    }
    
}


