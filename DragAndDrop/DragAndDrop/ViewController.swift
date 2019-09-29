//
//  ViewController.swift
//  DragAndDrop
//
//  Created by Ufuk Köşker on 15.09.2019.
//  Copyright © 2019 Ufuk Köşker. All rights reserved.
//

import UIKit
import MobileCoreServices

class ViewController: UIViewController {
    
    @IBOutlet weak var leftTableView: UITableView!
    @IBOutlet weak var rightTableView: UITableView!
    
    var leftItems = [String](repeating: "Sol", count: 30)
    var rightItems = [String](repeating: "Sağ", count: 30)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        leftTableView.dragDelegate = self
        leftTableView.dropDelegate = self
        rightTableView.dragDelegate = self
        rightTableView.dropDelegate = self
        
        leftTableView.dragInteractionEnabled = true
        rightTableView.dragInteractionEnabled = true
        
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate, UITableViewDragDelegate, UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == leftTableView {
            return leftItems.count
        } else {
            return rightItems.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if tableView == leftTableView {
            cell.textLabel?.text = leftItems[indexPath.row]
        } else {
            cell.textLabel?.text = rightItems[indexPath.row]
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        leftTableView.deselectRow(at: indexPath, animated: true)
        rightTableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let string = tableView == leftTableView ? leftItems[indexPath.row] : rightItems[indexPath.row]
        guard let data = string.data(using: .utf8) else { return [] }
        let itemProvider = NSItemProvider(item: data as NSData, typeIdentifier: kUTTypePlainText as String)
        return [UIDragItem(itemProvider: itemProvider)]
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        let destinationIndexPath: IndexPath
        
        if let indexPath = coordinator.destinationIndexPath {
            destinationIndexPath = indexPath
        } else {
            let section = tableView.numberOfSections - 1
            let row = tableView.numberOfRows(inSection: section)
            destinationIndexPath = IndexPath(row: row, section: section)
        }
        
        // Sürüklenen her öğe için belirtilen sınıfın yeni bir örneğini oluşturur ve yükler.
        coordinator.session.loadObjects(ofClass: NSString.self) { items in
            // Bırakılacak olan öğeyi strings Array'ine cast ediyoruz.
            guard let strings = items as? [String] else { return }
            
            // Sürüklenen öğeleri izlemek için boş bir array oluşturuyoruz.
            var indexPaths = [IndexPath]()
            
            // Sürüklediğimiz tüm öğeler için çalışacak olan for döngüsü.(Aynı anda ne kadar öğe sürüklersek for döngüsü o kadar çalışacaktır.)
            for (index, string) in strings.enumerated() {
                // Sürüklediğimiz öğe kadar yeni bir row açmasını söyledik.
                let indexPath = IndexPath(row: destinationIndexPath.row + index, section: destinationIndexPath.section)
                
                // Sürüklenen öğeyi hangi tableView'e bırakırsak onun dizisine eklemesini söyledik.
                if tableView == self.leftTableView {
                    self.leftItems.insert(string, at: indexPath.row)
                } else {
                    self.rightItems.insert(string, at: indexPath.row)
                }
                
                // Yukarıda oluşturduğumuz boş Dizi'ye sürüklediğimiz veri sayısı kadar ekleme yaptık.
                indexPaths.append(indexPath)
            }
            
            // Bırakma işleminin yapıldığı tableView'e yeni bir row ekler.
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
}



