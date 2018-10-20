//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Pierre-Luc Bruyere on 2018-10-17.
//  Copyright © 2018 Pierre-Luc Bruyere. All rights reserved.
//

import UIKit
import RealmSwift


class CategoryViewController: SwipeTableViewController
{
  // MARK: - Attributes
  private var categories : Results<Category>?

  let realm = try! Realm()

  // MARK: -

  override func viewDidLoad()
  {
    super.viewDidLoad()

    loadCategories()
  }

  // MARK: - TableView Datasource Methods

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return categories?.count ?? 1
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cell = super.tableView(tableView, cellForRowAt: indexPath)
    cell.textLabel?.text = categories?[indexPath.row].name ?? "No category name"
    return cell
  }

  // MARK: - TableView Delegate Methods

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
  {
    performSegue(withIdentifier: "goToItems", sender: self)
  }

  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    if let destinationVC = segue.destination as? TodoListViewController,
       let indexPath = tableView.indexPathForSelectedRow
    {
      destinationVC.selectedCategory = categories?[indexPath.row]
    }
  }

  // MARK: - Data Manipulation Methods

  private func loadCategories()
  {
    categories = realm.objects(Category.self)
  }

  private func save(_ category: Category)
  {
    do
    {
      try realm.write
      {
        realm.add(category)
      }
    }
    catch
    {
      print("Error saving context \(error)")
    }
  }

  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
  {
    if (editingStyle == .delete)
    {
      // handle delete (by removing the data from your array and updating the tableview)
      if let category = categories?[indexPath.row]
      {
        do
        {
          try realm.write
          {
            realm.delete(category)
          }
        }
        catch
        {
          print("Error deleting category \(error)")
        }
      }
    }
  }

  // MARK: - Add New Categories

  @IBAction func addButtonPressed(_ sender: UIBarButtonItem)
  {
    var textField = UITextField()

    let action = UIAlertAction(title: "Add Category", style: .default)
    { (action) in
      let text = textField.text!
      if text.count > 0
      {
        let newCategory = Category()
        newCategory.name = text

        self.save(newCategory)

        let index = self.categories != nil ? self.categories!.count - 1 : 0
        let indexPath = [IndexPath(item: index, section: 0)]
        self.tableView.insertRows(at: indexPath, with: .automatic)
      }
    }

    let alert = UIAlertController(title: "Add New Todoey Category", message: "", preferredStyle: .alert)
    alert.addTextField
    { (alertTextField) in
      alertTextField.placeholder = "Create new category"
      textField = alertTextField
    }
    alert.addAction(action)
    present(alert, animated: true, completion: nil)
  }
}
