//
//  CatalogModel.swift
//  RandomMe
//
//  Created by Joe on 12.09.17.
//
//

import Foundation
import RealmSwift

class Catalog: Object {
    
    @objc dynamic var id: Int = 0    // primary key
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    
    let items = List<CatalogItem>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
