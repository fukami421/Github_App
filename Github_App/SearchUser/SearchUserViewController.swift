//
//  SearchViewController.swift
//  Github_App
//
//  Created by 深見龍一 on 2019/12/27.
//  Copyright © 2019 深見龍一. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchUserViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    let activityIndicator = UIActivityIndicatorView()

    fileprivate let viewModel: SearchUserViewModel = SearchUserViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Search User"
        self.tableView.register(UINib(nibName: "UsersTableViewCell", bundle: nil), forCellReuseIdentifier: "UsersTableViewCell")

        self.activityIndicator.center = self.view.center
        self.activityIndicator.startAnimating()
        self.view.addSubview(self.activityIndicator)

        self.bindViewModel()

    }
    
    private func bindViewModel()
    {
        // SearchBarの入力値をViewModelにbind
        self.searchBar.rx.text
            .bind(to: self.viewModel.inputs.searchText)
            .disposed(by: self.disposeBag)
        
        // 検索結果の個数をtitleにbind
        self.viewModel.outputs.searchResultText
            .bind(to: self.rx.title)
            .disposed(by: disposeBag)

        // セル選択時の処理をViewModelにbind
        self.tableView.rx.itemSelected
            .bind(to: self.viewModel.inputs.itemSelected)
            .disposed(by: disposeBag)
        
        // 検索結果をtableのcellにbind
        self.viewModel.outputs.users
            .filter{ $0.count > 0 }
            .bind(to: self.tableView.rx.items){tableView, row, element in
                let cell: UsersTableViewCell = tableView.dequeueReusableCell(withIdentifier: "UsersTableViewCell")! as! UsersTableViewCell
                cell.userNameLbl.text = element.login
                let url = URL(string: element.avatar_url)
                do {
                    let data = try Data(contentsOf: url!)
                    cell.avatarImg.image = UIImage(data: data)
                }catch let err {
                     print("Error : \(err.localizedDescription)")
                }
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                return cell
        }
        .disposed(by: self.disposeBag)
        
        // 選択されたユーザーのリポジトリを表示するViewに遷移
        self.viewModel.outputs.userName
            .bind(to: Binder(self) { _, name in
                var repositoryVC: RepositoryViewController? = RepositoryViewController.init(nibName: nil, bundle: nil)

                repositoryVC!.title = name // 遷移先のViewのtitleをユーザー名にする
                self.navigationController?.pushViewController(repositoryVC!, animated: true) //遷移する
                repositoryVC = nil // メモリリークを防ぐ
            })
            .disposed(by: disposeBag)
        
        // 検索中にActivityIndicatorを回す
        self.viewModel.outputs.isLoading
            .bind(to: self.activityIndicator.rx.isHidden)
            .disposed(by: self.disposeBag)
        
        
        self.tableView.rx.contentOffset
            .map {_ in 
                let currentOffsetY = self.tableView.contentOffset.y
                let maximumOffset = self.tableView.contentSize.height - self.tableView.frame.height
                let distanceToBottom = maximumOffset - currentOffsetY
                return Double(distanceToBottom)
            }
            .bind(to: self.viewModel.inputs.distanceToBottom)
            .disposed(by: self.disposeBag)
            

//        .map(CGPoint -> Double in )
//            .subscribe { [unowned self] contentOffset in
//                let currentOffsetY = self.tableView.contentOffset.y
//                let maximumOffset = self.tableView.contentSize.height - self.tableView.bounds.size.height
//                let distanceToBottom = maximumOffset - currentOffsetY
//                if distanceToBottom < 500 {
//                    print("rx_contentOffset : \(contentOffset)")
//                }
//
//                self.viewModel.inputs.distanceToBottom
//                // contentOffset値の変化時に取得
//            }
//            .disposed(by: self.disposeBag)
    }
}

