//
//  Category.swift
//  Todoey
//
//  Created by Pierre-Luc Bruyere on 2018-10-19.
//  Copyright © 2018 Pierre-Luc Bruyere. All rights reserved.
//

import Foundation
import RealmSwift

class Category : Object
{
  // Realm can dynamically update the variable if it changes
  @objc dynamic var name: String = ""
  @objc dynamic var backgroundColor: String = "FFFFFF"
  let items = List<Item>()
}
