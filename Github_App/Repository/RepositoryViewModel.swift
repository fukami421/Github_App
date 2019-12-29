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
}

protocol RepositoryViewModelOutputs {
    var searchResultText: Observable<String> { get }
    var repositories: Observable<[Repository]> { get }
    var isLoading: Observable<Bool>{ get }
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
    
    let searchResultText: Observable<String>
    let repositories: Observable<[Repository]>
    let isLoading: Observable<Bool>
    
    private let disposeBag   = DisposeBag()
    
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
        
        // Ouputのpropertyの初期化
        let _searchResultText = BehaviorRelay<String>(value: "Github Search API")
        self.searchResultText = _searchResultText.asObservable().map{"User検索結果: " + $0 + "件"}
        
        let _repositories = BehaviorRelay<[Repository]>(value: [])
        self.repositories = _repositories.asObservable()

        let _isLoading = PublishRelay<Bool>()
        self.isLoading = _isLoading.asObservable()

        // APIへのリクエスト
        _userName
            .filter{ $0.count > 0 }
//            .debounce(.milliseconds(500), scheduler: MainScheduler.instance) // 0.5s以上変更がなければ
            .subscribe({ value in
                _isLoading.accept(true)
                self.showRepository(repositories: _repositories, userName: _userName.value)
                _isLoading.accept(false)
            })
            .disposed(by: self.disposeBag)
        
        
        // Itemが選択されたら、該当のindexのPageのURLを取り出す
//        _itemSelected
//            .withLatestFrom(_users) { ($0.row, $1) }
//            .flatMap { index, users -> Observable<String> in
//                guard index < users.count else {
//                    return .empty()
//                }
//                return .just(users[index].login)
//            }
//            .bind(to: _userName)
//            .disposed(by: disposeBag)
    }

    
    // MARK: - Functions
    fileprivate func searchRepository(users: BehaviorRelay<[SearchUser.Item]>, searchText: String, searchResult: BehaviorRelay<String>)
    {
        let url = "https://api.github.com/users/fukami421/repos"
        var usersItem: [SearchUser.Item] = []
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
    }
    
    fileprivate func showRepository(repositories: BehaviorRelay<[Repository]>, userName: String)
    {
        let url = "https://api.github.com/users/" + userName + "/repos"
        var repositoriesItems: [Repository] = []
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
                        let items: [Repository] = try decoder.decode([Repository].self, from: data)
                        for item in items
                        {
                            repositoriesItems.append(item)
                        }
                        repositories.accept(repositoriesItems)
                        print(repositories.value)
                    } catch {
                        print("error:")
                        print(error)
                    }
                case .failure:
                    print("Failure!")
            }
        }

    }
}
