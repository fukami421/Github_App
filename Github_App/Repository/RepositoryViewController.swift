//
//  RepositoryViewController.swift
//  Github_App
//
//  Created by 深見龍一 on 2019/12/28.
//  Copyright © 2019 深見龍一. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RepositoryViewController: UIViewController {
    // MARK: - Properties
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    let activityIndicator = UIActivityIndicatorView()
    
    public var userName = BehaviorRelay<String>(value: "")
    fileprivate let viewModel: RepositoryViewModel = RepositoryViewModel()
    private let disposeBag = DisposeBag()
        
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        self.activityIndicator.center = self.view.center
        self.activityIndicator.startAnimating()
        self.view.addSubview(self.activityIndicator)

        self.userName.accept(self.title!)
        self.bindViewModel()
    }
    
    private func bindViewModel()
    {
        // SearchBarの入力値をViewModelにbind
        self.searchBar.rx.text
            .bind(to: self.viewModel.inputs.searchText)
            .disposed(by: self.disposeBag)

        // self.titleに表示されている値をViewModelにbind
        self.userName
            .bind(to: self.viewModel.inputs.userName)
            .disposed(by: self.disposeBag)
        
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
                cell.detailTextLabel?.text = element.description
                return cell
        }
        .disposed(by: self.disposeBag)

        // 選択されたリポジトリのWebViewに遷移
        self.viewModel.outputs.repository_url
            .bind(to: Binder(self) { _, url in
                var webVC: WebViewController? = WebViewController.init(nibName: nil, bundle: nil)
                webVC?.repository_url = URL(string: url)
                self.navigationController?.pushViewController(webVC!, animated: true) //遷移する
                webVC = nil // メモリリークを防ぐ
            })
            .disposed(by: disposeBag)

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
