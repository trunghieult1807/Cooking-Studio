//
//  RecipesViewController.swift
//  Cooking Studio
//
//  Created by Apple on 3/19/20.
//  Copyright © 2020 Hieu Le. All rights reserved.
//

import UIKit
import os.log

class RecipesViewController: ViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var selectCategory: String?
    var recipe: DetailRecipe?

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var instructionTextView: UITextView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleTextField.delegate = self
        if let  recipe = recipe {
            titleTextField.text = recipe.title
            imageView.image = recipe.image
            instructionTextView.text = recipe.instructions
            
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //centerName.constant -= view.bounds.width
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIView.animate(withDuration: 0.5, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            //self.centerName.constant += self.view.bounds.width
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
    }
    
    
    
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        titleTextField.resignFirstResponder()
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: false , completion:  nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: false, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }

        // Set photoImageView to display the selected image.
        imageView.image = selectedImage

        // Dismiss the picker.
        dismiss(animated: false, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        // cấu hình bộ điều khiển chế độ xem đích khi nhấn nút lưu
        guard let button = sender as? UIBarButtonItem, button == saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default,type: .debug)
            return
        }
        let title = titleTextField.text ?? ""
        let image = imageView.image
        let instructions = instructionTextView.text
        let recipeID = selectCategory
 
        recipe = DetailRecipe(recipeID: recipeID, title: title, instructions: instructions, image: image)
        
    }
}
