//
//  Login.swift
//  Github_App
//
//  Created by 深見龍一 on 2020/01/04.
//  Copyright © 2020 深見龍一. All rights reserved.
//

import Foundation

struct Login: Codable {
    let login: String
    let avatar_url: String
    let html_url: String
    let followers_url: String
    let following_url: String
    let repos_url: String
    let followers: Int
    let following: Int
    
    static let key = "login"
    
    static func save(_ value: Login!) {
         UserDefaults.standard.set(try? PropertyListEncoder().encode(value), forKey: key)
    }
    
    static func get() -> Login! {
        var userData: Login!
        if let data = UserDefaults.standard.value(forKey: key) as? Data {
            userData = try? PropertyListDecoder().decode(Login.self, from: data)
            return userData!
        }
        return Login(login: "", avatar_url: "", html_url: "", followers_url: "", following_url: "", repos_url: "", followers: 0, following: 0)
    }
}
