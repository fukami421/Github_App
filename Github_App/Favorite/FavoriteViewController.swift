//
//  FavoriteViewController.swift
//  Github_App
//
//  Created by 深見龍一 on 2020/01/02.
//  Copyright © 2020 深見龍一. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FavoriteViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    
    private let refreshCtl: UIRefreshControl = UIRefreshControl()
    
    private let viewModel: FavoriteUserViewModel = FavoriteUserViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Favorite User"
        self.tableView.register(UINib(nibName: "UsersTableViewCell", bundle: nil), forCellReuseIdentifier: "UsersTableViewCell")
        self.tableView.refreshControl = self.refreshCtl

        self.bindViewModel()
    }

    private func bindViewModel()
    {
        // セル選択時の処理をViewModelにbind
        self.tableView.rx.itemSelected
            .bind(to: self.viewModel.inputs.itemSelected)
            .disposed(by: disposeBag)
        
        self.refreshCtl.rx.controlEvent(.valueChanged)
            .bind(to: self.viewModel.inputs.refreshTrigger)
            .disposed(by: self.disposeBag)
                
        // お気に入りのUserをtableのcellにbind
        self.viewModel.outputs.favoriteUsers
            .filter{ $0.count > 0 }
            .bind(to: self.tableView.rx.items){tableView, row, element in
                let cell: UsersTableViewCell = tableView.dequeueReusableCell(withIdentifier: "UsersTableViewCell")! as! UsersTableViewCell
                cell.userNameLbl.text = element.user_name
                let url = URL(string: element.avatar_url)
                do {
                    let data = try Data(contentsOf: url!)
                    cell.avatarImg.image = UIImage(data: data)
                }catch let err {
                     print("Error : \(err.localizedDescription)")
                }
                cell.accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
                
                // お気に入りボタンを押したことをviewModelにbind
                cell.favoriteBtn.rx.tap
                    .map{ row }
                    .bind(to: self.viewModel.inputs.tapFavoriteBtn)
                    .disposed(by: self.disposeBag)
                
                return cell
        }
        .disposed(by: self.disposeBag)
        
        // refresh中かどうかのflagをViewにbind
        self.viewModel.outputs.isRefreshing
            .bind(to: self.refreshCtl.rx.isRefreshing)
            .disposed(by: self.disposeBag)

        // 選択されたユーザーのリポジトリを表示するViewに遷移ためにuserNameをViewにbind
        self.viewModel.outputs.userName
            .bind(to: Binder(self) { _, name in
                var repositoryVC: RepositoryViewController? = RepositoryViewController.init(nibName: nil, bundle: nil)

                repositoryVC!.title = name // 遷移先のViewのtitleをユーザー名にする
                self.navigationController?.pushViewController(repositoryVC!, animated: true) //遷移する
                repositoryVC = nil // メモリリークを防ぐ
            })
            .disposed(by: self.disposeBag)
    }
}
