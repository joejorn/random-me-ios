//
//  CatalogCollectionViewController.swift
//  RandomMe
//
//  Created by Joe on 18.09.17.
//
//

import Foundation
import UIKit
import RealmSwift
import SwiftIconFont

class CatalogCollectionViewController: UICollectionViewController {
    
    var helper = CatalogManager.service
    var notification: NotificationToken? = nil
    
    var dataset: Results<Catalog>!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareCustomLayout()
        
        self.dataset = self.helper.getAllCatalogs()
        self.notification = self.dataset.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            
            switch changes {
            case .initial, .update(_):
                self?.collectionView!.reloadData()
                break
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
                break
            }
        }
    }
	
	
    deinit {
        self.notification?.stop()
    }
	
	
    func prepareCustomLayout() {
        
        let numRowItems: CGFloat = 2.0
        let itemSpacing: CGFloat = 25.0
        let insetSpacing: CGFloat = 25.0
        
        let cellWidth : CGFloat = (self.collectionView!.frame.size.width - (numRowItems - 1.0) * itemSpacing - (2.0 * insetSpacing) ) / numRowItems
        let cellheight : CGFloat = 120.0
        let cellSize = CGSize(width: cellWidth , height:cellheight)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical //.horizontal
        layout.itemSize = cellSize
        layout.sectionInset = UIEdgeInsets(top: 10.0, left: insetSpacing, bottom: 40.0, right: insetSpacing)
        layout.minimumLineSpacing = itemSpacing
        layout.minimumInteritemSpacing = itemSpacing
        
        collectionView?.setCollectionViewLayout(layout, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let segueId = segue.identifier else {return}
        
        if (segueId == "detail-segue") {
            let destination = segue.destination as! CatalogDetailViewController
            
            if let cellIndexPath = collectionView?.indexPath(for: sender as! UICollectionViewCell) {
                let dataIndex = cellIndexPath.row - 1
                destination.catalog = self.dataset[dataIndex]
            }
        }
        
    }
	
	
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataset.count + 1
    }
	
	
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let isFirst = indexPath.row < 1
        let identifier = isFirst ? "add-cell":"item-cell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        if let cellLabel = cell.viewWithTag(10) {
            
            let label = cellLabel as! UILabel
            
            if isFirst {
                label.font = UIFont.icon(from: .Ionicon, ofSize: 36.0)
                label.text = String.fontIonIcon("ios-plus-empty")
            } else {
                let item = self.dataset[indexPath.row - 1]
                cell.backgroundColor = UIColor(hexString: item.color)
                
                let title = (item.name != "") ? item.name : "Untitled"
                label.text = title.uppercased()
            }
        }
        
        return cell
        
    }
	
	
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        
        if kind == UICollectionElementKindSectionHeader {
            
            return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "catalog-header", for: indexPath)
            
        } else {
            
            return UICollectionReusableView()
            
        }
    }
	
	
	@objc
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return section < 1 ? CGSize(width: collectionView.bounds.width, height: 80.0) : CGSize(width: 0, height: 0)
    }
}
