//
//  getBanknotes.swift
//  banknotes-reader
//
//  Created by Robert Wan on 29/11/2025.
//

import CoreData

func getBanknotes(_ callback: @escaping ([DatasetRow]) -> Void) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        callback([])
        return
    }
    let context = appDelegate.persistentContainer.newBackgroundContext()
    context.perform {
        let request = BanknoteEntity.fetchRequest()
        let entities = (try? context.fetch(request)) ?? []
        let rows: [DatasetRow] = entities.compactMap { entity in
            guard let name = entity.name else {
                return nil
            }
            return DatasetRow(
                key: entity.key,
                banknote: Banknote(name: name, url: entity.url, width: entity.width, height: entity.height),
                imageData: entity.imageData
            )
        }
        callback(rows)
    }
}
