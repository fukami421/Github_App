//
//  FavoriteViewModel.swift
//  Github_App
//
//  Created by 深見龍一 on 2020/01/02.
//  Copyright © 2020 深見龍一. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

protocol FavoriteViewModelInputs {
    var itemSelected: AnyObserver<IndexPath>{ get }
    var tapFavoriteBtn: AnyObserver<Int>{ get }
    var refreshTrigger: AnyObserver<Void>{ get }
}

protocol FavoriteViewModelOutputs {
    var favoriteUsers: Observable<[Favorite]> { get }
    var userName: Observable<String> { get }
    var isRefreshing: Observable<Bool>{ get }
}

protocol FavoriteViewModelType {
    var inputs: FavoriteViewModelInputs { get }
    var outputs: FavoriteViewModelOutputs { get }
}

final class FavoriteUserViewModel: FavoriteViewModelType, FavoriteViewModelInputs, FavoriteViewModelOutputs {
    

    // MARK: - Properties
    var inputs: FavoriteViewModelInputs { return self }
    var outputs: FavoriteViewModelOutputs { return self }

    let itemSelected: AnyObserver<IndexPath>
    let tapFavoriteBtn: AnyObserver<Int>
    let refreshTrigger: AnyObserver<Void>
    
    let favoriteUsers: Observable<[Favorite]>
    let userName: Observable<String>
    let isRefreshing: Observable<Bool>
    
    private let disposeBag   = DisposeBag()
    private let udf = UserDefaults.standard
    
    // MARK: - Initializers
    init() {
        // Inputのpropertyの初期化
        let _itemSelected = PublishRelay<IndexPath>()
        self.itemSelected = AnyObserver<IndexPath> { event in
            guard let indexPath = event.element else {
                return
            }
            _itemSelected.accept(indexPath)
        }
        
        let _tapFavoriteBtn = PublishRelay<Int>()
        self.tapFavoriteBtn = AnyObserver<Int> { event in
            guard let e = event.element else {
                return
            }
            _tapFavoriteBtn.accept(e)
        }
        
        let _refreshTrigger = PublishRelay<Void>()
        self.refreshTrigger = AnyObserver<Void> { event in
            guard let e = event.element else {
                return
            }
            _refreshTrigger.accept(e)
        }
        
        // Ouputのpropertyの初期化
        let _favoriteUsers = BehaviorRelay<[Favorite]>(value: Favorite.get())
        self.favoriteUsers = _favoriteUsers.asObservable()

        let _userName = PublishRelay<String>()
        self.userName = _userName.asObservable()

        let _isRefreshing = BehaviorRelay<Bool>(value: false)
        self.isRefreshing = _isRefreshing.asObservable()

        // Itemが選択されたら、該当のindexのPageのURLを取り出す
        _itemSelected
            .withLatestFrom(_favoriteUsers) { ($0.row, $1) }
            .flatMap { index, users -> Observable<String> in
                guard index < users.count else {
                    return .empty()
                }
                return .just(_favoriteUsers.value[index].user_name)
            }
            .bind(to: _userName)
            .disposed(by: disposeBag)
        
        // お気に入りボタンがtapされたらお気に入りに追加, 削除処理を行う
        _tapFavoriteBtn
            .subscribe({ _index in
                let row = _index.element!
                var favorites: [Favorite] = Favorite.get()

                var index = -1
                for favorite in favorites
                {
                    index += 1
                    if favorite.user_name == _favoriteUsers.value[row].user_name
                    {
                        if favorite.is_favorite
                        {
                            favorites.remove(at: index)
                            Favorite.save(favorites)
                            return
                        }
                    }
                }
                favorites.append(Favorite(user_name: _favoriteUsers.value[row].user_name, avatar_url: _favoriteUsers.value[row].avatar_url, is_favorite: true))
                Favorite.save(favorites)
            })
            .disposed(by: self.disposeBag)
        
        // refreshされたらお気に入りユーザーを正しく表示する
        _refreshTrigger
            .subscribe({ _ in
                _isRefreshing.accept(true)
                self.refresh(_favoriteUsers: _favoriteUsers)
                _isRefreshing.accept(false)
            })
            .disposed(by: self.disposeBag)
    }

    // MARK: - Functions
    // 現段階でのお気に入りユーザーの取得
    func refresh(_favoriteUsers: BehaviorRelay<[Favorite]>)
    {
        let favorites = Favorite.get()
        _favoriteUsers.accept(favorites!)
    }
}
