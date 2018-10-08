//
//  ToDoListVC.swift
//  Ado
//
//  Created by Tubal Cain on 10/7/18.
//  Copyright © 2018 Milliwaze Software. All rights reserved.
//

import UIKit

class ToDoListVC: UITableViewController {
    
    let TODO_ITEM_CELL_ID        = "ToDoItemCell"
    let TODO_LIST_ARRAY_KEY = "ToDoListArray"
    let TODO_SAVED                      = "ToDoItemsBackup.plist"

    // let defaults = UserDefaults.standard
    let dataPathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("ToDoItemsBackup.plist")

    var itemArray = [ToDoItem]()
    
    private func loadItems() {
        // let savedItems = defaults.array(forKey: TODO_LIST_ARRAY_KEY) as? [ToDoItem]
        do {
            if let data = try? Data(contentsOf: dataPathURL!) {
                itemArray = try PropertyListDecoder().decode([ToDoItem].self, from: data)
            }
        } catch {
            print("Failed to read itemArray: ", error)
        }
    }
    private func saveItems() {
        // self.defaults.set(self.itemArray, forKey: self.TODO_LIST_ARRAY_KEY)
        do {
            let data = try PropertyListEncoder().encode(itemArray)
            try data.write(to: dataPathURL!)
        } catch {
            print("Failed to write itemArray: ", error)
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var savedAlertTextField = UITextField()
        let alert    = UIAlertController(title: "Add new item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            let item = ToDoItem()                   // item.done defaults to false
            item.title = savedAlertTextField.text!
            self.itemArray.append(item)
            self.saveItems()
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
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
        loadItems()
        //  print("dataPath: ", dataPathURL!)
        // if let savedItems = defaults.array(forKey: TODO_LIST_ARRAY_KEY) as? [ToDoItem]  {
       //    itemArray = savedItems
      // }
    }
    
    // TableView Datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TODO_ITEM_CELL_ID, for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.item].title
        cell.accessoryType = itemArray[indexPath.item].done ? .checkmark : .none
        return cell
    }
    
    // TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        itemArray[indexPath.item].done = !itemArray[indexPath.item].done
        tableView.deselectRow(at: indexPath, animated: true)
        self.saveItems()
         tableView.reloadData()
    }


} // end ToDoListVC

