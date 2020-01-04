//
//  MyPageViewController.swift
//  Github_App
//
//  Created by 深見龍一 on 2020/01/04.
//  Copyright © 2020 深見龍一. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MyPageViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var avatarImg: UIImageView!
    @IBOutlet weak var userName: UIButton!
    @IBOutlet weak var followingLbl: UILabel!
    @IBOutlet weak var follerLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    let activityIndicator = UIActivityIndicatorView()

    private let udf = UserDefaults.standard
    private var userInfo: Login!
    
    private let disposeBag = DisposeBag()
    private let viewModel: MyPageViewModel = MyPageViewModel()

    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "MyPage"
        self.navigationController?.navigationBar.barTintColor = UIColor.orange
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

        self.userInfo = Login.get()

        self.activityIndicator.center = self.view.center
        self.activityIndicator.startAnimating()
        self.view.addSubview(self.activityIndicator)

        self.setUpUI()
        self.bindViewModel()
    }
            
    // MARK: - Functions
    
    private func setUpUI()
    {
        // avatar
        let url = URL(string: Login.get().avatar_url)
        do {
            let data = try Data(contentsOf: url!)
            self.avatarImg.image = UIImage(data: data)
        }catch let err {
            print("Error : \(err.localizedDescription)")
            self.avatarImg.image = UIImage(named: "micky") // 画像が貼れなかった時はミッキーの写真を貼る
        }
        self.avatarImg.layer.cornerRadius = 0.5 * self.avatarImg.bounds.size.width

        // ユーザーネーム
        self.userName.setTitle(self.userInfo.login, for: .normal)
        
        // following
        self.followingLbl.text = String(self.userInfo.following) + " Following"
        
        // followers
        self.follerLbl.text = String(self.userInfo.followers) + " Followers"
        print(self.udf.string(forKey: "oauthToken")!)
    }
    
    private func bindViewModel()
    {
        self.userName.rx.tap
            .subscribe({ _ in
                var webVC: WebViewController? = WebViewController.init(nibName: nil, bundle: nil)
                webVC?.repository_url = URL(string: self.userInfo.html_url)
                self.navigationController?.pushViewController(webVC!, animated: true) //遷移する
                webVC = nil // メモリリークを防ぐ
            })
            .disposed(by: disposeBag)
        
        // セル選択時の処理をViewModelにbind
        self.tableView.rx.itemSelected
            .bind(to: self.viewModel.inputs.itemSelected)
            .disposed(by: disposeBag)

        // 検索結果をtableのcellにbind
        self.viewModel.outputs.repositories
            .filter{ $0.count > 0 }
            .bind(to: self.tableView.rx.items){tableView, row, element in
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "myCell")
                cell.textLabel?.text = element.name
                cell.textLabel?.textColor = .black
                if element.private == true // privateリポジトリはリポジトリ名の色を変える
                {
                    cell.textLabel?.textColor = .blue
                }
                cell.detailTextLabel?.text = element.description
                return cell
        }
        .disposed(by: self.disposeBag)
        
        // 検索中にActivityIndicatorを回す
        self.viewModel.outputs.isLoading
            .bind(to: self.activityIndicator.rx.isHidden)
            .disposed(by: self.disposeBag)
        
        // スクロール点とtableViewの最下点の距離をviewModelにbind
        self.tableView.rx.contentOffset
            .map {_ in
                let currentOffsetY = self.tableView.contentOffset.y
                let maximumOffset = self.tableView.contentSize.height - self.tableView.frame.height
                let distanceToBottom = maximumOffset - currentOffsetY
                return Double(distanceToBottom)
            }
            .bind(to: self.viewModel.inputs.distanceToBottom)
            .disposed(by: self.disposeBag)
    }
}
