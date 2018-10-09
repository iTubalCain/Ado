//
//  CategoryVC.swift
//  Ado
//
//  Created by Tubal Cain on 10/9/18.
//  Copyright © 2018 Milliwaze Software. All rights reserved.
//

import CoreData
import UIKit

class CategoryVC: UITableViewController {

    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var savedAlertTextField = UITextField()
        let alert    = UIAlertController(title: "Add new category", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let category = Category(context: self.context)
            category.name  = savedAlertTextField.text!
            self.categories.append(category)
            self.saveCategories()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter new category"
            savedAlertTextField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true,  completion: nil)
    }
    
    let GO_TO_SEGUE_ID = "goToItems"
    let TODO_CATEGORY_CELL_ID = "CategoryCell"
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var categories = [Category]()


    // MARK: - Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCategories()
    }
    

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TODO_CATEGORY_CELL_ID, for: indexPath)
        cell.textLabel?.text = categories[indexPath.item].name
        return cell
    }
    
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: GO_TO_SEGUE_ID, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ToDoListVC
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedCategory =  categories[indexPath.item]
        }
    }
    
    
    // MARK: - Core Data
    
    private func fetchCategories(with request: NSFetchRequest<Category> = Category.fetchRequest()) {
        do {
            categories = try context.fetch(request)
            tableView.reloadData()
        } catch  {
            print("Failed to fetch: ", error)
        }
    }
    
    private func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: ", error)
        }
        tableView.reloadData()
    }


} // end CategoryVC
