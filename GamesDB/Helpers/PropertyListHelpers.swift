//
//  PropertyListHelpers.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 10.08.2025.
//

import Foundation

final class PropertyListHelpers {
    static let shared = PropertyListHelpers()
    
    private init() {}
    
    func getValue<T: Decodable>(_ type: T.Type, with id: String, from plistName: String) -> T {
        guard let url = Bundle.main.url(forResource: plistName, withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let result = plist[id] as? T
        else {
            fatalError("There were issues with loading \(id) from \(plistName).plist file")
        }
        
        return result
    }
}
