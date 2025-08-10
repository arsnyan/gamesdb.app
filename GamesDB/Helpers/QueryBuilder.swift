//
//  QueryBuilder.swift
//  GamesDB
//
//  Created by Арсен Саруханян on 11.08.2025.
//

import Foundation

final class QueryBuilder {
    private init() {}
    
    static func build(searchQuery: String? = nil, fields: [String], limit: Int? = nil, offset: Int? = nil) -> String {
        var builder: [String] = [
            "fields \(fields.joined(separator: ","));",
        ]
        
        if let searchQuery {
            builder.insert("\(searchQuery);", at: 0)
        }
        
        if let limit, let offset {
            builder.append("limit \(limit);")
            builder.append("offset \(offset);")
        }
        
        return builder.joined(separator: "\n")
    }
}
