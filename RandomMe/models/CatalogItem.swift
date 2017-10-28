//
//  CatalogItem.swift
//  RandomMe
//
//  Created by Joe on 12.09.17.
//
//

import Foundation
import RealmSwift

class CatalogItem: Object {
    
    @objc dynamic var id: Int = 0    // primary key
    @objc dynamic var name: String = ""
    @objc dynamic var active: Bool = true
    let catalog = LinkingObjects(fromType: Catalog.self, property: "items")
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["id"]
    }
}
