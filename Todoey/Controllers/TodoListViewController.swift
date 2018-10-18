//
//  ViewController.swift
//  Todoey
//
//  Created by Pierre-Luc Bruyere on 2018-10-14.
//  Copyright © 2018 Pierre-Luc Bruyere. All rights reserved.
//

import UIKit
import CoreData


class TodoListViewController : UITableViewController
{
  // MARK: Attributes
  var itemArray = [Item]()
  var selectedCategory : Category?
  {
    didSet
    {
      navigationItem.title = selectedCategory?.name
      loadItems()
    }
  }

  let dataFilePath = FileManager.default.urls(for: .documentDirectory,
                                              in: .userDomainMask)
  private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

  private let cellIdentifier = "ToDoItemCell"

  @IBOutlet weak var searchBar: UISearchBar!

  // MARK: -

  override func viewDidLoad()
  {
    super.viewDidLoad()
  }

  // MARK: - Tableview Datasource Methods

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return itemArray.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    let item = itemArray[indexPath.row]
    cell.textLabel?.text = item.title
    cell.accessoryType = item.done ? .checkmark : .none
    return cell
  }

  //MARK: - Tableview Delegate Methods

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
  {
    tableView.deselectRow(at: indexPath, animated: true)
    if let cell = tableView.cellForRow(at: indexPath)
    {
      let item = itemArray[indexPath.row]
      item.done = !item.done
      cell.accessoryType = item.done ? .checkmark : .none
      saveItems()
    }
  }

  //MARK: - Add New Items

  @IBAction func addButtonPressed(_ sender: UIBarButtonItem)
  {
    var textField = UITextField()

    let action = UIAlertAction(title: "Add Item", style: .default)
    { (action) in
      let text = textField.text!
      if text.count > 0
      {
        let item = Item(context: self.context)
        item.title = text
        item.done = false
        item.parentCategory = self.selectedCategory
        self.itemArray.append(item)

        self.saveItems()

        let indexPath = [IndexPath(item: self.itemArray.count - 1, section: 0)]
        self.tableView.insertRows(at: indexPath, with: .automatic)
      }
    }

    let alert = UIAlertController(title: "Add New Todoey Item", message: "", preferredStyle: .alert)
    alert.addTextField
    { (alertTextField) in
      alertTextField.placeholder = "Create new item"
      textField = alertTextField
    }
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }

  //MARK: - Model Manipulation Methods

  private func saveItems()
  {
    do
    {
      try context.save()
    }
    catch
    {
      print("Error saving context \(error)")
    }
  }

  private func loadItems(with request: NSFetchRequest<Item> = Item.fetchRequest(), predicate: NSPredicate? = nil)
  {
    var predicates = [NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)]
    if predicate != nil
    {
      predicates.append(predicate!)
    }

    // Compound predicate that includes the filter predicate
    request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)

    do
    {
      itemArray = try context.fetch(request)
    }
    catch
    {
      print("Error fetching data from context \(error)")
    }
  }
}

//MARK: - Search bar delegate

extension TodoListViewController : UISearchBarDelegate
{
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
  {
    let request : NSFetchRequest<Item> = Item.fetchRequest()
    if (searchText.count > 0)
    {
      // [cd] = Case insensitive and accent insensitive
      let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
      request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
      loadItems(with: request, predicate: predicate)
    }
    else
    {
      loadItems(with: request)
    }
    tableView.reloadData()

    if (searchText.count == 0)
    {
      DispatchQueue.main.async
      {
        searchBar.resignFirstResponder()
      }
    }
  }
}
