//
//  SpeechViewModel.swift
//  SpeechToText
//
//  Created by Vivek Gupta on 29/05/20.
//  Copyright © 2020 Vivek Gupta. All rights reserved.
//

import Foundation


protocol SpeechDBProtocol {
    func getDataMatchedBy(query: String, completion: @escaping (([UtterenceDTO]) -> Void))
    func saveData(word: String, completion: @escaping ((UtterenceModel) -> Void))
}


class SpeechViewModel: SpeechDataBaseManager<Storable> {
    init() {
        let dbManager = RealmDataManager(realm: RealmProvider.main)
        super.init(db: dbManager)
    }
    
}

extension SpeechViewModel: SpeechDBProtocol {
    func saveData(word: String, completion: @escaping ((UtterenceModel) -> Void)) {
        let model = UtterenceModel(word)
        do {
            try super.save(object: model)
            completion(model)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getDataMatchedBy(query: String, completion: @escaping (([UtterenceDTO]) -> Void)) {
        let words = query.split(separator: " ")
        var mutableArrayPredicates = [NSPredicate]()
        for obj in words {
            let predicate = NSPredicate(format: "%K CONTAINS[cd] %@", argumentArray: ["text", obj])
            mutableArrayPredicates.append(predicate)
        }
        let finalPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: mutableArrayPredicates)
        let sorted = Sorted(key: "text", ascending: true)
        super.fetch(UtterenceModel.self, predicate: finalPredicate, sorted: sorted) { (resultArray) in
            let dtos = resultArray.map {
                UtterenceDTO.mapFromPeristentObjectToDTO(object: $0)
            }
            completion(dtos)
            
        }
    }
    
    
}
