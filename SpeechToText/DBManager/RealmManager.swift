//
//  RealmManager.swift
//  SpeechToText
//
//  Created by Vivek Gupta on 29/05/20.
//  Copyright © 2020 Vivek Gupta. All rights reserved.
//

import Foundation
import RealmSwift

class RealmDataManager {
    
    private let realm: Realm?
    
    init(realm: Realm?) {
        self.realm = realm
    }
}

extension RealmDataManager: DataManagerProtocol {
    func create<T>(_ model: T.Type, value: [T], completion: @escaping ((T) -> Void)) throws where T : Storable {
        guard let realm = realm else {throw RealmError.eitherRealmIsNilOrNotRealmSpecificModel}
        guard let model = model as? Object.Type else { throw RealmError.eitherRealmIsNilOrNotRealmSpecificModel }
        try realm.write  {
            let newObject = realm.create(model, value: value, update: .all) as! T
            completion(newObject)
        }
    }
    
    //MARK: - Methods
    func create<T>(_ model: T.Type, completion: @escaping ((T) -> Void)) throws where T : Storable {
        
    }
    func save(object: Storable) throws {
        guard let realm = realm, let object = object as? Object else { throw RealmError.eitherRealmIsNilOrNotRealmSpecificModel }
        try realm.write {
            realm.add(object, update: .all)
        }
    }
    func update(object: Storable, completion: @escaping ((Bool) -> Void)) throws {
        guard let realm = realm, let object = object as? Object else {
            throw RealmError.eitherRealmIsNilOrNotRealmSpecificModel
        }
        do {
            try realm.write {
                realm.add(object, update: .modified)
                completion(true)
            }
        } catch {
            completion(false)
        }
        
    }
    func delete(object: Storable) throws {
        guard let realm = realm, let object = object as? Object else { throw RealmError.eitherRealmIsNilOrNotRealmSpecificModel }
        try realm.write {
            realm.delete(object)
        }
    }
    func deleteAll<T>(_ model: T.Type) throws where T : Storable {
        guard let realm = realm, let model = model as? Object.Type else { throw RealmError.eitherRealmIsNilOrNotRealmSpecificModel }
        try realm.write {
            let objects = realm.objects(model)
            for object in objects {
                realm.delete(object)
            }
        }
    }
    func fetch<T>(_ model: T.Type, predicate: NSPredicate?, sorted: Sorted?, completion: (([T]) -> ())) where T : Storable {
        guard let realm = realm, let model = model as? Object.Type else { return }
        var objects = realm.objects(model)
        if let predicate = predicate {
            objects = objects.filter(predicate)
        }
        if let sorted = sorted {
            objects = objects.sorted(byKeyPath: sorted.key, ascending: sorted.ascending)
        }
        completion(objects.compactMap { $0 as? T })
    }
    
}

enum RealmError: Error {
    case eitherRealmIsNilOrNotRealmSpecificModel
}

extension RealmError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .eitherRealmIsNilOrNotRealmSpecificModel:
            return NSLocalizedString("eitherRealmIsNilOrNotRealmSpecificModel", comment: "eitherRealmIsNilOrNotRealmSpecificModel")
        }
    }
}

