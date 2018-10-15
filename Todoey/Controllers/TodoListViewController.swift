//
//  ViewController.swift
//  Todoey
//
//  Created by Pierre-Luc Bruyere on 2018-10-14.
//  Copyright © 2018 Pierre-Luc Bruyere. All rights reserved.
//

import UIKit


class TodoListViewController : UITableViewController
{
  var itemArray = [Item]()

  let defaults = UserDefaults.standard
  let dataFilePath = FileManager.default.urls(for: .documentDirectory,
                                              in: .userDomainMask).first?.appendingPathComponent("Items.plist")

  private let userDefaultsKey = "TodoListArray"
  private let cellIdentifier = "ToDoItemCell"


  override func viewDidLoad()
  {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    loadItems()
  }

  //MARK - Tableview Datasource Methods

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

  //MARK - Tableview Delegate Methods

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

  //MARK - Add New Items

  @IBAction func addButtonPressed(_ sender: UIBarButtonItem)
  {
    var textField = UITextField()

    let action = UIAlertAction(title: "Add Item", style: .default)
    { (action) in
      let text = textField.text!
      if text.count > 0
      {
        let item = Item()
        item.title = text
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

  //MARK - Model Manipulation Methods

  private func saveItems()
  {
    let encoder = PropertyListEncoder()
    do
    {
      let data = try encoder.encode(itemArray)
      try data.write(to: dataFilePath!)
    }
    catch
    {
      print("\(error)")
    }
  }

  private func loadItems()
  {
    if let data = try? Data(contentsOf: dataFilePath!)
    {
      let decoder = PropertyListDecoder()
      do
      {
        itemArray = try decoder.decode([Item].self, from: data)
      }
      catch
      {
        print("\(error)")
      }
    }
  }
}

