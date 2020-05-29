//
//  DataManagerProtocol.swift
//  SpeechToText
//
//  Created by Vivek Gupta on 29/05/20.
//  Copyright © 2020 Vivek Gupta. All rights reserved.
//

import Foundation
import RealmSwift

public protocol Storable {
 
}

protocol DataManagerProtocol {
    func create<T: Storable>(_ model: T.Type, value: [T], completion: @escaping ((T) -> Void)) throws
    func save(object: Storable) throws
    func update(object: Storable, completion: @escaping ((Bool) -> Void)) throws
    func delete(object: Storable) throws
    func deleteAll<T: Storable>(_ model: T.Type) throws
    func fetch<T: Storable>(_ model: T.Type, predicate: NSPredicate?, sorted: Sorted?, completion: (([T]) -> ()))
}

extension Object: Storable {
    
}

public struct Sorted {
    var key: String
    var ascending: Bool = true
}

