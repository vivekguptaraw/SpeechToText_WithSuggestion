//
//  RealmProvider.swift
//  SpeechToText
//
//  Created by Vivek Gupta on 29/05/20.
//  Copyright © 2020 Vivek Gupta. All rights reserved.
//

import Foundation

import RealmSwift

//MARK: - RealmProvider
struct RealmProvider {
    
    let configuration: Realm.Configuration
    
    internal init(config: Realm.Configuration) {
        configuration = config
    }
    
    private var realm: Realm? {
        do {
            return try Realm(configuration: configuration)
        }catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    //MARK: - Configuration
    private static let defaultConfig = Realm.Configuration(schemaVersion: 1)
    private static let mainConfig = Realm.Configuration(
        fileURL:  URL.inDocumentsFolder(fileName: "speech_vivek.realm"),
        schemaVersion: 1)
    
    
    //MARK: - Realm Instances
    public static var `default`: Realm? = {
        var config = RealmProvider.defaultConfig
        config.deleteRealmIfMigrationNeeded = true
        return RealmProvider(config: config).realm
    }()
    public static var main: Realm? = {
        return RealmProvider(config: RealmProvider.mainConfig).realm
    }()
}


extension URL {
    static func inDocumentsFolder(fileName: String) -> URL {
        return URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0], isDirectory: true)
            .appendingPathComponent(fileName)
    }
}

