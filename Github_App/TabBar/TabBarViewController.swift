//
//  TabBarViewController.swift
//  Github_App
//
//  Created by 深見龍一 on 2019/12/27.
//  Copyright © 2019 深見龍一. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let seachVC = UINavigationController(rootViewController: SearchViewController.init(nibName: nil, bundle: nil))
        // タブのFooter部分を設定
        seachVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 0)
//
//        let secondVC = UINavigationController(rootViewController: SecondViewController.init(nibName: nil, bundle: nil))
//        // タブのFooter部分を設定
//        secondVC.tabBarItem = UITabBarItem(tabBarSystemItem: .bookmarks, tag: 1)
        
        self.viewControllers = [seachVC]
    }
}
