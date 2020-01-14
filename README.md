Github_App
========================

[![Platform](http://img.shields.io/badge/platform-ios-blue.svg?style=flat
)](https://developer.apple.com/iphone/index.action)
[![Language](http://img.shields.io/badge/language-swift-brightgreen.svg?style=flat
)](https://developer.apple.com/swift)


This is a sample that was implemented the MVVM Architecture using RxSwift in iOS.


[RxSwift](https://github.com/ReactiveX/RxSwift)


#### It is a simple application that the user search  github users and repositories.
![1](https://user-images.githubusercontent.com/41050625/72330551-0ca3b280-36fa-11ea-8e38-8ba27914897e.gif)
![2](https://user-images.githubusercontent.com/41050625/72330552-0d3c4900-36fa-11ea-9c88-aa644e69613f.gif)


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

