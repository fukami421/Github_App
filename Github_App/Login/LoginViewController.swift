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
        self.navigationController?.navigationBar.barTintColor = UIColor.orange
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

        self.setUpUI()
        self.bindViewModel()
    }
    
    private func setUpUI()
    {
        let isNotFirst = udf.bool(forKey: "isNotFirst")
        let oauthToken = udf.string(forKey: "oauthToken") ?? ""
        if oauthToken == "" && isNotFirst// ログインしていない状態
        {
            self.noLoginBtn.isHidden = true
        }
    }
    
    private func bindViewModel()
    {
        // GithubのOAuth認証をする
        self.loginBtn.rx.tap
            .subscribe ({ _ in
                self.udf.set(true, forKey: "isNotFirst")
                self.oauthswift = OAuth2Swift(
                    consumerKey:    "consumerKeyを入れる",
                    consumerSecret: "consumerSecretを入れる",
                    authorizeUrl:   "https://github.com/login/oauth/authorize",
                    accessTokenUrl: "https://github.com/login/oauth/access_token",
                    responseType:   "code"
                )
                
                let _ = self.oauthswift.authorize(
                    withCallbackURL: URL(string: "Ryu1GitApp://oauth")!,
                    scope: "repo", state:"Ryu1GitApp") { result in
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
                self.udf.set(true, forKey: "isNotFirst")
                let tabBarVC = TabBarViewController.init(nibName: nil, bundle: nil)
                tabBarVC.modalPresentationStyle = .fullScreen
                self.present(tabBarVC, animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
    }
}

