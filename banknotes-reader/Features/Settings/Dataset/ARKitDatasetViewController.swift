//
//  ARKitDatasetViewController.swift
//  banknotes-reader
//
//  Created by Robert Wan on 30/11/2025.
//

import UIKit
import CoreData

typealias BanknoteResponse = [String: Banknote]

class ARKitDatasetViewController: DatasetViewController {
    func save(_ banknotes: [String: Banknote], _ callback: @escaping ([DatasetRow]) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            getBanknotes(callback)
            return
        }
        let context = appDelegate.persistentContainer.newBackgroundContext()
        context.perform {
            let request = BanknoteEntity.fetchRequest()
            let keys = Set(((try? context.fetch(request)) ?? []).compactMap { $0.key })
            
            for (key, banknote) in banknotes where !keys.contains(key) {
                let entity = BanknoteEntity(context: context)
                entity.key = key
                entity.name = banknote.name
                entity.url = banknote.url
                entity.width = banknote.width
                entity.height = banknote.height
            }
            
            do {
                try context.save()
            } catch {}
            
            let updatedEntities = (try? context.fetch(request)) ?? []
            
            let group = DispatchGroup()
            
            for entity in updatedEntities {
                guard let urlString = entity.url,
                      let url = URL(string: urlString),
                      entity.imageData == nil else { continue }
                
                group.enter()
                
                URLSession.shared.dataTask(with: url) { data, _, _ in
                    context.perform {
                        defer { group.leave() }
                        
                        guard let data = data else {
                            return
                        }
                        
                        entity.imageData = data
                        do {
                            try context.save()
                        } catch {}
                    }
                }.resume()
            }
            
            group.notify(queue: .main) {
                getBanknotes(callback)
            }
        }
    }
    
    func delete(_ key: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let context = appDelegate.persistentContainer.viewContext
        let request = BanknoteEntity.fetchRequest()
        request.predicate = NSPredicate(format: "key == %@", key)
        if let result = try? context.fetch(request).first {
            context.delete(result)
            try? context.save()
        }
    }
    
    @objc override func onSyncButtonClicked() {
        activityIndicator.isHidden = false
        tableView.isHidden = true

        get("https://wanlok.github.io/#/api/banknotes") { result in
            if let data = result.data(using: .utf8) {
                do {
                    let banknotes = try JSONDecoder().decode([String: Banknote].self, from: data)
                    self.save(banknotes) { rows in
                        self.sections = [(title: "Dataset", rows: rows)]
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            self.activityIndicator.isHidden = true
                            self.tableView.isHidden = false
                        }
                    }
                } catch {}
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        activityIndicator.isHidden = false
        tableView.isHidden = true
        
        getBanknotes() { rows in
            self.sections = [(title: "Dataset", rows: rows)]
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.activityIndicator.isHidden = true
                self.tableView.isHidden = false
            }
        }
    }
    
    func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [UIContextualAction(style: .destructive, title: "Delete") { _, _, completion in
            let key = self.sections[indexPath.section].rows[indexPath.row].key
            self.delete(key)
            tableView.beginUpdates()
            self.sections[indexPath.section].rows.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            completion(true)
        }])
    }
}
