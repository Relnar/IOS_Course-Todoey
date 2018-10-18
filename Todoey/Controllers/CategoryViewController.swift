//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Pierre-Luc Bruyere on 2018-10-17.
//  Copyright © 2018 Pierre-Luc Bruyere. All rights reserved.
//

import UIKit
import CoreData

class CategoryViewController: UITableViewController
{
  private var categories = [Category]()
  let dataFilePath = FileManager.default.urls(for: .documentDirectory,
                                              in: .userDomainMask)
  private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

  private let cellIdentifier = "CategoryCell"

  override func viewDidLoad()
  {
    super.viewDidLoad()

    loadCategories()
  }

  // MARK: - TableView Datasource Methods

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return categories.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
    let item = categories[indexPath.row]
    cell.textLabel?.text = item.name
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
      destinationVC.selectedCategory = categories[indexPath.row]
    }
  }

  // MARK: - Data Manipulation Methods

  private func loadCategories(with request: NSFetchRequest<Category> = Category.fetchRequest())
  {
    do
    {
      categories = try context.fetch(request)
    }
    catch
    {
      print("Error fetching data from context \(error)")
    }
  }

  private func saveCategories()
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

  // MARK: - Add New Categories

  @IBAction func addButtonPressed(_ sender: UIBarButtonItem)
  {
    var textField = UITextField()

    let action = UIAlertAction(title: "Add Category", style: .default)
    { (action) in
      let text = textField.text!
      if text.count > 0
      {
        let item = Category(context: self.context)
        item.name = text
        self.categories.append(item)

        self.saveCategories()

        let indexPath = [IndexPath(item: self.categories.count - 1, section: 0)]
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
