//
//  ActiveCatalogItemTableViewController.swift
//  RandomMe
//
//  Created by Joe on 17.09.17.
//
//

import Foundation
import UIKit

class ActiveCatalogItemTableViewController: UITableViewController {
    
    var itemHelper = CatalogItemManager.service
    var dataset = Array<CatalogItem>()
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		UIApplication.shared.statusBarStyle = .lightContent
	}
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Available Items"
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Deselection will remove the deselected item from the random list"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataset.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "default-cell")
        
        let item = self.dataset[indexPath.row]
        cell.textLabel?.text = item.name
        cell.accessoryType = item.active ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = self.dataset[indexPath.row]
        self.itemHelper.setItem(item, withValues: ["active": !item.active])
        
        tableView.reloadRows(at: [indexPath], with: .automatic)
        
    }
}
