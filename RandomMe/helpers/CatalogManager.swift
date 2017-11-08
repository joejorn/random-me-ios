//
//  CatalogManager.swift
//  RandomMe
//
//  Created by Joe on 12.09.17.
//
//

import Foundation
import RealmSwift

final class CatalogManager {
    
    static let service = CatalogManager()
    
    fileprivate var realm : Realm!
    
    private init() {
        self.realm = try! Realm()
    }
    
    func getNextId() -> Int {
        return (self.realm.objects(Catalog.self).max(ofProperty: "id") as Int? ?? 0 ) + 1
    }
    
    func getCatalog(id catId: Int) -> Results<Catalog> {
        return self.realm.objects(Catalog.self).filter( "id == \(catId)" )
    }
    
    func getCatalogSnapshot(id catId: Int) -> Catalog? {
        var cat: Catalog? = nil;
        if (catId > 0) {
            cat = self.getCatalog(id: catId).first
        }
        return cat
    }
    
    func getAllCatalogs() -> Results<Catalog> {
        return self.realm.objects(Catalog.self)
    }
    
    
    func addCatalog(values: [String: Any]) -> Catalog {
        
        let catalog = Catalog(value: values)
        if (catalog.id < 1) {
            catalog.id = self.getNextId()
        }
        
        try! realm.write {
            realm.add(catalog, update: true)
        }
        
        return catalog
    }
    
    
    func setCatalog(_ catalog: Catalog, withValues values: [String: Any]) {
        
        try! realm.write {
            catalog.setValuesForKeys(values)
        }
        
    }
    
    
    func removeCatalog(_ catalog: Catalog) {
        try! realm.write {
            catalog.items.forEach{ self.realm.delete($0) }
            self.realm.delete(catalog)
        }
    }
    
    func addItems(_ items: [CatalogItem], toCatalog catalog: Catalog) {
        
        guard items.count > 0, catalog.id > 0 else {return}
        
        try! realm.write {
            
            for i in 0..<items.count {
                let item = items[i]
                if (item.id > 0) {  // only valid item
                    catalog.items.append(item)
                }
            }
            
        }
    }

}
