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

func save(_ banknotesDict: [String: Banknote], _ appDelegate: AppDelegate) {
    let context = appDelegate.persistentContainer.newBackgroundContext()
    context.perform {
        let request = BanknoteEntity.fetchRequest()
        let existing = (try? context.fetch(request)) ?? []
        let existingKeys = Set(existing.compactMap { $0.key })
        
        print(existingKeys.count)
        
        for (key, banknote) in banknotesDict where !existingKeys.contains(key) {
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
            print("Download completed")
        }
    }
}

class SyncViewController: APIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        get("https://wanlok.github.io/#/api/banknotes") { result in
            if let data = result.data(using: .utf8) {
                do {
                    let banknotes = try JSONDecoder().decode([String: Banknote].self, from: data)
                    save(banknotes, appDelegate)
                } catch {}
            }
        }
    }
}
