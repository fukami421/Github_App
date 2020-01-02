//
//  SearchUserViewModel.swift
//  Github_App
//
//  Created by 深見龍一 on 2019/12/28.
//  Copyright © 2019 深見龍一. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

protocol SearchUserViewModelInputs {
    var searchText: AnyObserver<String?>{ get }
    var itemSelected: AnyObserver<IndexPath>{ get }
    var distanceToBottom: AnyObserver<Double>{ get }
    var tapFavoriteBtn: AnyObserver<Void>{ get }
}

protocol SearchUserViewModelOutputs {
    var searchResultText: Observable<String> { get }
    var users: Observable<[SearchUser.Item]> { get }
    var userName: Observable<String> { get }
    var isLoading: Observable<Bool>{ get }
}

protocol SearchUserViewModelType {
    var inputs: SearchUserViewModelInputs { get }
    var outputs: SearchUserViewModelOutputs { get }
}

final class SearchUserViewModel: SearchUserViewModelType, SearchUserViewModelInputs, SearchUserViewModelOutputs {
    

    // MARK: - Properties
    var inputs: SearchUserViewModelInputs { return self }
    var outputs: SearchUserViewModelOutputs { return self }

    let searchText: AnyObserver<String?>
    let itemSelected: AnyObserver<IndexPath>
    let distanceToBottom: AnyObserver<Double>
    let tapFavoriteBtn: AnyObserver<Void>
    
    let searchResultText: Observable<String>
    let users: Observable<[SearchUser.Item]>
    let userName: Observable<String>
    let isLoading: Observable<Bool>

    private let disposeBag   = DisposeBag()
    private var pageIndex: Int = 1
    private var pageEnd: Bool = false
    
    // MARK: - Initializers
    init() {
        // Inputのpropertyの初期化
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
            _distanceToBottom.accept(distance)
        }
        
        let _tapFavoriteBtn = PublishRelay<Void>()
        self.tapFavoriteBtn = AnyObserver<Void> { event in
            guard let e = event.element else {
                return
            }
            _tapFavoriteBtn.accept(e)
        }
        
        // Ouputのpropertyの初期化
        let _searchResultText = BehaviorRelay<String>(value: "")
        self.searchResultText = _searchResultText.asObservable().filter{ $0 != "" }.map{"User検索結果: " + $0 + "件"}
        
        let _users = BehaviorRelay<[SearchUser.Item]>(value: [])
        self.users = _users.asObservable()

        let _userName = PublishRelay<String>()
        self.userName = _userName.asObservable()

        let _isLoading = BehaviorRelay<Bool>(value: true)
        self.isLoading = _isLoading.asObservable()

        // APIへのリクエスト
        _searchText
            .map{ $0.trimmingCharacters(in: .whitespaces) }
            .filter{ $0.count > 0 }
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance) // 0.5s以上変更がなければ
            .subscribe({ value in
                self.pageIndex = 1
                self.pageEnd = false
                self.api(users: _users, searchText: _searchText.value, searchResult: _searchResultText, isLoading: _isLoading)
            })
            .disposed(by: self.disposeBag)
        
        // Itemが選択されたら、該当のindexのPageのURLを取り出す
        _itemSelected
            .withLatestFrom(_users) { ($0.row, $1) }
            .flatMap { index, users -> Observable<String> in
                guard index < users.count else {
                    return .empty()
                }
                return .just(users[index].login)
            }
            .bind(to: _userName)
            .disposed(by: disposeBag)
        
        // スクロールできる距離がある一定の距離以下になったらapiを叩く
        _distanceToBottom
            .filter{ $0 < 550 && _searchText.value != "" && !self.pageEnd }
            .throttle(.milliseconds(500), latest: false, scheduler: MainScheduler.instance)
            .subscribe({ _ in
                self.api(users: _users, searchText: _searchText.value, searchResult: _searchResultText, isLoading: _isLoading)
            })
            .disposed(by: self.disposeBag)
        
        // お気に入りボタンがtapされたらお気に入りに追加, 削除処理を行う
        _tapFavoriteBtn
            .subscribe({ _ in
                print("tap")
            })
            .disposed(by: self.disposeBag)
    }

    
    // MARK: - Functions
    func api(users: BehaviorRelay<[SearchUser.Item]>, searchText: String, searchResult: BehaviorRelay<String>, isLoading: BehaviorRelay<Bool>)
    {
        let url = "https://api.github.com/search/users?q=" + searchText + "&page=" + String(self.pageIndex) + "&per_page=30"
        var usersItem: [SearchUser.Item] = []
        if self.pageIndex == 1{
            isLoading.accept(false)
        }
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
                        let items: SearchUser = try decoder.decode(SearchUser.self, from: data)
                        searchResult.accept(String(items.total_count))
                        for item in items.items
                        {
                            usersItem.append(item)
                        }
                        if self.pageIndex == 1
                        {
                            users.accept(usersItem)
                            isLoading.accept(true)
                        }else
                        {
                            users.accept(users.value + usersItem)
                        }
                        self.pageIndex += 1
                        print(Int(searchResult.value)!)
                        print(Double(searchResult.value)! / 20)
                        if Int(searchResult.value)! % 20 <= self.pageIndex{ self.pageEnd = true }
                    } catch {
                        print("error:")
                        print(error)
                        isLoading.accept(true)
                    }
                case .failure:
                    print("Failure!")
                    searchResult.accept(String(0))
                    isLoading.accept(true)
            }
        }
    }
}
