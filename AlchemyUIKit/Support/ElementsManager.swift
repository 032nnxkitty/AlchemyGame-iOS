//
//  ElementsManager.swift
//  AlchemyUIKit
//
//  Created by Arseniy Zolotarev on 13.09.2023.
//

import Foundation

protocol ElementsManager {
    func getFourBaseElements() -> (ElementModel, ElementModel, ElementModel, ElementModel)
    
    func getUnlockedElements() -> [ElementModel]
    
    func match(_ first: ElementModel, _ second: ElementModel) -> ElementModel?
}

final class ElementsManagerImp: ElementsManager {
    // MARK: Singleton
    static let shared = ElementsManagerImp()
    
    // MARK: - Base Elements
    private let water = ElementModel(elementName: "Water", imageName: "water", unlock: true)
    private let earth = ElementModel(elementName: "Earth", imageName: "earth", unlock: true)
    private let air   = ElementModel(elementName: "Air", imageName: "air", unlock: true)
    private let fire  = ElementModel(elementName: "Fire", imageName: "fire", unlock: true)
    
    // MARK: - Other Elements
    private let swamp   = ElementModel(elementName: "Swamp", imageName: "swamp", unlock: false)
    private let alcohol = ElementModel(elementName: "Alcohol", imageName: "alcohol", unlock: false)
    private let steam   = ElementModel(elementName: "Steam", imageName: "steam", unlock: false)
    private let lava    = ElementModel(elementName: "Lava", imageName: "lava", unlock: false)
    private let energy  = ElementModel(elementName: "Energy", imageName: "energy", unlock: false)
    private let dust    = ElementModel(elementName: "Dust", imageName: "dust", unlock: false)
    
    // MARK: - Elements Array
    private var allElementsArray: [ElementModel] {
        [water, earth, air, fire, swamp, alcohol, steam, lava, energy, dust]
    }
    
    // MARK: - Init
    private init() {
        
        water.matches = [
            earth: swamp,
            fire: alcohol,
            air: steam,
        ]
        
        earth.matches = [
            water: swamp,
            fire: lava,
            air: dust,
        ]
        
        air.matches = [
            water: steam,
            earth: dust,
            fire: energy,
        ]
        
        fire.matches = [
            water: alcohol,
            earth: lava,
            air: energy,
        ]
    }
    
    // MARK: - Public Methods
    func getFourBaseElements() -> (ElementModel, ElementModel, ElementModel, ElementModel) {
        return (water, earth, air, fire)
    }
    
    func getUnlockedElements() -> [ElementModel] {
        return allElementsArray.filter { $0.unlock }
    }
    
    func match(_ first: ElementModel, _ second: ElementModel) -> ElementModel? {
        if let match = first.matches[second] {
            match.unlock = true
            return match
        } else if let match = second.matches[first] {
            match.unlock = true
            return match
        } else {
            return nil
        }
    }
}
