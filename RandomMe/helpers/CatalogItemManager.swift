//
//  CatalogItemManager.swift
//  RandomMe
//
//  Created by Joe on 12.09.17.
//
//

import Foundation
import RealmSwift

final class CatalogItemManager {
    
    static let service = CatalogItemManager()
    
    fileprivate var realm : Realm!
    
    private init() {
        self.realm = try! Realm()
    }
    
    
    func getNextId() -> Int {
        return (self.realm.objects(CatalogItem.self).max(ofProperty: "id") as Int? ?? 0 ) + 1
    }
    
    
    func addItem(values: [String: Any]) -> CatalogItem {
        let item = CatalogItem(value: values)
        if (item.id < 1) {
            item.id = self.getNextId()
        }
        
        try! realm.write {
            realm.add(item, update: true)
        }
        
        return item
    }
    
    
    func setItem(_ item: CatalogItem, withValues values: [String:Any]) {
        try! realm.write {
            item.setValuesForKeys(values)
        }
    }

    
    func removeItem(_ catItem: CatalogItem) {
        try! realm.write {
            self.realm.delete(catItem)
        }
    }
    
    
    
}
