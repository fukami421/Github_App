//
//  Favorite.swift
//  Github_App
//
//  Created by 深見龍一 on 2020/01/02.
//  Copyright © 2020 深見龍一. All rights reserved.
//

import Foundation

struct Favorite: Codable {
    let user_name: String
    let avatar_url: String
    let is_favorite: Bool
        
    static let key = "favorite"
    
    static func save(_ value: [Favorite]!) {
         UserDefaults.standard.set(try? PropertyListEncoder().encode(value), forKey: key)
    }
    
    static func get() -> [Favorite]! {
        var userData: [Favorite]!
        if let data = UserDefaults.standard.value(forKey: key) as? Data {
            userData = try? PropertyListDecoder().decode([Favorite].self, from: data)
            return userData!
        } else {
            return []
//            return userData
        }
    }
    
    static func remove() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
