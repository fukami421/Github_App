//
//  LoginViewModel.swift
//  Github_App
//
//  Created by 深見龍一 on 2020/01/04.
//  Copyright © 2020 深見龍一. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

final class LoginViewModel{
    

    // MARK: - Properties
    private let udf = UserDefaults.standard
    
    // MARK: - Initializers
    init() {
    }

    // MARK: - Functions
    // インクリメンタルサーチでユーザーを検索する
    func saveLoginInfo(access_token: String)
    {
        var canSave = false
//        var keepAlive = true
        let parameters:[String: Any] = [
            "access_token": access_token,
        ]
        let url = "https://api.github.com/user"
        Alamofire.request(url, method: .get, parameters: parameters)
        .validate(statusCode: 200..<300)
        .validate(contentType: ["application/json"])
        .responseJSON { response in
            switch response.result {
                case .success:
                    print("success!")
                    guard let data = response.data else {
                        return
                    }
                    let decoder = JSONDecoder()
                    do {
                        let item: Login = try decoder.decode(Login.self, from: data)
                        print(item)// followingがおかしい
                        let loginInfo: Login = Login(login: item.login, avatar_url: item.avatar_url, html_url: item.html_url, followers_url: item.followers_url, following_url: item.following_url, repos_url: item.repos_url, followers: item.followers, following: item.following)
                        Login.save(loginInfo)
                        canSave = true
                    } catch {
                        print("error:")
                        print(error)
                    }
                case .failure:
                    print("Failure!")
            }
//            keepAlive = false
        }
//        let runLoop = RunLoop.current
//        while keepAlive &&
//            runLoop.run(mode: RunLoop.Mode.default, before: NSDate(timeIntervalSinceNow: 0.1) as Date) {
//        }
//        return canSave
    }
}
