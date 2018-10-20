//
//  ViewController.swift
//  Todoey
//
//  Created by Pierre-Luc Bruyere on 2018-10-14.
//  Copyright © 2018 Pierre-Luc Bruyere. All rights reserved.
//

import UIKit
import RealmSwift


class TodoListViewController : SwipeTableViewController
{
  // MARK: - Attributes
  var todoItems = [Item]()
  var selectedCategory : Category?
  {
    didSet
    {
      navigationItem.title = selectedCategory?.name
      loadItems()
    }
  }

  private let realm = try! Realm()

  @IBOutlet weak var searchBar: UISearchBar!

  // MARK: -

  override func viewDidLoad()
  {
    super.viewDidLoad()
  }

  // MARK: - Tableview Datasource Methods

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return todoItems.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cell = super.tableView(tableView, cellForRowAt: indexPath)
    let item = todoItems[indexPath.row]
    cell.textLabel?.text = item.title
    cell.accessoryType = item.done ? .checkmark : .none
    return cell
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
  {
    if (editingStyle == .delete)
    {
      // handle delete (by removing the data from your array and updating the tableview)
      if let item = selectedCategory?.items[indexPath.row]
      {
        do
        {
          try realm.write
          {
            realm.delete(item)
            todoItems.remove(at: indexPath.row)
          }
        }
        catch
        {
          print("Error deleting item \(error)")
        }
      }
    }
  }

  //MARK: - Tableview Delegate Methods

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
  {
    tableView.deselectRow(at: indexPath, animated: true)

    if let cell = tableView.cellForRow(at: indexPath),
       let item = selectedCategory?.items[indexPath.row]
    {
      do
      {
        try realm.write
        {
          item.done = !item.done
        }
      }
      catch
      {
        print("Error saving status \(error)")
      }
      cell.accessoryType = item.done ? .checkmark : .none
    }
  }

  //MARK: - Add New Items

  @IBAction func addButtonPressed(_ sender: UIBarButtonItem)
  {
    var textField = UITextField()

    let action = UIAlertAction(title: "Add Item", style: .default)
    { (action) in
      if let currentCategory = self.selectedCategory
      {
        let text = textField.text!
        if text.count > 0
        {
          do
          {
            try self.realm.write
            {
              let item = Item()
              item.title = text
              item.done = false
              item.dateCreated = Date()
              currentCategory.items.append(item)
              self.todoItems.append(item)

              let index = self.todoItems.count
              let indexPath = [IndexPath(item: index - 1, section: 0)]
              self.tableView.insertRows(at: indexPath, with: .automatic)
            }
          }
          catch
          {
            print("Error saving context \(error)")
          }
        }
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

  private func loadItems(predicate: NSPredicate? = nil)
  {
    todoItems.removeAll()
    var iter = selectedCategory?.items.makeIterator()
    while let item = iter?.next()
    {
      todoItems.append(item)
    }
    if let userPredicate = predicate
    {
      todoItems = (todoItems.filter{ (item) in userPredicate.evaluate(with: item) })
                            .sorted { $0.title < $1.title }
    }
  }
}

//MARK: - Search bar delegate

extension TodoListViewController : UISearchBarDelegate
{
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
  {
    if (searchText.count > 0)
    {
      // [cd] = Case insensitive and accent insensitive
      let predicate = NSPredicate(format: "title CONTAINS[cd] %@", searchBar.text!)
      loadItems(predicate: predicate)
    }
    else
    {
      loadItems()
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
