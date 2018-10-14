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
  var itemArray = ["Find Mike", "Buy Eggos", "Destroy Demogorgon"]


  override func viewDidLoad()
  {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
  }

  //MARK - Tableview Datasource Methods

  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
  {
    return itemArray.count
  }

  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
  {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
    cell.textLabel?.text = itemArray[indexPath.row]
    return cell
  }

  //MARK - Tableview Delegate Methods

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
  {
    tableView.deselectRow(at: indexPath, animated: true)
    if let cell = tableView.cellForRow(at: indexPath)
    {
      cell.accessoryType = cell.accessoryType == .checkmark ? .none : .checkmark
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
        self.itemArray.append(text)

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
}

