//
//  SearchUser.swift
//  Github_App
//
//  Created by 深見龍一 on 2019/12/28.
//  Copyright © 2019 深見龍一. All rights reserved.
//

import Foundation

struct SearchUser: Codable {
    let total_count: Int
    let items: [Item]

    struct Item: Codable{
        let login: String
        let avatar_url: String
    }
}
