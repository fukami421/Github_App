//
//  Repository.swift
//  Github_App
//
//  Created by 深見龍一 on 2019/12/28.
//  Copyright © 2019 深見龍一. All rights reserved.
//

import Foundation

struct Repository: Codable {
    let name: String
    let description: String? // nullである場合があるため初期値を設定
    let url: String
    let html_url: String
}
