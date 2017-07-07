# Table of Contents  
  
1. [Development Environment](#development-environment)  
2. [Task Management](#task-management)  
3. [Coding Rules](#coding-rules)  
4. [References](#references)  
5. [Architecture](#architecture)  
  
# Development Environment  
  
## Xcode  
  
Xcode7.3 or above (for Swift2.2 support)  
  
## Swift 2.2  
  
## CocoaPods  
  
We use EXACT version 0.39.0, or Podfile.lock may conflict.  
`$ pod install` with exact version of CocoaPods, see here:  [downgrading-or-installing-older-version-of-cocoapods](http://stackoverflow.com/questions/20487849/downgrading-or-installing-older-version-of-cocoapods/31772875#31772875)  
  
The reason we include Podfile.lock is to prevent unexpected update dependent libraries.   
  
## SwiftLint  
  
See: [SwiftLint](https://github.com/realm/SwiftLint)    
The lint rules are specified in `perzzle-ios/.swiftlint.yml`.   
You can modify it when there's solid reason (and when you submit a pull-request, explain why).  
Basically you should not left any warnings nor errors when submitting pull-request.  
  
# Task Management  
  
## Tool  
  
Using [Trello](https://trello.com/b/Llcz4AwV/perzzle-ios-studio-ios)  
  
## Git + GitHub Flow  
  
With BitBucket ;-)   
BitBucket also has pull-request and stuff so we can use it as same as GitHub.   
The only thing we have to consider about is it doesn't have a way to revert pull-requests on the web. We have to do revert on terminal (on the local machine).   
  
About GitHub flow:  [https://guides.github.com/introduction/flow/](https://guides.github.com/introduction/flow/)  
  
## Task Flow  
  
1. You're assign to a task on Trello.  
2. If you have any questions, suggestion and stuff comment on the task.   
3. Refresh master branch and checkout from master, the new branch name could be `task<taiga-task-number>_<what-the-task-is>` like `task48_write_getting_started`.  
4. Implement, commit then push it once it's done.  
5. Create a pull request on BitBucket, assign a reviewer.  
6. Once the review done, merge the branch to master.   
  
# Coding Rules  
  
Basically we follows [リクルートライフスタイル Swiftコーディング規約](https://github.com/recruit-lifestyle/swift-style-guide)  
  
Excepts:  
  
* 1-2 No class name prefixes: To cleary show which module the class belongs to.   
* 2-6 & 2-7 Avoid forced Unwrapping: To make them work as assertion (e.g. `self.navigationController!` if you don't want the ViewController be without NavigationController). When the variable can be nil on runtime, of course you should avoid force unwrapping.    
  
When you find any codes those're not following the coding rule, please make them follow it.  
And if it possible, define the rule in Swiftlint.  
  
# References  
  
## API Specification  
  
See: [Perzzle API Specification](https://bitbucket.org/personalstock/perzzle-api-specifications)  
  
Production domain is `http://api.perzzle.com/v1/`  
  
example requests  
  
```shell  
$ curl -v -X POST -H "content-type: application/json" --data '{"email_or_studio_unique_name": <name>, "password": <pass>}' http://api.perzzle.com/v1/auth/login   
# It returns an auth token  
  
$ curl -v -H "Authorization: Token  <token>" "http://api.perzzle.com/v1/me/courses"  
```

# Architecture

## Code

There're two apps (targets) in this project.  
Perzzle (target name: PezzleHub) and PerzzleStudio (PerzzleStudio).  
  
Perzzle is the main app, user can browse courses they want to see.  
PerzzleStudio is for owners' app. Course owners create courses on the web and check how it looks like using PerzzleStudio app.  
  
Those targets share most of codes, codes under PezzleHub/DataModels and PezzleHub/Utilities are used by both targets, other codes are depending on what they are.  
  
Targets also share image assets, PezzleHub/Shared.xcassets is the one. Target-depending assets are stored in PezzleHub/PerzzleHub.xcassets and PerzzleStudio/PerzzleStudio.xcassets.  
  
[NOTE]  
Some of the classes are used for both app and expected to handle app-specific tasks.  
To achieve this, we're using Protocol Extension.  
Those app-specific functions are written under `perzzle-ios/PezzleHub/Utilities/HubClassExtensions/` and `perzzle-ios/PerzzleStudio/Utilities/HubClassExtensions/`  
  
  
## ViewControllers  
  
Most of ViewControllers in the apps have their own storyboard file, and be instantiated by `SomeViewController.instantiate()` method. (in `perzzle-ios/PezzleHub/Utilities/UIViewControllerExtensions.swift`)  
`instantiate()` loads the ViewController from its storyboard, but the method can be overriden so some of ViewControllers have their own initializing process.   
  
  
## Main Data Model
  
* PHOwner    : Represents user that creates courses.  
* PHCourse   : Represents course. Owner creates courses and users register and watch courses. Contains chapters(PHChapter). Has owner(PHOwner).  
* PHChapter  : Represents chapter. Each chapters are delivered on specific date the owner specified, like every Monday 18:00. Contains pieces(PHPiece).  
* PHPiece    : Represents piece (each bubble on chat view on Perzzle app). Contains text and several attachment data.  
  
## Directory Structure  
  
perzzle-ios/PezzleHub/ : Perzzle and Perzzle-PerzzleStudio shared files  
perzzle-ios/PerzzleStudio : PerzzleStudio specific files  

perzzle-ios/<target>/Views/ : General Views  
perzzle-ios/<target>/Cells/ : General TableViewCells & CollectionViewCells  
perzzle-ios/<target>/ViewControllers/ : ViewController, storyboard, ViewController-specific views and cells  
perzzle-ios/<target>/DataModels/ : API, authentication and data related classes  
perzzle-ios/<target>/DataModels/Models/ : Data models  
perzzle-ios/<target>/Utilities/ : Foundation, UIKit, Pods libraries and other extensions