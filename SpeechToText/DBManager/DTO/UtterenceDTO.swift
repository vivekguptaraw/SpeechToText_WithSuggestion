//
//  UtterenceDTO.swift
//  SpeechToText
//
//  Created by Vivek Gupta on 29/05/20.
//  Copyright © 2020 Vivek Gupta. All rights reserved.
//

import Foundation

protocol MappableProtocol {
    associatedtype PersistentType: Storable
    func mapToPersistentObject() -> PersistentType
    static func mapFromPeristentObjectToDTO(object: PersistentType) -> Self
}

struct UtterenceDTO {
    var text: String?
    
    init(txt: String) {
        self.text = txt
        
    }
}

extension UtterenceDTO: MappableProtocol {
    func mapToPersistentObject() -> UtterenceModel {
        let model = UtterenceModel(self.text ?? "")
        return model
    }
    
    static func mapFromPeristentObjectToDTO(object: UtterenceModel) -> UtterenceDTO {
        let dto = UtterenceDTO(txt: object.text ?? "")
        return dto
    }
    
    typealias PersistentType = UtterenceModel
    
}
