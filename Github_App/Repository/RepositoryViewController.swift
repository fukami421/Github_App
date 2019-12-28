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
        fileprivate let viewModel: SearchUserViewModel = SearchUserViewModel()
        private let disposeBag = DisposeBag()
        
        // MARK: - Functions
        override func viewDidLoad() {
            super.viewDidLoad()
            self.bindViewModel()
//            self.title = ""
        }
        
        private func bindViewModel()
        {
        }
    }

