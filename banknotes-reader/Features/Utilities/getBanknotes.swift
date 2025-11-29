//
//  getBanknotes.swift
//  banknotes-reader
//
//  Created by Robert Wan on 29/11/2025.
//

import CoreData

func getBanknotes(_ callback: @escaping ([(key: String, banknote: Banknote, imageData: Data)]) -> Void) {
    guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        callback([])
        return
    }
    let context = appDelegate.persistentContainer.newBackgroundContext()
    context.perform {
        let request = BanknoteEntity.fetchRequest()
        let entities = (try? context.fetch(request)) ?? []
        let rows: [(key: String, banknote: Banknote, imageData: Data)] = entities.compactMap { entity in
            guard let key = entity.key, let name = entity.name, let url = entity.url, let imageData = entity.imageData else {
                return nil
            }
            return (
                key: key,
                banknote: Banknote(name: name, url: url, width: entity.width, height: entity.height),
                imageData: imageData
            )
        }
        callback(rows)
    }
}
