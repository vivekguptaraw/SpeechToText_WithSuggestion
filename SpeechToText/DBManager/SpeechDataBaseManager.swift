//
//  SpeechDataBaseManager.swift
//  SpeechToText
//
//  Created by Vivek Gupta on 29/05/20.
//  Copyright © 2020 Vivek Gupta. All rights reserved.
//

import Foundation


class SpeechDataBaseManager<T> {
    let dbManager: DataManagerProtocol
    
    init(db: DataManagerProtocol) {
        dbManager = db
    }
    
    func fetch<T>(_ model: T.Type, predicate: NSPredicate?, sorted: Sorted?, completion: (([T]) -> ())) where T : Storable {
        dbManager.fetch(model, predicate: predicate, sorted: sorted, completion: completion)
    }
    
    func save(object: Storable) throws {
        try dbManager.save(object: object)
    }
}
