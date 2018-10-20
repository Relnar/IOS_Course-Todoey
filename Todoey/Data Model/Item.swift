//
//  Data.swift
//  Todoey
//
//  Created by Pierre-Luc Bruyere on 2018-10-19.
//  Copyright © 2018 Pierre-Luc Bruyere. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object
{
  // Realm can dynamically update the variable if it changes
  @objc dynamic var title: String = ""
  @objc dynamic var done: Bool = false
  @objc dynamic var dateCreated: Date?
  var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
