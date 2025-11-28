//
//  SyncViewController.swift
//  banknotes-reader
//
//  Created by wanlok on 8/11/2025.
//

import UIKit
import CoreData

struct Banknote: Codable {
    let name: String
    let url: String
    let width: Double
    let height: Double
}

typealias BanknoteResponse = [String: Banknote]

func save(_ banknotes: [String: Banknote], _ appDelegate: AppDelegate, _ callback: @escaping ([(banknote: Banknote, imageData: Data)]) -> Void) {
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
            context.perform {
                let entities = (try? context.fetch(request)) ?? []
                callback(entities.compactMap { entity in
                    guard let name = entity.name,
                          let url = entity.url,
                          let imageData = entity.imageData else {
                        return nil
                    }
                    return (
                        banknote: Banknote(name: name, url: url, width: entity.width, height: entity.height),
                        imageData: imageData
                    )
                })
            }
        }
    }
}

class SyncViewController: APIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let identifier: String = "SyncViewController"
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var sections: [(
        title: String,
        rows: [(banknote: Banknote, imageData: Data)]
    )] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        tableView.dataSource = self
        tableView.delegate = self
        
        activityIndicator.isHidden = false
        tableView.isHidden = true
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            self.activityIndicator.isHidden = true
            self.tableView.isHidden = false
            return
        }
        get("https://wanlok.github.io/#/api/banknotes") { result in
            if let data = result.data(using: .utf8) {
                do {
                    let banknotes = try JSONDecoder().decode([String: Banknote].self, from: data)
                    save(banknotes, appDelegate) { banknotes in
                        self.sections = [(title: "Dummy", rows: banknotes)]
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].title
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sections[section].title == title ? 0 : 24
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: identifier)
        }
        guard let cell else {
            fatalError("tableView cellForRowAt")
        }
        let (banknote, _) = sections[indexPath.section].rows[indexPath.row]
        cell.textLabel?.text = "\(banknote.name) \(banknote.width) \(banknote.height)"
        return cell
    }
}
