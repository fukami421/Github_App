//
//  MyPageViewModel.swift
//  Github_App
//
//  Created by 深見龍一 on 2020/01/04.
//  Copyright © 2020 深見龍一. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Alamofire

protocol MyPageViewModelInputs {
    var itemSelected: AnyObserver<IndexPath>{ get }
    var distanceToBottom: AnyObserver<Double>{ get }
}

protocol MyPageViewModelOutputs {
    var repositories: Observable<[MyPage]> { get }
    var isLoading: Observable<Bool>{ get }
    var repository_url: Observable<String> { get }
}

protocol MyPageViewModelType {
    var inputs: MyPageViewModelInputs { get }
    var outputs: MyPageViewModelOutputs { get }
}

final class MyPageViewModel: MyPageViewModelType, MyPageViewModelInputs, MyPageViewModelOutputs {

    // MARK: - Properties
    var inputs: MyPageViewModelInputs { return self }
    var outputs: MyPageViewModelOutputs { return self }
    
    let itemSelected: AnyObserver<IndexPath>
    let distanceToBottom: AnyObserver<Double>

    let repositories: Observable<[MyPage]>
    let isLoading: Observable<Bool>
    let repository_url: Observable<String>
    
    private let disposeBag   = DisposeBag()
    private var pageIndex: Int = 1
    private var pageEnd: Bool = false
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

        let _distanceToBottom = PublishRelay<Double>()
        self.distanceToBottom = AnyObserver<Double> { event in
            guard let distance = event.element else {
                return
            }
            _distanceToBottom.accept(distance)
        }

        // Ouputのpropertyの初期化
        let _repositories = BehaviorRelay<[MyPage]>(value: [])
        self.repositories = _repositories.asObservable()

        let _isLoading = BehaviorRelay<Bool>(value: false)
        self.isLoading = _isLoading.asObservable()

        let _repository_url = PublishRelay<String>()
        self.repository_url = _repository_url.asObservable()
        
        // Itemが選択されたら、該当のindexのPageのURLを取り出す
        _itemSelected
            .filter{ $0.count > 0 }
            .withLatestFrom(_repositories) { ($0.row, $1) }
            .flatMap { index, repositories -> Observable<String> in
                guard index < repositories.count else {
                    return .empty()
                }
                return .just(repositories[index].full_name)
            }
            .bind(to: _repository_url)
            .disposed(by: disposeBag)

        // スクロールできる距離がある一定の距離以下になったらapiを叩く
        _distanceToBottom
            .filter{ $0 < 550 && !self.pageEnd }
            .throttle(.milliseconds(500), latest: false, scheduler: MainScheduler.instance)
            .subscribe({ _ in
                print("実行")
                self.showRepository(repositories: _repositories, isLoading: _isLoading)
            })
            .disposed(by: self.disposeBag)
    }

    
    // MARK: - Functions
    fileprivate func showRepository(repositories: BehaviorRelay<[MyPage]>, isLoading: BehaviorRelay<Bool>)
    {
        let url = "https://api.github.com/user/repos"
        let parameters:[String: Any] = [
            "access_token": self.udf.string(forKey: "oauthToken")!,
            "page": self.pageIndex,
            "per_page": 20
        ]
        var repositoriesItems: [MyPage] = []
        Alamofire.request(url, method: .get, parameters: parameters)
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
                        let items: [MyPage] = try decoder.decode([MyPage].self, from: data)
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
