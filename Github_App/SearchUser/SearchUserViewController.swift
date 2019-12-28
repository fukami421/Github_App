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
    fileprivate let viewModel: SearchUserViewModel = SearchUserViewModel()
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    private let disposeBag = DisposeBag()
    
//    init(viewModel: Input & Output = SearchUserViewModel()) {
//        self.input = viewModel
//        self.output = viewModel
//        super.init(nibName: nil, bundle: nil)
//        print("initされたよ")
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
        self.title = "Search User"
    }
    
    private func bindViewModel()
    {
        // SearchBarの入力値をViewModelにbind
        self.searchBar.rx.text
            .bind(to: self.viewModel.inputs.searchText)
            .disposed(by: self.disposeBag)
        
        self.viewModel.searchResultText
            .bind(to: self.rx.title)
            .disposed(by: disposeBag)        
        }
    }
}
