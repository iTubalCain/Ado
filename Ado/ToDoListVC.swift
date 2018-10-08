//
//  ToDoListVC.swift
//  Ado
//
//  Created by Tubal Cain on 10/7/18.
//  Copyright © 2018 Milliwaze Software. All rights reserved.
//

import UIKit

class ToDoListVC: UITableViewController {
    
    var itemArray = [String]()
    
    let defaults = UserDefaults.standard
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var savedAlertTextField = UITextField()
        let alert = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            self.itemArray.append(savedAlertTextField.text!)
            self.tableView.reloadData()
            self.defaults.set(self.itemArray, forKey: "ToDoListArray")
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Enter new item"
            savedAlertTextField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true,  completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if let savedItems = defaults.array(forKey: "ToDoListArray") as! [String]? {
            itemArray = savedItems
        }
    }
    
    // TableView Datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.item]
        return cell
    }
    
    // TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        } else {
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        tableView.deselectRow(at: indexPath, animated: true)
        
    }


} // end ToDoListVC

