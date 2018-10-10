//
//  ToDoListVC.swift
//  Ado
//
//  Created by Tubal Cain on 10/7/18.
//  Copyright © 2018 Milliwaze Software. All rights reserved.
//

import CoreData
import ChameleonFramework
import UIKit

class ToDoListVC: UITableViewController {
    
    let TODO_ITEM_CELL_ID        = "ToDoItemCell"
    let TODO_LIST_ARRAY_KEY = "ToDoListArray"
    let TODO_SAVED                      = "ToDoItemsBackup.plist"

    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    // let defaults = UserDefaults.standard
    // let dataPathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("ToDoItemsBackup.plist")

    var items = [ToDoItem]()
    
    var selectedCategory: Category? {
        didSet {
            fetchItems()
        }
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
     
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var savedAlertTextField = UITextField()
        let alert    = UIAlertController(title: "New item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let item = ToDoItem(context: self.context)
            //let item = ToDoItem()                   // item.done defaults to false
            item.title    = savedAlertTextField.text!
            item.done = false
            item.parentCategory = self.selectedCategory  // set relation
            self.items.append(item)
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
    

    // MARK:- Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()
        // print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        // let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        // fetchItems()
        // searchBar.delegate = self
        //  print("dataPath: ", dataPathURL!)
        // if let savedItems = defaults.array(forKey: TODO_LIST_ARRAY_KEY) as? [ToDoItem]  {
       //    itemArray = savedItems
      // }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        title = selectedCategory?.name
        guard let cellColor = UIColor(hexString: selectedCategory?.cellColor) else { fatalError() }
        setupNavBar(categoryColor: cellColor)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        setupNavBar(categoryColor: UIColor(hexString: "1D98F6"))
    }
    
    func setupNavBar(categoryColor: UIColor) {
        guard let navBar = navigationController?.navigationBar else {  fatalError("No NavigationController") }
        navBar.barTintColor = categoryColor
        navBar.tintColor = ContrastColorOf(backgroundColor: categoryColor, returnFlat: true)
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(backgroundColor: categoryColor, returnFlat: true)]
        navBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: ContrastColorOf(backgroundColor: categoryColor, returnFlat: true)]
        searchBar.barTintColor =  categoryColor
    }
    
    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
    
    
    // MARK:- TableView Datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TODO_ITEM_CELL_ID, for: indexPath)
        cell.textLabel?.text = items[indexPath.item].title
        cell.accessoryType = items[indexPath.item].done ? .checkmark : .none
        // cell.backgroundColor = UIColor.flatYellow()?.darken(byPercentage: CGFloat(0.05 * Double(indexPath.row)))
        cell.backgroundColor = UIColor.init(hexString: selectedCategory?.cellColor).darken(byPercentage: CGFloat(0.05 * Double(indexPath.row)))
        cell.textLabel?.textColor = UIColor(contrastingBlackOrWhiteColorOn: cell.backgroundColor, isFlat: true)
        // cell.textLabel?.textColor = UIColor(complementaryFlatColorOf: cell.backgroundColor)
        return cell
    }
    
    // MARK:- TableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //  itemArray[indexPath.item].setValue("Finished", forKey: "title")
        
        // How to delete a row. Order is important. Careful changing indexPath.
        // context.delete(itemArray[indexPath.item]) // 1/ remove from context, must still saveContext()
        // itemArray.remove(at: indexPath.item)           // 2. remove item from array

        items[indexPath.item].done = !items[indexPath.item].done
        tableView.deselectRow(at: indexPath, animated: true)
        self.saveItems()
        tableView.reloadData()
    }
    
    
    // MARK: - Core Data

    private func fetchItems(with request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest(), predicate itemPredicate: NSPredicate? = nil) {
        let categoryPredicate = NSPredicate(format: "parentCategory.name matches %@",  selectedCategory!.name!)
        if  itemPredicate != nil {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, itemPredicate!])
        } else {
            request.predicate = categoryPredicate
        }
        
        do {
            items = try context.fetch(request)
            tableView.reloadData()
        } catch  {
            print("Failed to fetch: ", error)
        }
        //        // let savedItems = defaults.array(forKey: TODO_LIST_ARRAY_KEY) as? [ToDoItem]
        //        do {
        //            if let data = try? Data(contentsOf: dataPathURL!) {
        //                itemArray = try PropertyListDecoder().decode([ToDoItem].self, from: data)
        //            }
        //        } catch {
        //            print("Failed to read itemArray: ", error)
        //        }
    }
    
    // Any sort of database update MUST call saveItems to persist
    
    private func saveItems() {
        do {
            try context.save()
        } catch {
            print("Failed to save context: ", error)
        }
        tableView.reloadData()
        // self.defaults.set(self.itemArray, forKey: self.TODO_LIST_ARRAY_KEY)
        //        do {
        //            let data = try PropertyListEncoder().encode(itemArray)
        //            try data.write(to: dataPathURL!)
        //        } catch {
        //            print("Failed to write itemArray: ", error)
        //        }
    }

} // end ToDoListVC


// MARK: - Extension: SearchBar
extension ToDoListVC: UISearchBarDelegate {
        
        // MARK:- SearchBar Delegate
        
    func  searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request: NSFetchRequest<ToDoItem> = ToDoItem.fetchRequest()
        let predicate = NSPredicate(format: "title contains[cd] %@", searchBar.text!)
        // 'cd' means ignore case and diacritcal marks
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        fetchItems(with: request, predicate: predicate)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            fetchItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }

} // end extension ToDoListVC
