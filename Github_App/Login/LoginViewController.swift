//
//  LoginViewController.swift
//  Github_App
//
//  Created by 深見龍一 on 2019/12/27.
//  Copyright © 2019 深見龍一. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import OAuthSwift

class LoginViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var noLoginBtn: UIButton!
    
    private var oauthswift: OAuth2Swift!
    private let udf = UserDefaults.standard

    fileprivate let viewModel: LoginViewModel = LoginViewModel()
    private let disposeBag = DisposeBag()

    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Login"
        self.bindViewModel()
    }
    
    private func bindViewModel()
    {
        // GithubのOAuth認証をする
        self.loginBtn.rx.tap
            .subscribe ({ _ in
                self.oauthswift = OAuth2Swift(
                    consumerKey:    "22b8bc36ee1c097f3f77",
                    consumerSecret: "ffe51515e088a2400fad727cd7aef52cfd8b6831",
                    authorizeUrl:   "https://github.com/login/oauth/authorize",
                    accessTokenUrl: "https://github.com/login/oauth/access_token",
                    responseType:   "code"
                )
                
                let _ = self.oauthswift.authorize(
                    withCallbackURL: URL(string: "Ryu1GitApp://oauth")!,
                    scope: "", state:"Ryu1GitApp") { result in
                        switch result {
                        case .success(let (credential, _, _)):
                            self.viewModel.saveLoginInfo(access_token: credential.oauthToken)
                            self.udf.set(credential.oauthToken, forKey: "oauthToken")
                            let tabBarVC = TabBarViewController.init(nibName: nil, bundle: nil)
                            tabBarVC.modalPresentationStyle = .fullScreen
                            self.present(tabBarVC, animated: true, completion: nil)
                        case .failure(let error):
                            print("failure")
                            print(error.localizedDescription)
                        }
                    }
            })
            .disposed(by: disposeBag)
        
        // タブバーを開く
        self.noLoginBtn.rx.tap
            .subscribe({ _ in
                let tabBarVC = TabBarViewController.init(nibName: nil, bundle: nil)
                tabBarVC.modalPresentationStyle = .fullScreen
                self.present(tabBarVC, animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
    }
}

