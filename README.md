Github_App
========================

[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
)](https://developer.apple.com/swift)


This is a sample that was implemented the MVVM Architecture using RxSwift in iOS.


[RxSwift](https://github.com/ReactiveX/RxSwift)


#### It is a simple application that the user search  github users and repositories.
![users-_2_ (1)](https://user-images.githubusercontent.com/41050625/71780656-b1423800-3008-11ea-8cab-127002d9a39f.gif)

<img width="238" alt="repo" src="https://user-images.githubusercontent.com/41050625/71780721-6d036780-3009-11ea-8846-4087c53ecf5d.png">


## Used Libraries
[RxSwift](https://github.com/ReactiveX/RxSwift)  
[Alamofire](https://github.com/Alamofire/Alamofire)  
[OAuthSwift](https://github.com/OAuthSwift/OAuthSwift)  
[RxCocoa](https://github.com/ReactiveX/RxSwift/tree/master/RxCocoa)  
[RxOptional](https://github.com/RxSwiftCommunity/RxOptional)  
[RxWebKit](https://github.com/RxSwiftCommunity/RxWebKit)  


## Setup
#### Pod setup
```
pod install
```

#### Github API setup

You have to get peronal consumerKey and consumerSecret from github and set token to `LoginViewController.swift`

```LoginViewController.swift
consumerKey = "consumerKeyを入れる", 
consumerSecret = "consumerSecretを入れる"
```

##### see more information

[GitHub API Tokens](https://github.com/blog/1509-personal-api-tokens)

[GitHub API Reference](https://developer.github.com/v3/)


Warning: you can make up to 5000 requests per minute

[search rate limit](https://developer.github.com/v3/search/#rate-limit)

