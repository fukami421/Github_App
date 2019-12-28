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
    fileprivate let repositoryVC = RepositoryViewController.init(nibName: nil, bundle: nil)

    fileprivate let viewModel: SearchUserViewModel = SearchUserViewModel()
    private let disposeBag = DisposeBag()
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
        self.title = "Search User"
        self.tableView.register(UINib(nibName: "UsersTableViewCell", bundle: nil), forCellReuseIdentifier: "UsersTableViewCell")
    }
    
    private func bindViewModel()
    {
        // SearchBarの入力値をViewModelにbind
        self.searchBar.rx.text
            .bind(to: self.viewModel.inputs.searchText)
            .disposed(by: self.disposeBag)
        
        // 検索結果の個数をtitleにbind
        self.viewModel.searchResultText
            .bind(to: self.rx.title)
            .disposed(by: disposeBag)

        // セル選択時の処理をViewModelにbind
        self.tableView.rx.itemSelected
            .bind(to: self.viewModel.itemSelected)
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
        self.viewModel.userName
            .bind(to: Binder(self) { _, name in
                self.repositoryVC.title = name // 遷移先のViewのtitleをユーザー名にする
                self.navigationController?.pushViewController(self.repositoryVC, animated: true) //遷移する
            })
            .disposed(by: disposeBag)
    }
}

