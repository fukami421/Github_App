//
//  WebViewController.swift
//  Github_App
//
//  Created by 深見龍一 on 2019/12/29.
//  Copyright © 2019 深見龍一. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import RxCocoa
import RxOptional
import RxWebKit

class WebViewController: UIViewController, WKNavigationDelegate {
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var toolBar: UIToolbar!
    
    private var goBackButton: UIBarButtonItem!
    private var fastForwardButton: UIBarButtonItem!
    public var repository_url: URL!
    
    // MARK: - Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.barTintColor = UIColor.orange
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]

        self.setUpToolBar()
        self.setUpWebView()
    }
    
    private func setUpWebView()
    {
        // Observableの定義
        let loadingObservable = self.webView.rx.observe(Bool.self, "loading")
            .filterNil()
            .share()
        
        // プログレスバーの表示非表示
        loadingObservable
            .map{return !$0} // Boolを反転
            .observeOn(MainScheduler.instance)
            .bind(to: self.progressView.rx.isHidden)
            .disposed(by: self.disposeBag)
        
        // Webの読み込み具合をプログレスバーのゲージにbind
        self.webView.rx.estimatedProgress
            .map{return Float($0)}
            .observeOn(MainScheduler.instance)
            .bind(to: self.progressView.rx.progress)
            .disposed(by: self.disposeBag)
        
        // 読み込んだページのタイトルをNavigationBarのちタイトルにbind
        self.webView.rx.title
            .filterNil()
            .observeOn(MainScheduler.instance)
            .bind(to: self.rx.title)
            .disposed(by: self.disposeBag)

        // 戻るボタンの選択可否
        self.webView.rx.canGoBack
            .observeOn(MainScheduler.instance)
            .bind(to: self.goBackButton.rx.isEnabled)
            .disposed(by: self.disposeBag)

        // 進むボタンの選択可否
        self.webView.rx.canGoForward
            .observeOn(MainScheduler.instance)
            .bind(to: self.fastForwardButton.rx.isEnabled)
            .disposed(by: self.disposeBag)

        // Webの読み込み
        let myRequest = URLRequest(url: self.repository_url)
        self.webView.load(myRequest)
    }
    
    
    
    private func setUpToolBar()
    {
        // 各ボタンを生成する
        let spacerEdge: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacerEdge.width = 16
        let spacer: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spacer.width = 42
        self.goBackButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem(rawValue: 101)!, target: self, action: #selector(back))
        self.fastForwardButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem(rawValue: 102)!, target: self, action: #selector(forward))
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refresh))
        let openInSafari = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(safari))
        let spacerRight: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        // ボタンをツールバーに入れる
        toolBar.items = [spacerEdge, goBackButton, spacer, fastForwardButton, spacerRight, refreshButton, spacer, openInSafari, spacerEdge]
    }
    // 戻るボタンの処理
    @objc func back(_: AnyObject) {
        self.webView?.goBack()
    }

    // 進むボタンの処理
    @objc func forward(_: AnyObject) {
        self.webView?.goForward()
    }

    // 再読み込みボタンの処理
    @objc func refresh(_: AnyObject) {
        self.webView?.reload()
    }

    // safari で開く
    @objc func safari(_: AnyObject) {
        let url = self.webView?.url
        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
    }
}
