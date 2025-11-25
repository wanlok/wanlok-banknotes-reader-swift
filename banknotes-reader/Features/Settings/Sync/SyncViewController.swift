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

func getKeySet(_ context: NSManagedObjectContext) -> Set<String> {
    var keySet = Set<String>()
    let request: NSFetchRequest<BanknoteEntity> = BanknoteEntity.fetchRequest()
    do {
        let banknotes = try context.fetch(request)
        print("COUNT", banknotes.count)
        for banknote in banknotes {
            if let key = banknote.key {
                keySet.insert(key)
            }
        }
    } catch {}
    return keySet
}

func save(_ banknotesDict: [String: Banknote]) {
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    let keySet = getKeySet(context)
    for (key, banknote) in banknotesDict {
        if !keySet.contains(key) {
            let entity = BanknoteEntity(context: context)
            entity.key = key
            entity.name = banknote.name
            entity.url = banknote.url
            entity.width = banknote.width
            entity.height = banknote.height
        }
    }
    do {
        try context.save()
    } catch {}
}

class SyncViewController: APIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        get("https://wanlok.github.io/#/api/banknotes") { result in
            if let data = result.data(using: .utf8) {
                do {
                    let banknotes = try JSONDecoder().decode([String: Banknote].self, from: data)
                    save(banknotes)
                } catch {}
            }
        }
    }
}
