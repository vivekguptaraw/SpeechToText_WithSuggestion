//
//  UtterenceModel.swift
//  SpeechToText
//
//  Created by Vivek Gupta on 29/05/20.
//  Copyright © 2020 Vivek Gupta. All rights reserved.
//

import Foundation
import RealmSwift

class UtterenceModel: Object {
    @objc dynamic var text: String?
    
    override static func primaryKey() -> String? {
        return "text"
    }
    
    convenience init(_ text: String) {
        self.init()
        self.text = text
    }
    
}
