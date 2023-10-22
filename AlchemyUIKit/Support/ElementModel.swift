//
//ElementModel.swift
//  AlchemyUIKit
//
//  Created by Arseniy Zolotarev on 12.09.2023.
//

import Foundation

class ElementModel: Hashable {
    let elementName: String
    
    let imageName: String
    
    let description: String = ""
    
    var unlock: Bool
    
    var matches: [ElementModel: ElementModel] = [:]
    
    init(elementName: String, imageName: String, unlock: Bool) {
        self.elementName = elementName
        self.imageName = imageName
        self.unlock = unlock
    }
    
    static func == (lhs: ElementModel, rhs: ElementModel) -> Bool {
        // Implement the equality comparison based on your requirements.
        return lhs.elementName == rhs.elementName && lhs.imageName == rhs.imageName
    }
    
    func hash(into hasher: inout Hasher) {
        // Implement the hash calculation based on properties that define the uniqueness of an element.
        hasher.combine(elementName)
        hasher.combine(imageName)
    }
    
    func copy() -> ElementModel {
        return .init(elementName: self.elementName, imageName: self.imageName, unlock: self.unlock)
    }
}
