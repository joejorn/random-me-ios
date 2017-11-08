//
//  CatalogFormViewController.swift
//  RandomMe
//
//  Created by Joe on 11.09.17.
//
//

import Foundation
import UIKit
import Eureka

protocol FormController {
    func initForm()
    func submitCatalog(values: [String:Any], catalog: Catalog?) -> Catalog
    func submitCatalogItems(values: [String:Any], catalog: Catalog)
}

class CatalogFormViewController: FormViewController {
    
    // states
    fileprivate var nextItemIndex = 0
    
    // helpers
    let catalogHelper = CatalogManager.service
    let itemHelper = CatalogItemManager.service
    
    // an existing catalog as form input
    var catalog: Catalog?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nextItemIndex = self.itemHelper.getNextId()
        
        self.initForm()
    }
    
    @IBAction func onDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func onSubmit(_ sender: Any) {
        let values = self.form.values()
		
		// properties with "cat" prefix
        var catValues = self.filterKeyValues(values: values, withPrefix: "cat")
        catValues["color"] = CategoryColor.parse(colorName: catValues["color"] as! String)
        
        let _catalog = self.submitCatalog(values: catValues, catalog: self.catalog)
		
		// properties with "item" prefix
        let itemValues = self.filterKeyValues(values: values, withPrefix: "item")
        self.submitCatalogItems(values: itemValues, catalog: _catalog)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // filter key values by a given prefix
    private func filterKeyValues( values: [String: Any?], withPrefix prefix: String) -> [String:Any] {
        let relKeys = values.keys.filter{ $0.contains(prefix) } // only keys with the given prefix
        
        var newDict = [String:Any]()
        relKeys.forEach({ str in
            
            if let val = values[str] {
                let newKey = str.components(separatedBy: "_").last  // remove the prefix
                newDict[newKey!] = val  // assign new prefix with the same value
            }
        })
        
        return newDict
    }
    
}

extension CatalogFormViewController: FormController {
    
    // FORM VIEW
    /////////////////////////////////
    
    func initForm() {
        form
            +++
            Section("Catalog")
            <<< TextRow("cat_name"){ row in
                row.title = "Name"
                row.placeholder = "Enter a catalog name"
                
                if let _catalog = self.catalog {
                    row.value = _catalog.name
                }
            }
            <<< PushRow<String>("cat_color") {
                $0.title = "Color"
                $0.options = CategoryColor.palette
                $0.selectorTitle = "Choose a color"
                
                if let _catalog = self.catalog {
                    $0.value = CategoryColor.invert(hexColor: _catalog.color)
                } else {
					$0.value = $0.options?[0]
                }
			}
            
            +++
            MultivaluedSection(
                multivaluedOptions: [.Insert, .Delete],
                header: "Catalog Items",
                footer: ""
            ) {
                $0.addButtonProvider = { section in
                    return ButtonRow(){
                        $0.title = "Add New Item"
                    }.cellUpdate { cell, row in
                        cell.textLabel?.textAlignment = .left
                    }
                }
                $0.multivaluedRowToInsertAt = { index in
                    let newIndex = self.nextItemIndex
                    self.nextItemIndex = newIndex + 1   // new next index
                    return TextRow("item_\(newIndex)") {
                        $0.placeholder = "Item Title"
                    }
                }
                
                guard let _catalog = self.catalog else { return }
                
                let numItems = _catalog.items.count
                
                for i in 0..<numItems {
                    let catItem = _catalog.items[i]
                    $0 <<< TextRow("item_\(catItem.id)") {
                        $0.value = "\(catItem.name)"
                    }
                }
                
            }
            +++
            Section(){ $0.hidden = Condition.init(booleanLiteral: self.catalog == nil) }
            
            <<< ButtonRow() {
                    $0.title = "Delete Catalog"
                }
                .cellSetup { cell, row in
                    cell.tintColor = UIColor.red
                }.onCellSelection{ cell, row in
                    self.removeCatalog(catalog: self.catalog!)
                }

    }
    
    func removeCatalog(catalog: Catalog) {
        
        let alertDescription = "Are you sure your want to delete '\(catalog.name)' permanently?"
        
        let alert = UIAlertController(title: "Delete Catalog", message: alertDescription, preferredStyle: .alert)
        
        // ok button
        alert.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { _ in
            self.catalogHelper.removeCatalog(self.catalog!)
            self.onDismiss( UIButton() )
        }))
        
        // cancel button
        alert.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", comment: "Default action"), style: .cancel, handler: nil) )
        
        self.present(alert, animated: true, completion: nil)
        
    }
    

    func submitCatalog(values: [String : Any], catalog: Catalog?) -> Catalog {
        
        var _catalog: Catalog!
        if catalog != nil { // update
            
            _catalog = catalog!
            self.catalogHelper.setCatalog( _catalog, withValues: values)
            
        } else {    // new
            
            _catalog = self.catalogHelper.addCatalog(values: values)
            
        }
        
        return _catalog
    }
    
    
    func submitCatalogItems(values: [String : Any], catalog: Catalog ) {
        
        // update existing items
        /////////////////////////////
        
        catalog.items.forEach({ item in
            
            if let val = values["\(item.id)"] { // update value
                
                if ((val as! String) != item.name) {
                    self.itemHelper.setItem(item, withValues: ["name": val])
                }
                
            } else { // item has been deleted
                self.itemHelper.removeItem(item)
            }
        })
        
        
        // new items
        /////////////////////////////
        
        // ignore if no new item
        guard catalog.items.count < values.keys.count else {return}
        
        // get recent item index
        let baseIndex = self.itemHelper.getNextId()
        let newStrIndexes = values.keys.filter({ key in
            var bool = false
            if let intKey = Int(string: key) {
                bool = intKey >= baseIndex
            }
            return bool
        }).sorted()
        
        var queue = Array<CatalogItem>() // new items
        
        // create items
        newStrIndexes.forEach({ strIndex in
            
            let dict: [String:Any] = [ "id": Int(string: strIndex)!, "name": values[strIndex]! ]
            let item = self.itemHelper.addItem(values: dict)   // add new one
            queue.append(item)
        })
        
        guard queue.count > 0 else {return}
        
        // add new items to catalog
        self.catalogHelper.addItems(queue, toCatalog: catalog)
        
    }
}
