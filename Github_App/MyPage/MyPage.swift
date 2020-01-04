//
//  MyPage.swift
//  Github_App
//
//  Created by 深見龍一 on 2020/01/04.
//  Copyright © 2020 深見龍一. All rights reserved.
//

import Foundation

struct MyPage: Codable {
    let name: String
    let full_name: String
    let `private`: Bool
    let description: String?
}
