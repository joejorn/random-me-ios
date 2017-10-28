//
//  CatalogDetailViewController.swift
//  RandomMe
//
//  Created by Joe on 11.09.17.
//
//

import Foundation
import UIKit
import RealmSwift

class CatalogDetailViewController: UIViewController {
    
    @IBOutlet weak var defaultTextLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // buttons
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    
    var randomLabel: UILabel?
    var randomizer: Randomizer! = nil
    var notifications = Array<NotificationToken>()
    
    var catalog: Catalog! = nil
    var isPlaying: Bool = false

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = .default
		// clear selected row
		if let selectionIndexPath = self.tableView.indexPathForSelectedRow {
			self.tableView.deselectRow(at: selectionIndexPath, animated: animated)
		}
    }
	
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navBar = self.navigationController?.navigationBar
        navBar?.barTintColor = UIColor(hexString: catalog.color)
        navBar?.tintColor = UIColor.white
        navBar?.isTranslucent = false
		navBar?.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        navBar?.isHidden = false
        
        self.title = self.catalog.name
        
        self.notifications.append(
            catalog.addNotificationBlock { change in
                switch change {
                case .change(let properties):
                    for property in properties {
                        if property.name == "name" {
                            self.title = self.catalog.name
                        } else if property.name == "color" {
                            navBar?.barTintColor = UIColor(hexString: self.catalog.color)
                        }
                    }
                    break
                case .error(let error):
                    print("An error occurred: \(error)")
                    break
                case .deleted:
                    print("The object was deleted.")
                    self.navigationController?.popViewController(animated: true)
                    break
                }
            }
        )
        
        self.notifications.append(
            catalog.items.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
                
                switch changes {
                    
                case .initial:
                    self?.toggleDefaultText()
                    break
                    
                case .update:
                    self?.toggleDefaultText()
                    self?.randomizer.reloadItems((self?.getRandomItems())!)
                    self?.tableView.reloadData()
                    break
                    
                case .error(let error):
                    // An error occurred while opening the Realm file on the background worker thread
                    fatalError("\(error)")
                    break
                }
            }
        )
        
        self.randomizer = Randomizer(
                                items: self.getRandomItems(),
                                onChanges: { (item) in
                                    if let _label = self.randomLabel {
                                        (_label as UILabel).text = (item as! CatalogItem).name
                                    }
                                },
                                onComplete: { (item) in
                                    self.togglePlaying(nil)
                                })
    }
    
    deinit {
        for token in self.notifications {
            token.stop()
        }
    }
    
    @IBAction func togglePlaying(_ sender: Any?) {
        
        self.isPlaying = !isPlaying
        if (!isPlaying) {
            self.randomizer.cancel()
        } else {
            self.randomizer.randomize()
        }
        
        // toggle start button
        self.startButton.isEnabled = !isPlaying
        self.startButton.backgroundColor = isPlaying ? UIColor.lightGray : UIColor(hexString: "#0AE85E")
        
        // toggle stop button
        self.stopButton.isEnabled = isPlaying
        self.stopButton.backgroundColor = !isPlaying ? UIColor.lightGray : UIColor.red
        
    }
    
    func getRandomItems() -> Array<CatalogItem> {
        return catalog.items.map{$0}.filter{$0.active}
    }
    
    func toggleDefaultText() {
        
        let defaultTag = 9
        let isEmpty = catalog.items.count < 1
        
        view.subviews.forEach{
            // display default text only or other views
            $0.isHidden = ($0.tag != defaultTag) ? isEmpty:!isEmpty
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let segueId = segue.identifier else {return}
        
        // stop playing before transition begins
        if (self.isPlaying) {
            self.togglePlaying(nil)
        }
        
        if (segueId == "edit-segue") {
            let destination = segue.destination as! UINavigationController
            let formCtrl = destination.viewControllers.first as! CatalogFormViewController
            formCtrl.catalog = self.catalog
        } else if (segueId == "items-active-segue") {
            let destination = segue.destination as! ActiveCatalogItemTableViewController
            destination.dataset = self.catalog.items.map{ $0 }
        }
    }
}

extension CatalogDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let isFirst = indexPath.row < 1
        let cellIdentifier = isFirst ? "random-container": "items-container"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        
        if let textLabel = cell?.viewWithTag(20) {
            
            var str = ""
            let activeItems = self.catalog.items.filter({ $0.active })
            if self.catalog.items.count > 0 {
                str = isFirst ? activeItems.first?.name ?? "?" : "\(activeItems.count) of \(self.catalog.items.count)"
            }
            (textLabel as! UILabel).text = str
            
            if isFirst {
                self.randomLabel = textLabel as? UILabel    // assign label for random
            }
        }
    
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellIdentifier = indexPath.row < 1 ? "random-container": "items-container"
        
        // use height of cell template
        let cellHeight = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)!.bounds.height
        return cellHeight
    }
}
