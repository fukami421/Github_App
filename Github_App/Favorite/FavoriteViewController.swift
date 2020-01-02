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

class FavoriteViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Favorite User"
    }
}
