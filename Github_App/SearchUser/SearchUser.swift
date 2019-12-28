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
//    var login: String
//    var id: Int
    struct Item: Codable{
        let login: String
    }
//    enum CodingKeys: String, CodingKey {
//        case total_count
////        case login
////        case id
//    }
  
//    init()
//    {
//        self.total_count = 0
////        self.login = ""
////        self.id = 0
//    }
}
//
//struct SearchUser: Equatable {
//    let id: Int
//    let title: String
//    let url: URL
//}
//
//extension SearchUser: Decodable {
//    private enum CodingKeys: String, CodingKey {
//        case id = "pageid"
//        case title
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        self.id = try container.decode(Int.self, forKey: .id)
//        self.title = try container.decode(String.self, forKey: .title)
//        self.url = try URL(string: "https://ja.wikipedia.org/w/index.php?curid=\(id)") ??
//            { throw DecodingError
//                .dataCorrupted(.init(codingPath: [], debugDescription: "Failed to create URL"))
//            }()
//    }
//}
