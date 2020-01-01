//
//  RepositoryViewModel.swift
//  Github_App
//
//  Created by 深見龍一 on 2019/12/28.
//  Copyright © 2019 深見龍一. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

protocol RepositoryViewModelInputs {
    var userName: AnyObserver<String?>{ get }
    var searchText: AnyObserver<String?>{ get }
    var itemSelected: AnyObserver<IndexPath>{ get }
    var distanceToBottom: AnyObserver<Double>{ get }
}

protocol RepositoryViewModelOutputs {
    var searchResultText: Observable<String> { get }
    var repositories: Observable<[Repository]> { get }
    var isLoading: Observable<Bool>{ get }
    var repository_url: Observable<String> { get }
}

protocol RepositoryViewModelType {
    var inputs: RepositoryViewModelInputs { get }
    var outputs: RepositoryViewModelOutputs { get }
}

final class RepositoryViewModel: RepositoryViewModelType, RepositoryViewModelInputs, RepositoryViewModelOutputs {
    

    // MARK: - Properties
    var inputs: RepositoryViewModelInputs { return self }
    var outputs: RepositoryViewModelOutputs { return self }
    
    let userName: AnyObserver<String?>
    let searchText: AnyObserver<String?>
    let itemSelected: AnyObserver<IndexPath>
    let distanceToBottom: AnyObserver<Double>

    let searchResultText: Observable<String>
    let repositories: Observable<[Repository]>
    let isLoading: Observable<Bool>
    let repository_url: Observable<String>
    
    private let disposeBag   = DisposeBag()
    private var pageIndex: Int = 1
    private var pageEnd: Bool = false

    // MARK: - Initializers
    init() {
        // Inputのpropertyの初期化
        let _userName = BehaviorRelay<String>(value: "")
        self.userName = AnyObserver<String?>() { event in
            guard let text = event.element else {
                return
            }
            _userName.accept(text!)
            print("username: " + text!)
        }

        
        let _searchText = BehaviorRelay<String>(value: "")
        self.searchText = AnyObserver<String?>() { event in
            guard let text = event.element else {
                return
            }
            _searchText.accept(text!)
            print(text!)
        }
        
        let _itemSelected = PublishRelay<IndexPath>()
        self.itemSelected = AnyObserver<IndexPath> { event in
            guard let indexPath = event.element else {
                return
            }
            _itemSelected.accept(indexPath)
        }

        let _distanceToBottom = PublishRelay<Double>()
        self.distanceToBottom = AnyObserver<Double> { event in
            guard let distance = event.element else {
                return
            }
            print(distance)
            _distanceToBottom.accept(distance)
        }

        // Ouputのpropertyの初期化
        let _searchResultText = BehaviorRelay<String>(value: "Github Search API")
        self.searchResultText = _searchResultText.asObservable().map{"User検索結果: " + $0 + "件"}
        
        let _repositories = BehaviorRelay<[Repository]>(value: [])
        self.repositories = _repositories.asObservable()

        let _isLoading = BehaviorRelay<Bool>(value: false)
        self.isLoading = _isLoading.asObservable()

        let _repository_url = PublishRelay<String>()
        self.repository_url = _repository_url.asObservable()

        // APIへのリクエスト
        _userName
            .map{ $0.trimmingCharacters(in: .whitespaces) }
            .filter{ $0.count > 0 }
            .subscribe({ value in
                self.pageIndex = 1
                self.pageEnd = false
                    self.showRepository(repositories: _repositories, userName: _userName.value, isLoading: _isLoading)
            })
            .disposed(by: self.disposeBag)
        
        
        // Itemが選択されたら、該当のindexのPageのURLを取り出す
        _itemSelected
            .filter{ $0.count > 0 }
            .withLatestFrom(_repositories) { ($0.row, $1) }
            .flatMap { index, repositories -> Observable<String> in
                guard index < repositories.count else {
                    return .empty()
                }
                return .just(repositories[index].html_url)
            }
            .bind(to: _repository_url)
            .disposed(by: disposeBag)

        // スクロールできる距離がある一定の距離以下になったらapiを叩く
        _distanceToBottom
            .filter{ $0 < 550 && !self.pageEnd && self.pageIndex > 1 }
            .throttle(.milliseconds(500), latest: false, scheduler: MainScheduler.instance)
            .subscribe({ _ in
                self.showRepository(repositories: _repositories, userName: _userName.value, isLoading: _isLoading)
            })
            .disposed(by: self.disposeBag)
    }

    
    // MARK: - Functions
    fileprivate func searchRepository(users: BehaviorRelay<[SearchUser.Item]>, searchText: String, searchResult: BehaviorRelay<String>, isLoading: BehaviorRelay<Bool>)
    {
        let url = "https://api.github.com/users/fukami421/repos"
        var usersItem: [SearchUser.Item] = []
        DispatchQueue.global(qos: .default).async {
            isLoading.accept(false)
        Alamofire.request(url, method: .get, parameters: nil)
        .validate(statusCode: 200..<300)
        .validate(contentType: ["application/json"])
        .responseJSON { response in
            switch response.result {
                case .success:
                    print("success!")
                    guard let data = response.data else {
                        return
                    }
                    let decoder = JSONDecoder()
                    do {
                        let tasks: SearchUser = try decoder.decode(SearchUser.self, from: data)
                        searchResult.accept(String(tasks.total_count))
                        for item in tasks.items
                        {
                            usersItem.append(item)
                        }
                        users.accept(usersItem)
                    } catch {
                        print("error:")
                        print(error)
                    }
                case .failure:
                    print("Failure!")
                    searchResult.accept(String(0))
            }
            }
            DispatchQueue.main.async {
                isLoading.accept(true)
            }
        }
    }
    
    fileprivate func showRepository(repositories: BehaviorRelay<[Repository]>, userName: String, isLoading: BehaviorRelay<Bool>)
    {
        let url = "https://api.github.com/users/" + userName + "/repos" + "?page=" + String(self.pageIndex) + "&per_page=20"
        print("url: " + url)
        var repositoriesItems: [Repository] = []
        if self.pageIndex == 1{
            isLoading.accept(false)
        }
        Alamofire.request(url, method: .get, parameters: nil)
        .validate(statusCode: 200..<300)
        .validate(contentType: ["application/json"])
        .responseJSON { response in
            switch response.result {
                case .success:
                    print("showRepository API success!")
                    guard let data = response.data else {
                        return
                    }
                    let decoder = JSONDecoder()
                    do {
                        let items: [Repository] = try decoder.decode([Repository].self, from: data)
                        if items.count == 0 // 表示できるリポジトリが無くなったらこれ以上APIを叩かないようにself.pageEndにtrueを代入
                        {
                            self.pageEnd = true
                            return
                        }
                        for item in items
                        {
                            repositoriesItems.append(item)
                        }
                        if self.pageIndex == 1
                        {
                            repositories.accept(repositoriesItems)
                            isLoading.accept(true)
                        }else
                        {
                            repositories.accept(repositories.value + repositoriesItems)
                        }
                        print("num: " + String(self.pageIndex))
                        self.pageIndex += 1
                        isLoading.accept(true)
                    } catch {
                        print("error:")
                        print(error)
                        isLoading.accept(true)
                    }
                case .failure:
                    print("Failure!")
                    isLoading.accept(true)
            }
        }
    }
}
